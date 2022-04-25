
# Timing Specification Constraints

create_clock -name clk -period 10.172526ns -waveform {0.0ns 5.086263ns} [get_ports {clk}]
derive_pll_clocks
derive_clock_uncertainty
