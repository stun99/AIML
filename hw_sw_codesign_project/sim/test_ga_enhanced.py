import cocotb
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock
import random
import time

# GA Parameters
POPULATION_SIZE = 50  # Increased since hardware is faster
GENES = '''abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ 1234567890, .-;:_!"#%&/()=?@${[]}'''
TARGET = "I love GeeksforGeeks"

# Operation codes (match Verilog)
OP_FITNESS = 0
OP_CROSSOVER = 1 
OP_MUTATION = 2

class Individual(object):
    def __init__(self, chromosome):
        self.chromosome = chromosome 
        self.fitness = 999  # Will be calculated by hardware

    @classmethod
    def mutated_genes(self):
        global GENES
        gene = random.choice(GENES)
        return gene

    @classmethod
    def create_gnome(self):
        global TARGET
        gnome_len = len(TARGET)
        return [self.mutated_genes() for _ in range(gnome_len)]

# SOFTWARE BASELINE IMPLEMENTATIONS FOR BENCHMARKING
def software_fitness(chromosome_str, target_str):
    """Pure Python fitness calculation for baseline comparison"""
    start_time = time.perf_counter()
    
    mismatch_count = 0
    for i in range(len(chromosome_str)):
        if chromosome_str[i] != target_str[i]:
            mismatch_count += 1
    
    end_time = time.perf_counter()
    return mismatch_count, (end_time - start_time)

def software_crossover(parent1_str, parent2_str, seed=None):
    """Pure Python crossover for baseline comparison"""
    if seed is not None:
        random.seed(seed)
    
    start_time = time.perf_counter()
    
    offspring = ""
    for i in range(len(parent1_str)):
        prob = random.random()
        if prob < 0.45:
            offspring += parent1_str[i]
        elif prob < 0.90:
            offspring += parent2_str[i]
        else:
            offspring += random.choice(GENES)
    
    end_time = time.perf_counter()
    return offspring, (end_time - start_time)

def software_mutation(chromosome_str, mutation_rate=0.1, seed=None):
    """Pure Python mutation for baseline comparison"""
    if seed is not None:
        random.seed(seed)
    
    start_time = time.perf_counter()
    
    mutated = ""
    for char in chromosome_str:
        if random.random() < mutation_rate:
            mutated += random.choice(GENES)
        else:
            mutated += char
    
    end_time = time.perf_counter()
    return mutated, (end_time - start_time)

def software_ga_generation(population, generation_size=50):
    """Complete software GA generation for full system comparison"""
    start_time = time.perf_counter()
    
    # Calculate fitness for all individuals
    for individual in population:
        chromosome_str = "".join(individual.chromosome)
        individual.fitness, _ = software_fitness(chromosome_str, TARGET)
    
    # Sort by fitness
    population = sorted(population, key=lambda x: x.fitness)
    
    # Create new generation
    new_population = []
    elite_count = max(2, int(0.1 * generation_size))
    new_population.extend(population[:elite_count])
    
    # Generate offspring
    while len(new_population) < generation_size:
        # Select parents
        parent1 = random.choice(population[:int(0.3 * generation_size)])
        parent2 = random.choice(population[:int(0.3 * generation_size)])
        
        parent1_str = "".join(parent1.chromosome)
        parent2_str = "".join(parent2.chromosome)
        
        # Software crossover
        offspring_str, _ = software_crossover(parent1_str, parent2_str)
        
        # Software mutation
        mutated_str, _ = software_mutation(offspring_str, mutation_rate=0.1)
        
        # Create new individual
        offspring_chromosome = list(mutated_str)
        offspring = Individual(offspring_chromosome)
        
        # Software fitness calculation
        offspring.fitness, _ = software_fitness(mutated_str, TARGET)
        
        new_population.append(offspring)
    
    end_time = time.perf_counter()
    return new_population, (end_time - start_time)

# HARDWARE INTERFACE FUNCTIONS (existing)
def string_to_bits_safe(s):
    """Convert string to bits safely"""
    s = s.ljust(19)[:19]
    bits = 0
    for i, char in enumerate(s):
        bits |= ord(char) << (i * 8)
    return bits

def bits_to_string(bits):
    """Convert bits back to string"""
    s = ""
    for i in range(19):
        char_code = (bits >> (i * 8)) & 0xFF
        if char_code == 0:
            s += ' '
        else:
            s += chr(char_code)
    return s

async def hardware_fitness(dut, chromosome_str, target_str):
    """Calculate fitness using hardware"""
    
    # Convert to bits
    chromosome_bits = string_to_bits_safe(chromosome_str)
    target_bits = string_to_bits_safe(target_str)
    
    # Clear signals
    dut.start.value = 0
    dut.operation_valid.value = 0
    await RisingEdge(dut.clk)
    
    # Set fitness operation
    dut.operation.value = OP_FITNESS
    dut.chromosome_in.value = chromosome_bits
    dut.target_string.value = target_bits
    dut.operation_valid.value = 1
    dut.start.value = 1
    
    await RisingEdge(dut.clk)
    dut.start.value = 0
    dut.operation_valid.value = 0
    
    # Count cycles for completion
    cycles = 0
    while not dut.processing_done.value and cycles < 50:
        await RisingEdge(dut.clk)
        cycles += 1
    
    if cycles >= 50:
        return 999, cycles  # Timeout fallback
    
    fitness = int(dut.fitness_out.value)
    await RisingEdge(dut.clk)
    return fitness, cycles

async def hardware_crossover(dut, parent1_str, parent2_str, seed=None):
    """Perform crossover using hardware"""
    
    # Convert to bits
    parent1_bits = string_to_bits_safe(parent1_str)
    parent2_bits = string_to_bits_safe(parent2_str)
    crossover_seed = seed if seed is not None else random.randint(0, 0xFFFFFFFF)
    
    # Clear signals
    dut.start.value = 0
    dut.operation_valid.value = 0
    await RisingEdge(dut.clk)
    
    # Set crossover operation
    dut.operation.value = OP_CROSSOVER
    dut.parent1.value = parent1_bits
    dut.parent2.value = parent2_bits
    dut.crossover_seed.value = crossover_seed
    dut.operation_valid.value = 1
    dut.start.value = 1
    
    await RisingEdge(dut.clk)
    dut.start.value = 0
    dut.operation_valid.value = 0
    
    # Count cycles for completion
    cycles = 0
    while not dut.processing_done.value and cycles < 50:
        await RisingEdge(dut.clk)
        cycles += 1
    
    if cycles >= 50:
        return parent1_str, cycles  # Fallback to parent1
    
    offspring_bits = int(dut.offspring_out.value)
    offspring_str = bits_to_string(offspring_bits)
    await RisingEdge(dut.clk)
    
    return offspring_str, cycles

async def hardware_mutation(dut, chromosome_str, mutation_rate=0.1, seed=None):
    """Perform mutation using hardware"""
    
    # Convert to bits
    chromosome_bits = string_to_bits_safe(chromosome_str)
    mutation_seed = seed if seed is not None else random.randint(0, 0xFFFFFFFF)
    mutation_rate_hw = int(mutation_rate * 255)  # Convert to 0-255 range
    
    # Clear signals
    dut.start.value = 0
    dut.operation_valid.value = 0
    await RisingEdge(dut.clk)
    
    # Set mutation operation
    dut.operation.value = OP_MUTATION
    dut.chromosome_to_mutate.value = chromosome_bits
    dut.mutation_seed.value = mutation_seed
    dut.mutation_rate.value = mutation_rate_hw
    dut.operation_valid.value = 1
    dut.start.value = 1
    
    await RisingEdge(dut.clk)
    dut.start.value = 0
    dut.operation_valid.value = 0
    
    # Count cycles for completion
    cycles = 0
    while not dut.processing_done.value and cycles < 50:
        await RisingEdge(dut.clk)
        cycles += 1
    
    if cycles >= 50:
        return chromosome_str, cycles  # Fallback to original
    
    mutated_bits = int(dut.mutated_out.value)
    mutated_str = bits_to_string(mutated_bits)
    await RisingEdge(dut.clk)
    
    return mutated_str, cycles

@cocotb.test()
async def test_performance_comparison(dut):
    """Compare hardware vs software performance - MAIN BENCHMARKING TEST"""
    
    # Setup hardware
    clock = Clock(dut.clk, 10, units="ns")  # 100MHz
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    for _ in range(10):
        await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    for _ in range(10):
        await RisingEdge(dut.clk)
    
    print("\n" + "="*60)
    print("# HARDWARE vs SOFTWARE PERFORMANCE COMPARISON")
    print("="*60)
    
    # Test data
    test_chromosome = "I love GeeksforGeeks"
    target = "I love GeeksforGeeks"
    test_chromosome_diff = "X love GeeksforGeeks" 
    parent1 = "AAAAAAAAAAAAAAAAAAA"
    parent2 = "BBBBBBBBBBBBBBBBBBB"
    
    # Use same seed for fair comparison
    test_seed = 12345
    
    print(f"# Clock Frequency: 100 MHz (10 ns period)")
    print(f"# Test Target: '{target}'")
    print("")
    
    # 1. FITNESS CALCULATION COMPARISON
    print("# 1. FITNESS CALCULATION PERFORMANCE")
    print("-" * 40)
    
    # Software timing - perfect match
    sw_fitness, sw_time = software_fitness(test_chromosome, target)
    print(f"# Software (perfect): {sw_fitness} mismatches in {sw_time*1e6:.3f} ?s")
    
    # Hardware timing - perfect match
    hw_fitness, hw_cycles = await hardware_fitness(dut, test_chromosome, target)
    hw_time = hw_cycles * 10e-9  # 10ns per cycle
    print(f"# Hardware (perfect): {hw_fitness} mismatches in {hw_cycles} cycles ({hw_time*1e6:.3f} ?s)")
    
    if sw_time > 0:
        speedup = sw_time / hw_time
        print(f"# Fitness Speedup: {speedup:.1f}x")
    
    # Software timing - single difference
    sw_fitness_diff, sw_time_diff = software_fitness(test_chromosome_diff, target)
    print(f"# Software (1 diff): {sw_fitness_diff} mismatches in {sw_time_diff*1e6:.3f} ?s")
    
    # Hardware timing - single difference
    hw_fitness_diff, hw_cycles_diff = await hardware_fitness(dut, test_chromosome_diff, target)
    hw_time_diff = hw_cycles_diff * 10e-9
    print(f"# Hardware (1 diff): {hw_fitness_diff} mismatches in {hw_cycles_diff} cycles ({hw_time_diff*1e6:.3f} ?s)")
    
    print("")
    
    # 2. CROSSOVER OPERATION COMPARISON
    print("# 2. CROSSOVER OPERATION PERFORMANCE")
    print("-" * 40)
    
    # Software timing
    sw_offspring, sw_time = software_crossover(parent1, parent2, seed=test_seed)
    print(f"# Software crossover: {sw_time*1e6:.3f} ?s")
    print(f"# Software result: '{sw_offspring}'")
    
    # Hardware timing  
    hw_offspring, hw_cycles = await hardware_crossover(dut, parent1, parent2, seed=test_seed)
    hw_time = hw_cycles * 10e-9
    print(f"# Hardware crossover: {hw_cycles} cycles ({hw_time*1e6:.3f} ?s)")
    print(f"# Hardware result: '{hw_offspring}'")
    
    if sw_time > 0:
        speedup = sw_time / hw_time
        print(f"# Crossover Speedup: {speedup:.1f}x")
    
    # Verify both contain mix of A's and B's
    sw_has_a, sw_has_b = 'A' in sw_offspring, 'B' in sw_offspring
    hw_has_a, hw_has_b = 'A' in hw_offspring, 'B' in hw_offspring
    print(f"# SW A/B content: {sw_has_a}/{sw_has_b}, HW A/B content: {hw_has_a}/{hw_has_b}")
    
    print("")
    
    # 3. MUTATION OPERATION COMPARISON
    print("# 3. MUTATION OPERATION PERFORMANCE")
    print("-" * 40)
    
    test_string = "I love GeeksforGeeks"
    mutation_rate = 0.3  # Higher rate for visible differences
    
    # Software timing
    sw_mutated, sw_time = software_mutation(test_string, mutation_rate, seed=test_seed)
    print(f"# Software mutation: {sw_time*1e6:.3f} ?s")
    print(f"# Software result: '{sw_mutated}'")
    
    # Hardware timing
    hw_mutated, hw_cycles = await hardware_mutation(dut, test_string, mutation_rate, seed=test_seed)
    hw_time = hw_cycles * 10e-9
    print(f"# Hardware mutation: {hw_cycles} cycles ({hw_time*1e6:.3f} ?s)")
    print(f"# Hardware result: '{hw_mutated}'")
    
    if sw_time > 0:
        speedup = sw_time / hw_time
        print(f"# Mutation Speedup: {speedup:.1f}x")
    
    # Count differences
    sw_differences = sum(1 for a, b in zip(test_string, sw_mutated) if a != b)
    hw_differences = sum(1 for a, b in zip(test_string, hw_mutated) if a != b)
    print(f"# SW differences: {sw_differences}, HW differences: {hw_differences}")
    
    print("")
    
    # 4. FULL GENERATION COMPARISON
    print("# 4. COMPLETE GA GENERATION PERFORMANCE")
    print("-" * 40)
    
    # Initialize test population
    small_pop_size = 10  # Smaller for faster testing
    test_population = []
    for _ in range(small_pop_size):
        gnome = Individual.create_gnome()
        individual = Individual(gnome)
        test_population.append(individual)
    
    # Software full generation
    print("# Running software generation...")
    sw_population, sw_gen_time = software_ga_generation(test_population.copy(), small_pop_size)
    print(f"# Software generation: {sw_gen_time*1e3:.3f} ms")
    
    # Hardware full generation  
    print("# Running hardware generation...")
    start_time = time.perf_counter()
    
    # Calculate initial fitness with hardware
    for individual in test_population:
        chromosome_str = "".join(individual.chromosome)
        individual.fitness, _ = await hardware_fitness(dut, chromosome_str, TARGET)
    
    # Sort population by fitness
    test_population = sorted(test_population, key=lambda x: x.fitness)
    
    # Create new generation using hardware
    new_population = []
    elite_count = max(1, int(0.1 * small_pop_size))
    new_population.extend(test_population[:elite_count])
    
    total_hw_cycles = 0
    
    # Generate offspring using hardware
    while len(new_population) < small_pop_size:
        # Select parents
        parent1 = random.choice(test_population[:max(1, int(0.3 * small_pop_size))])
        parent2 = random.choice(test_population[:max(1, int(0.3 * small_pop_size))])
        
        parent1_str = "".join(parent1.chromosome)
        parent2_str = "".join(parent2.chromosome)
        
        # Hardware crossover
        offspring_str, cross_cycles = await hardware_crossover(dut, parent1_str, parent2_str)
        total_hw_cycles += cross_cycles
        
        # Hardware mutation  
        mutated_str, mut_cycles = await hardware_mutation(dut, offspring_str, mutation_rate=0.1)
        total_hw_cycles += mut_cycles
        
        # Create new individual
        offspring_chromosome = list(mutated_str)
        offspring = Individual(offspring_chromosome)
        
        # Hardware fitness calculation
        offspring.fitness, fit_cycles = await hardware_fitness(dut, mutated_str, TARGET)
        total_hw_cycles += fit_cycles
        
        new_population.append(offspring)
    
    end_time = time.perf_counter()
    hw_gen_time = end_time - start_time
    
    print(f"# Hardware generation: {hw_gen_time*1e3:.3f} ms ({total_hw_cycles} total cycles)")
    
    if sw_gen_time > 0:
        gen_speedup = sw_gen_time / hw_gen_time
        print(f"# Generation Speedup: {gen_speedup:.1f}x")
    
    print("")
    
    # 5. SUMMARY
    print("# PERFORMANCE SUMMARY")
    print("="*60)
    print("# Operation      | HW Cycles | HW Time (?s) | SW Time (?s) | Speedup")
    print("# " + "-"*58)
    
    # Calculate averages for summary
    fit_sw_avg = (sw_time + sw_time_diff) / 2 * 1e6
    fit_hw_avg = ((hw_cycles + hw_cycles_diff) / 2) * 0.01  # 10ns = 0.01?s
    fit_speedup = fit_sw_avg / fit_hw_avg if fit_hw_avg > 0 else 0
    
    cross_sw_time = sw_time * 1e6 if sw_time > 0 else 0
    cross_hw_time = hw_cycles * 0.01
    cross_speedup = cross_sw_time / cross_hw_time if cross_hw_time > 0 else 0
    
    mut_sw_time = sw_time * 1e6 if sw_time > 0 else 0  
    mut_hw_time = hw_cycles * 0.01
    mut_speedup = mut_sw_time / mut_hw_time if mut_hw_time > 0 else 0
    
    print(f"# Fitness        | {(hw_cycles + hw_cycles_diff)//2:>8} | {fit_hw_avg:>10.3f} | {fit_sw_avg:>10.3f} | {fit_speedup:>6.1f}x")
    print(f"# Crossover      | {hw_cycles:>8} | {cross_hw_time:>10.3f} | {cross_sw_time:>10.3f} | {cross_speedup:>6.1f}x")
    print(f"# Mutation       | {hw_cycles:>8} | {mut_hw_time:>10.3f} | {mut_sw_time:>10.3f} | {mut_speedup:>6.1f}x")
    
    overall_speedup = sw_gen_time / hw_gen_time if hw_gen_time > 0 else 0
    print(f"# Full Gen       | {total_hw_cycles:>8} | {hw_gen_time*1e6:>10.3f} | {sw_gen_time*1e6:>10.3f} | {overall_speedup:>6.1f}x")
    
    print("="*60)

@cocotb.test()
async def test_enhanced_ga_hardware(dut):
    """GA with hardware acceleration for fitness, crossover, and mutation"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    for _ in range(10):
        await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    for _ in range(10):
        await RisingEdge(dut.clk)
    
    print("# Enhanced GA with Hardware Acceleration")
    print("# Hardware Operations: Fitness + Crossover + Mutation")
    print("# Population Size: {}".format(POPULATION_SIZE))
    print("# Target: '{}'".format(TARGET))
    print("")
    
    # Initialize population
    population = []
    for _ in range(POPULATION_SIZE):
        gnome = Individual.create_gnome()
        individual = Individual(gnome)
        population.append(individual)
    
    print("# Hardware accelerating initial fitness calculations...")
    
    # Calculate initial fitness with hardware
    for individual in population:
        chromosome_str = "".join(individual.chromosome)
        individual.fitness, _ = await hardware_fitness(dut, chromosome_str, TARGET)
    
    generation = 1
    found = False
    max_generations = 100
    hardware_operations = 0
    total_hw_cycles = 0
    
    while not found and generation <= max_generations:
        
        # Sort population by fitness
        population = sorted(population, key=lambda x: x.fitness)
        
        # Check for solution
        if population[0].fitness <= 0:
            found = True
            break
        
        # Print generation info
        best_str = "".join(population[0].chromosome)
        print("Generation: {}\tString: {}\tFitness: {}".format(
            generation, best_str, population[0].fitness))
        
        # Create new generation using hardware
        new_population = []
        
        # Elitism - keep best 10%
        elite_count = max(2, int(0.1 * POPULATION_SIZE))
        new_population.extend(population[:elite_count])
        
        # Generate offspring using hardware crossover and mutation
        while len(new_population) < POPULATION_SIZE:
            # Select parents
            parent1 = random.choice(population[:int(0.3 * POPULATION_SIZE)])
            parent2 = random.choice(population[:int(0.3 * POPULATION_SIZE)])
            
            parent1_str = "".join(parent1.chromosome)
            parent2_str = "".join(parent2.chromosome)
            
            # Hardware crossover
            offspring_str, cross_cycles = await hardware_crossover(dut, parent1_str, parent2_str)
            hardware_operations += 1
            total_hw_cycles += cross_cycles
            
            # Hardware mutation  
            mutated_str, mut_cycles = await hardware_mutation(dut, offspring_str, mutation_rate=0.1)
            hardware_operations += 1
            total_hw_cycles += mut_cycles
            
            # Create new individual
            offspring_chromosome = list(mutated_str)
            offspring = Individual(offspring_chromosome)
            
            # Hardware fitness calculation
            offspring.fitness, fit_cycles = await hardware_fitness(dut, mutated_str, TARGET)
            hardware_operations += 1
            total_hw_cycles += fit_cycles
            
            new_population.append(offspring)
        
        population = new_population
        generation += 1
    
    # Final result
    population = sorted(population, key=lambda x: x.fitness)
    final_str = "".join(population[0].chromosome)
    
    print("Generation: {}\tString: {}\tFitness: {}".format(
        generation, final_str, population[0].fitness))
    print("")
    
    if found:
        print("# SUCCESS: Perfect solution found!")
    else:
        print("# COMPLETED: {} generations".format(generation - 1))
    
    print("# Target:  '{}'".format(TARGET))
    print("# Result:  '{}'".format(final_str))
    print("# Final Fitness: {}".format(population[0].fitness))
    print("# Total Hardware Operations: {}".format(hardware_operations))
    print("# Total Hardware Cycles: {}".format(total_hw_cycles))
    print("# Operations per Generation: {:.1f}".format(hardware_operations / generation))
    print("# Average Cycles per Operation: {:.1f}".format(total_hw_cycles / hardware_operations if hardware_operations > 0 else 0))
    print("# Hardware Accelerated: Fitness + Crossover + Mutation")

@cocotb.test()
async def test_hardware_operations(dut):
    """Test individual hardware operations"""
    
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    for _ in range(10):
        await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    for _ in range(10):
        await RisingEdge(dut.clk)
    
    print("\n# Testing Enhanced Hardware Operations")
    print("# =====================================")
    
    # Test fitness
    print("# Testing Hardware Fitness:")
    fitness, cycles = await hardware_fitness(dut, TARGET, TARGET)
    print("#   Perfect match: {} (expected: 0) in {} cycles".format(fitness, cycles))
    
    fitness, cycles = await hardware_fitness(dut, "X love GeeksforGeeks", TARGET)
    print("#   Single difference: {} (expected: 1) in {} cycles".format(fitness, cycles))
    
    # Test crossover
    print("# Testing Hardware Crossover:")
    parent1 = "AAAAAAAAAAAAAAAAAAA"
    parent2 = "BBBBBBBBBBBBBBBBBBB"
    offspring, cycles = await hardware_crossover(dut, parent1, parent2)
    print("#   Parent1: '{}'".format(parent1))
    print("#   Parent2: '{}'".format(parent2))
    print("#   Offspring: '{}' in {} cycles".format(offspring, cycles))
    
    # Verify offspring contains mix of A's and B's
    has_a = 'A' in offspring
    has_b = 'B' in offspring
    print("#   Contains A: {}, Contains B: {} (Should be True, True)".format(has_a, has_b))
    
    # Test mutation
    print("# Testing Hardware Mutation:")
    original = "I love GeeksforGeeks"
    mutated, cycles = await hardware_mutation(dut, original, mutation_rate=0.5)  # High rate for testing
    print("#   Original: '{}'".format(original))
    print("#   Mutated:  '{}' in {} cycles".format(mutated, cycles))
    
    # Count differences
    differences = sum(1 for a, b in zip(original, mutated) if a != b)
    print("#   Differences: {} (Should be > 0 with 50% mutation rate)".format(differences))
    
    print("# Enhanced hardware operations test complete!")
