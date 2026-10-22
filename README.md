# YAPP Router UVM Verification

This project contains a SystemVerilog implementation of a YAPP packet router and a UVM testbench for verifying packet routing, output backpressure, and HBUS configuration.

## Contents

| Path | Description |
| --- | --- |
| `router_rtl/` | YAPP router RTL |
| `yapp/sv/` | YAPP packet, transmitter agent, monitor, and sequences |
| `channel/` | Channel receiver UVC and its demo testbench |
| `hbus/` | HBUS master/slave UVCs and demo testbench |
| `clock_and_reset/` | Clock/reset UVC and demo testbench |
| `sv/` | Router reference model, scoreboard, and UVM environment |
| `tb/` | Integrated router testbench, tests, and simulator file list |

The integrated environment connects a YAPP transmitter, three channel receiver agents, an HBUS master, and a clock/reset agent to the RTL. The reference model applies router configuration writes and predicts forwarded packets; the scoreboard compares those packets with channel monitor output.

## Requirements

- Cadence Xcelium (`xrun`) or a compatible SystemVerilog simulator with UVM support
- UVM library installation, with `UVMHOME` set to the location expected by the simulator's `-uvmhome` option

## Run the integrated testbench

Run from the `tb` directory so paths in `run.f` resolve correctly:

```sh
cd tb
xrun -f run.f
```

The file list selects `router_mcseq_test` by default. It runs the integrated multi-channel sequence and prints UVM topology and scoreboard/reference-model reports. To choose another test, change the `UVM_TESTNAME` setting in `tb/run.f` to a test defined in `tb/router_test_lib.sv`.

## Run a UVC demo

Each standalone UVC demo has its own `run.f`. From the corresponding testbench directory:

```sh
cd channel/tb
xrun -f run.f
```

Equivalent commands are available from `hbus/tb` and `clock_and_reset/tb`. Set `UVMHOME` in your shell before invoking the simulator if it is not already configured.

## Router configuration modeled by the testbench

The reference model observes HBUS writes to:

| Address | Effect |
| --- | --- |
| `0x1000` | Set the maximum accepted packet length from `hdata[5:0]` |
| `0x1001` | Set router enable from `hdata[0]` |

Packets are routed by address `0`, `1`, or `2`; disabled-router, oversized, and illegal-address packets are counted as drops by the reference model.


