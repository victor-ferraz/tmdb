create_clock -period 25.000 -name clk_in [get_ports {clk40M}]
derive_pll_clocks
derive_clock_uncertainty
