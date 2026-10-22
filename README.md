# YAPP Router UVM Verification

This repository contains a SystemVerilog YAPP packet router and a UVM verification environment. The integrated testbench connects the router to a packet source, three packet receivers, an HBUS configuration master, and a clock/reset agent. A reference model predicts which packets should be forwarded, and a scoreboard compares those predictions with the packets observed at the router outputs.

## Contents

| Path | Purpose |
| --- | --- |
| `router_rtl/` | Router RTL (`yapp_router.sv`) |
| `yapp/sv/` | YAPP packet type, transmit agent, monitor, sequencer, and traffic sequences |
| `channel/sv/` | Channel receiver UVC: packet/response types, receiver agent, driver, monitor, and sequences |
| `hbus/sv/` | HBUS transaction types, master and slave agents, monitor, sequences, and register adapter |
| `clock_and_reset/sv/` | Clock/reset interface, agent, driver, and sequences |
| `sv/` | Integrated router reference model, scoreboard, and module-level UVM environment |
| `tb/` | Integrated testbench top, test library, multi-channel sequences, and simulator file list |
| `channel/tb/` | Channel UVC demonstration testbench and file list |
| `hbus/tb/` | HBUS UVC demonstration testbench and file list |
| `clock_and_reset/tb/` | Clock/reset UVC demonstration testbench and file list |

The standalone UVCs are reusable verification components; the integrated environment in `tb/` composes them to exercise the router RTL.

## Verification environment

The integrated hierarchy is assembled in `router_tb`:

- **YAPP transmitter** drives packets into the router.
- **Three channel receiver agents** consume output traffic on channels 0, 1, and 2. Their response sequence controls when each channel accepts data, allowing receiver backpressure.
- **HBUS master** configures the router through the host bus.
- **Clock/reset agent** starts the clock and applies reset.
- **Reference model** receives YAPP packet observations and HBUS writes, updates its modeled settings, and publishes expected forwarded packets.
- **Scoreboard** queues expected packets by destination and compares each channel's observed packet against the corresponding expected packet. It checks address, length, payload, and parity and reports mismatches or unexpected channel traffic.

The testbench top-level modules and interfaces are connected in `tb/hw_top.sv`; UVM virtual interfaces are configured and `run_test()` is called from `tb/tb_top.sv`.

## Requirements

- Cadence Xcelium (`xrun`) with SystemVerilog and UVM support. Another simulator may work if it supports the constructs and UVM version used by the source.
- A UVM installation available to the simulator. The file lists use `$UVMHOME` with the simulator's `-uvmhome` option; configure `UVMHOME` to the installation path expected by your Xcelium setup.

For example, in PowerShell:

```powershell
$env:UVMHOME = "C:\path\to\uvm"
```

Or in a POSIX shell:

```sh
export UVMHOME=/path/to/uvm
```

Use the path and UVM library layout appropriate for your simulator installation.

## Run the integrated router test

The integrated simulator file list is `tb/run.f`. It selects `router_mcseq_test` and `UVM_VERBOSITY=UVM_HIGH` by default. Run it with Xcelium:

```sh
cd tb
xrun -f run.f
```

The source entries in `tb/run.f` refer to sibling directories. Note that its include-directory entries for the clock/reset, HBUS, and channel packages currently use `../../...`, while their source entries use `../...`. When running from the repository's `tb/` directory, those three include-directory paths point outside the repository; change them to `../clock_and_reset/sv`, `../hbus/sv`, and `../channel/sv` if your simulator reports the include directories missing.

The default test runs `router_simple_mcseq`, which coordinates traffic on the YAPP and HBUS sequencers:

1. Set the maximum packet length to 20 bytes and enable the router.
2. Read the maximum-length setting.
3. Send traffic addressed to channels 0, 1, and 2 twice.
4. Restore the maximum packet length to 63 bytes and read it back.
5. Run 50 randomized six-packet YAPP sequences while the channel receivers respond to output traffic.

At the end of simulation, UVM prints the component topology, the scoreboard packet comparison counts, and reference-model drop statistics. A run should be investigated if it reports UVM errors, packet mismatches, unexpected channel packets, or expected packets left queued.

### Select a different test

The test classes are in `tb/router_test_lib.sv`:

- `base_test` builds the environment and prints its topology.
- `simple_test` configures default sequences for basic traffic and uses short YAPP packets.
- `router_mcseq_test` is the default coordinated multi-sequencer test.

To run a different test, change the `+UVM_TESTNAME=...` setting in `tb/run.f` to the desired registered test name. `tb/run.f` also controls verbosity, seed selection, coverage options, and the source file list.

## Run the standalone UVC demos

Each UVC demonstration has its own `run.f` and demo top. From the corresponding testbench directory, run:

```sh
cd channel/tb
xrun -f run.f
```

The same pattern applies to `hbus/tb` and `clock_and_reset/tb`:

```sh
cd hbus/tb
xrun -f run.f

cd clock_and_reset/tb
xrun -f run.f
```

These demos exercise an individual UVC; they do not instantiate the integrated router testbench. Each file list selects its demo test by default. Review or edit that directory's `run.f` to select another test or change simulator options.

## YAPP router behavior modeled in this testbench

The reference model starts with the router enabled and a maximum packet length of 63 bytes. It observes HBUS writes to the following settings:

| HBUS address | Write data | Modeled effect |
| --- | --- | --- |
| `0x1000` | `hdata[5:0]` | Set maximum accepted packet length |
| `0x1001` | `hdata[0]` | Enable (`1`) or disable (`0`) the router |

Packets addressed to `0`, `1`, or `2` are expected on the matching output channel when the router is enabled and the packet length does not exceed the modeled limit. The reference model counts packets dropped because the router is disabled, the packet is too long, or the destination address is illegal (`3`).

The reference model is a testbench prediction model, not a complete model of every register or feature implemented in the RTL. The integrated scoreboard focuses on forwarded-packet content; consult the source and test sequences before assuming that a particular RTL feature or error case is covered.

## Useful source files

- `tb/run.f` — integrated simulator options, test selection, and compilation list.
- `tb/router_tb.sv` — builds and connects the integrated agents and verification environment.
- `tb/router_test_lib.sv` — integrated UVM tests and default-sequence configuration.
- `tb/router_mcseqs_lib.sv` — coordinated YAPP/HBUS traffic sequence.
- `sv/router_reference.sv` — modeled router settings and packet-drop decisions.
- `sv/router_scoreboard.sv` — expected-packet queues and packet comparisons.
- `router_rtl/yapp_router.sv` — router RTL.
