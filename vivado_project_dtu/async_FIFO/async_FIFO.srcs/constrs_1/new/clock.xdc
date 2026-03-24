create_clock -period 10.000 -name clk_write [get_ports wclk]
create_clock -period 25.000 -name clk_read [get_ports rclk]
set_clock_groups -asynchronous -group [get_clocks clk_write] -group [get_clocks clk_read]
