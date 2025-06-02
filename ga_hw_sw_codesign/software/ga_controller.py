#!/usr/bin/env python3
"""
Improved Genetic Algorithm Hardware-Software Co-Design
Shows realistic convergence to target string
"""

import time
import random
import struct
import os
from typing import List, Tuple
import numpy as np


class GACoprocessorDriver:
    """Hardware Abstraction Layer for GA Co-processor"""
    
    # Register addresses
    CTRL_REG_ADDR = 0x000
    STATUS_REG_ADDR = 0x004
    CONFIG_REG_ADDR = 0x008
    TARGET_REG_ADDR = 0x00C
    RESULT_REG_ADDR = 0x010
    
    # Control register bits
    CTRL_START_BIT = 0x01
    CTRL_RESET_BIT = 0x02
    
    # Status register bits
    STATUS_BUSY_BIT = 0x01
    STATUS_DONE_BIT = 0x02
    
    def __init__(self, simulation_mode=True):
        self.simulation_mode = simulation_mode
        self.population_size = 100
        self.chromosome_length = 19
        self.target = "I love GeeksforGeeks"
        
        # Simulation state for realistic hardware modeling
        self.sim_generation = 0
        self.sim_best_fitness = 19  # Start with worst possible fitness
        self.sim_population = []
        
        print(f"GA Coprocessor Driver initialized (simulation_mode={simulation_mode})")
    
    def configure_parameters(self, mutation_rate: float, crossover_rate: float, 
                           elite_percentage: float):
        """Configure GA parameters"""
        self.mutation_rate = mutation_rate
        self.crossover_rate = crossover_rate
        self.elite_percentage = elite_percentage
        
        mut_rate_int = int(mutation_rate * 255)
        cross_rate_int = int(crossover_rate * 255)
        elite_pct_int = int(elite_percentage * 255)
        
        config_value = (elite_pct_int << 16) | (cross_rate_int << 8) | mut_rate_int
        
        if self.simulation_mode:
            print(f"SIM: Configure params - mut={mutation_rate:.3f}, cross={crossover_rate:.3f}, elite={elite_percentage:.3f}")
        else:
            # Real hardware write would go here
            pass
    
    def set_target_string(self, target: str):
        """Set target string"""
        self.target = target
        self.chromosome_length = len(target)
        print(f"Set target: '{target}'")
    
    def write_population(self, population: List[str]):
        """Write population to hardware"""
        self.sim_population = population.copy()
        print(f"Loaded {len(population)} individuals")
    
    def start_processing(self):
        """Start GA processing"""
        print("Started hardware GA processing")
    
    def wait_for_completion(self, timeout: float = 5.0) -> bool:
        """Wait for processing completion - simulate realistic GA evolution"""
        if self.simulation_mode:
            # Simulate one generation of evolution
            self._simulate_hardware_generation()
            time.sleep(0.1)  # Simulate processing time
            print("Processing completed")
            return True
        return False
    
    def _simulate_hardware_generation(self):
        """Simulate realistic hardware genetic algorithm processing"""
        # Calculate fitness for current population
        fitness_scores = []
        for individual in self.sim_population:
            fitness = sum(1 for c1, c2 in zip(individual, self.target) if c1 != c2)
            fitness_scores.append((individual, fitness))
        
        # Sort by fitness (lower is better)
        fitness_scores.sort(key=lambda x: x[1])
        
        # Update best fitness
        self.sim_best_fitness = fitness_scores[0][1]
        
        # If we've reached the target, no need to evolve further
        if self.sim_best_fitness == 0:
            return
        
        # Create new generation
        new_population = []
        
        # Elitism - keep best individuals
        elite_count = int(self.elite_percentage * self.population_size)
        for i in range(elite_count):
            new_population.append(fitness_scores[i][0])
        
        # Generate rest through crossover and mutation
        genes = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ 1234567890'
        
        while len(new_population) < self.population_size:
            # Tournament selection
            parent1 = self._tournament_selection(fitness_scores)
            parent2 = self._tournament_selection(fitness_scores)
            
            # Crossover
            if random.random() < self.crossover_rate:
                child1, child2 = self._crossover(parent1, parent2)
            else:
                child1, child2 = parent1, parent2
            
            # Mutation
            child1 = self._mutate(child1, genes)
            child2 = self._mutate(child2, genes)
            
            new_population.extend([child1, child2])
        
        # Trim to exact population size
        self.sim_population = new_population[:self.population_size]
    
    def _tournament_selection(self, fitness_scores, tournament_size=3):
        """Tournament selection"""
        tournament = random.sample(fitness_scores, min(tournament_size, len(fitness_scores)))
        return min(tournament, key=lambda x: x[1])[0]
    
    def _crossover(self, parent1: str, parent2: str) -> Tuple[str, str]:
        """Single-point crossover"""
        if len(parent1) != len(parent2):
            return parent1, parent2
        
        crossover_point = random.randint(1, len(parent1) - 1)
        child1 = parent1[:crossover_point] + parent2[crossover_point:]
        child2 = parent2[:crossover_point] + parent1[crossover_point:]
        
        return child1, child2
    
    def _mutate(self, individual: str, genes: str) -> str:
        """Apply mutation"""
        mutated = list(individual)
        for i in range(len(mutated)):
            if random.random() < self.mutation_rate:
                mutated[i] = random.choice(genes)
        return ''.join(mutated)
    
    def get_best_fitness(self) -> int:
        """Get best fitness result"""
        return self.sim_best_fitness
    
    def read_population(self) -> List[str]:
        """Read processed population"""
        return self.sim_population.copy()


class Individual:
    """Individual in GA population"""
    
    def __init__(self, chromosome: str):
        self.chromosome = chromosome
        self.fitness = self.calculate_fitness()
    
    def calculate_fitness(self, target: str = "I love GeeksforGeeks") -> int:
        """Calculate fitness (number of mismatched characters)"""
        if len(self.chromosome) != len(target):
            return len(target)
        
        mismatches = sum(1 for c1, c2 in zip(self.chromosome, target) if c1 != c2)
        return mismatches
    
    def mutate(self, mutation_rate: float):
        """Apply mutation to the chromosome"""
        genes = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ 1234567890'
        
        mutated = list(self.chromosome)
        for i in range(len(mutated)):
            if random.random() < mutation_rate:
                mutated[i] = random.choice(genes)
        
        self.chromosome = ''.join(mutated)
        self.fitness = self.calculate_fitness()
    
    @classmethod
    def crossover(cls, parent1: 'Individual', parent2: 'Individual') -> Tuple['Individual', 'Individual']:
        """Perform crossover between two parents"""
        if len(parent1.chromosome) != len(parent2.chromosome):
            return parent1, parent2
        
        # Single-point crossover
        crossover_point = random.randint(1, len(parent1.chromosome) - 1)
        
        child1_chromo = parent1.chromosome[:crossover_point] + parent2.chromosome[crossover_point:]
        child2_chromo = parent2.chromosome[:crossover_point] + parent1.chromosome[crossover_point:]
        
        return cls(child1_chromo), cls(child2_chromo)
    
    @classmethod
    def create_random(cls, length: int) -> 'Individual':
        """Create a random individual"""
        genes = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ 1234567890'
        chromosome = ''.join(random.choice(genes) for _ in range(length))
        return cls(chromosome)


class HybridGeneticAlgorithm:
    """Hybrid GA using hardware acceleration"""
    
    def __init__(self, target: str = "I love GeeksforGeeks", population_size: int = 100):
        self.target = target
        self.population_size = population_size
        self.chromosome_length = len(target)
        
        # Initialize hardware driver
        self.hw_driver = GACoprocessorDriver(simulation_mode=True)
        
        # Configure parameters
        self.hw_driver.configure_parameters(
            mutation_rate=0.02,  # Slightly higher for better evolution
            crossover_rate=0.8,
            elite_percentage=0.1
        )
        self.hw_driver.set_target_string(self.target)
        
        # Initialize population
        self.population = [Individual.create_random(self.chromosome_length) 
                          for _ in range(self.population_size)]
    
    def run_software_only(self, max_generations: int = 1000) -> Tuple[Individual, int]:
        """Run GA entirely in software for comparison"""
        print("Running software-only genetic algorithm...")
        
        for gen in range(max_generations):
            # Sort population by fitness
            self.population.sort(key=lambda x: x.fitness)
            
            # Check if target reached
            if self.population[0].fitness == 0:
                print(f"✅ Target reached in generation {gen}")
                return self.population[0], gen
            
            # Print progress
            if gen % 50 == 0 or gen < 10:
                best_fitness = self.population[0].fitness
                best_individual = self.population[0].chromosome
                print(f"Gen {gen:3d}: Best fitness = {best_fitness:2d}, Individual = '{best_individual}'")
            
            # Create new generation
            new_population = []
            
            # Elitism: keep best individuals
            elite_count = int(0.1 * self.population_size)
            new_population.extend(self.population[:elite_count])
            
            # Crossover and mutation
            while len(new_population) < self.population_size:
                # Selection (tournament selection)
                parent1 = self._tournament_selection()
                parent2 = self._tournament_selection()
                
                # Crossover
                if random.random() < 0.8:
                    child1, child2 = Individual.crossover(parent1, parent2)
                else:
                    child1, child2 = parent1, parent2
                
                # Mutation
                child1.mutate(0.02)
                child2.mutate(0.02)
                
                new_population.extend([child1, child2])
            
            # Trim to population size
            self.population = new_population[:self.population_size]
        
        # Return best individual
        self.population.sort(key=lambda x: x.fitness)
        return self.population[0], max_generations
    
    def run_hardware_accelerated(self, max_generations: int = 1000) -> Tuple[str, int]:
        """Run GA with hardware acceleration showing realistic convergence"""
        print("Running hardware-accelerated genetic algorithm...")
        
        # Reset population for fair comparison
        self.population = [Individual.create_random(self.chromosome_length) 
                          for _ in range(self.population_size)]
        
        for gen in range(max_generations):
            # Convert population to strings for hardware
            population_strings = [ind.chromosome for ind in self.population]
            
            # Load population into hardware
            self.hw_driver.write_population(population_strings)
            
            # Start hardware processing
            self.hw_driver.start_processing()
            
            # Wait for completion
            if not self.hw_driver.wait_for_completion():
                print("Hardware processing timeout!")
                break
            
            # Get results from hardware
            new_population_strings = self.hw_driver.read_population()
            best_fitness = self.hw_driver.get_best_fitness()
            
            # Convert back to Individual objects
            self.population = [Individual(chromo) for chromo in new_population_strings]
            
            # Print progress every generation for first 10, then every 10
            if gen < 10 or gen % 10 == 0:
                # Find the actual best individual
                self.population.sort(key=lambda x: x.fitness)
                actual_best = self.population[0]
                print(f"Gen {gen:3d}: Best fitness = {actual_best.fitness:2d}, Individual = '{actual_best.chromosome}' (HW fitness: {best_fitness})")
            
            # Check if target reached
            if best_fitness == 0:
                print(f"🎉 Target reached in generation {gen}!")
                self.population.sort(key=lambda x: x.fitness)
                return self.population[0].chromosome, gen
        
        # Return best individual
        self.population.sort(key=lambda x: x.fitness)
        return self.population[0].chromosome, max_generations
    
    def _tournament_selection(self, tournament_size: int = 3) -> Individual:
        """Tournament selection for parent selection"""
        tournament = random.sample(self.population, min(tournament_size, len(self.population)))
        return min(tournament, key=lambda x: x.fitness)
    
    def benchmark_performance(self, num_runs: int = 3):
        """Benchmark hardware vs software performance"""
        print("\n" + "="*60)
        print("BENCHMARKING HARDWARE VS SOFTWARE PERFORMANCE")
        print("="*60)
        
        sw_times = []
        hw_times = []
        sw_generations = []
        hw_generations = []
        
        for run in range(num_runs):
            print(f"\n🔄 Run {run + 1}/{num_runs}")
            print("-" * 40)
            
            # Reset for fair comparison
            random.seed(42 + run)  # Reproducible results
            
            # Software-only run
            print("📊 Software run...")
            start_time = time.time()
            best_sw, gen_sw = self.run_software_only(max_generations=200)
            sw_time = time.time() - start_time
            sw_times.append(sw_time)
            sw_generations.append(gen_sw if gen_sw < 200 else 200)
            
            print(f"   Software: {gen_sw} generations, {sw_time:.2f}s, fitness={best_sw.fitness}")
            
            # Reset for hardware run
            random.seed(42 + run)  # Same seed for fair comparison
            
            # Hardware-accelerated run
            print("⚡ Hardware run...")
            start_time = time.time()
            best_hw, gen_hw = self.run_hardware_accelerated(max_generations=200)
            hw_time = time.time() - start_time
            hw_times.append(hw_time)
            hw_generations.append(gen_hw if gen_hw < 200 else 200)
            
            print(f"   Hardware: {gen_hw} generations, {hw_time:.2f}s")
        
        # Calculate statistics
        avg_sw_time = np.mean(sw_times)
        avg_hw_time = np.mean(hw_times)
        avg_sw_gen = np.mean(sw_generations)
        avg_hw_gen = np.mean(hw_generations)
        
        speedup = avg_sw_time / avg_hw_time if avg_hw_time > 0 else float('inf')
        
        print("\n" + "="*60)
        print("📈 BENCHMARK RESULTS")
        print("="*60)
        print(f"Software-only average time: {avg_sw_time:.2f}s")
        print(f"Hardware-accelerated average time: {avg_hw_time:.2f}s")
        print(f"⚡ Speedup: {speedup:.2f}x")
        print(f"Software average generations: {avg_sw_gen:.1f}")
        print(f"Hardware average generations: {avg_hw_gen:.1f}")
        print(f"Generation improvement: {(avg_sw_gen/avg_hw_gen):.2f}x faster convergence")
        print("="*60)
        
        return speedup, avg_sw_time, avg_hw_time


def main():
    """Main demonstration"""
    print("🧬 Genetic Algorithm Hardware-Software Co-Design Demo")
    print("="*60)
    
    # Create hybrid GA instance
    target_string = "I love GeeksforGeeks"
    ga = HybridGeneticAlgorithm(target=target_string, population_size=100)
    
    print(f"🎯 Target string: '{target_string}'")
    print(f"👥 Population size: {ga.population_size}")
    print(f"🧵 Chromosome length: {ga.chromosome_length}")
    print()
    
    # Run hardware-accelerated version with detailed output
    print("⚡ HARDWARE-ACCELERATED GENETIC ALGORITHM")
    print("=" * 50)
    start_time = time.time()
    best_result, generations = ga.run_hardware_accelerated(max_generations=100)
    runtime = time.time() - start_time
    
    print(f"\n🏆 FINAL RESULTS:")
    print(f"   Best individual: '{best_result}'")
    print(f"   Generations to convergence: {generations}")
    print(f"   Runtime: {runtime:.2f} seconds")
    print(f"   Final fitness: {Individual(best_result).fitness}")
    
    # Run performance comparison
    ga.benchmark_performance(num_runs=2)


if __name__ == "__main__":
    main()