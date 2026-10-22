module hw_top;

  logic [31:0]  clock_period;
  logic         run_clock;
  logic         clock;
  logic         reset;

  wire [7:0]    hdata_w;

  yapp_if in0(clock, reset);

  clock_and_reset_if  clock_and_reset(clock, reset, run_clock, clock_period);

  hbus_if  hbus_in(clock, reset);

  channel_if channel0(clock, reset);
  channel_if channel1(clock, reset);
  channel_if channel2(clock, reset);

  clkgen clkgen (
    .clock(clock),
    .run_clock(run_clock),
    .clock_period(clock_period)
  );

  yapp_router dut(
    .reset(reset),
    .clock(clock),
    .error(),

    .in_data(in0.in_data),
    .in_data_vld(in0.in_data_vld),
    .in_suspend(in0.in_suspend),


    .data_0(channel0.data),
    .data_vld_0(channel0.data_vld),
    .suspend_0(channel0.suspend),

    .data_1(channel1.data),
    .data_vld_1(channel1.data_vld),
    .suspend_1(channel1.suspend),
    // Channel 2
    .data_2(channel2.data),
    .data_vld_2(channel2.data_vld),
    .suspend_2(channel2.suspend),

    .haddr(hbus_in.haddr),
    .hdata(hdata_w),
    .hen(hbus_in.hen),
    .hwr_rd(hbus_in.hwr_rd));

  assign hdata_w = hbus_in.hwr_rd ? hbus_in.hdata : 8'bz;

endmodule