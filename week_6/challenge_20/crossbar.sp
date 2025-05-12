* 4x4 Resistive Crossbar Netlist (NGSpice)
* Each row (word line) is driven at 1.2 V, each column (bit line) is grounded for current output.

* Voltage sources for word lines (rows) at +1.2 V
V1 w1 0 DC 1.2    * Word line 1
V2 w2 0 DC 1.2    * Word line 2
V3 w3 0 DC 1.2    * Word line 3
V4 w4 0 DC 1.2    * Word line 4

* Resistive memristors at each cross-point (1 M? = 1 µS)
R11 w1 b1 1MEG
R12 w1 b2 1MEG
R13 w1 b3 1MEG
R14 w1 b4 1MEG
R21 w2 b1 1MEG
R22 w2 b2 1MEG
R23 w2 b3 1MEG
R24 w2 b4 1MEG
R31 w3 b1 1MEG
R32 w3 b2 1MEG
R33 w3 b3 1MEG
R34 w3 b4 1MEG
R41 w4 b1 1MEG
R42 w4 b2 1MEG
R43 w4 b3 1MEG
R44 w4 b4 1MEG

* 0 V sources at bit lines to ground: measure column currents
Vb1 b1 0 DC 0    * Bit line 1 to ground
Vb2 b2 0 DC 0    * Bit line 2 to ground
Vb3 b3 0 DC 0    * Bit line 3 to ground
Vb4 b4 0 DC 0    * Bit line 4 to ground

* DC operating point and current printout
.op
.print DC I(Vb1) I(Vb2) I(Vb3) I(Vb4)

.end

