# CNN Simple Accelerator on RISC-V SoC

![Language](https://img.shields.io/badge/Language-Verilog-blue)
![Firmware](https://img.shields.io/badge/Firmware-C-green)
![CPU](https://img.shields.io/badge/CPU-RISC--V-orange)
![Status](https://img.shields.io/badge/Status-Learning_Project-yellow)

## 1. Project Overview

`cnn_simple_vanthuc_24161421` is a simple RISC-V SoC project that integrates a custom CNN accelerator written in Verilog.

The main purpose of this project is to demonstrate how a RISC-V CPU can communicate with a hardware accelerator through memory-mapped registers. In this design, the CPU is responsible for controlling the system, while the CNN accelerator performs a simple convolution operation.

This project is designed for learning and experimentation with:

- RISC-V SoC design
- Verilog hardware design
- Wishbone bus communication
- Memory-mapped I/O
- Firmware development in C
- Hardware/software co-design
- Basic CNN acceleration using custom hardware

---

## 2. What is CNN?

CNN stands for **Convolutional Neural Network**.

A CNN is a type of deep learning model commonly used in image processing, object recognition, classification, face detection, and many other artificial intelligence applications.

The core operation of a CNN is called **convolution**. In convolution, a small matrix called a **kernel** or **filter** slides over an input matrix and performs multiply-and-accumulate operations.

For example, an input matrix may look like this:

```text
1 2 3 4 5
1 2 3 4 5
1 2 3 4 5
1 2 3 4 5
1 2 3 4 5
```

A simple 3x3 kernel may look like this:

```text
1 0 1
0 1 0
1 0 1
```

The CNN accelerator takes each 3x3 region of the input, multiplies it with the kernel, and sums the results to generate one output value.

In this project, the CNN model is simplified so that the hardware behavior is easy to understand, simulate, and debug.

---

## 3. Project Objectives

The main objectives of this project are:

1. Design a simple CNN accelerator in Verilog.
2. Connect the CNN accelerator to a RISC-V SoC.
3. Use a Wishbone-based bus interface for communication.
4. Write C firmware to control the accelerator.
5. Load input data and kernel data from software.
6. Start the CNN computation from firmware.
7. Read the output results back to the CPU.
8. Observe and verify the data flow through simulation.

---

## 4. System Architecture

The system contains the following main components:

```text
+------------------+
|    Firmware C    |
|  running on CPU  |
+--------+---------+
         |
         v
+------------------+
|   RISC-V CPU     |
|    VexRiscv      |
+--------+---------+
         |
         v
+------------------+
|   Wishbone Bus   |
+--------+---------+
         |
         +----------------------+
         |                      |
         v                      v
+------------------+    +------------------+
|       RAM        |    | CNN Accelerator  |
| Instruction/Data |    |  Verilog Module  |
+------------------+    +------------------+
```

The RISC-V CPU does not directly compute the CNN operation. Instead, it controls the accelerator by writing and reading memory-mapped registers.

The CPU performs these tasks:

- Write input data to the CNN accelerator
- Write kernel data to the CNN accelerator
- Send the start signal
- Wait for the accelerator to finish
- Read the output data back

The CNN accelerator performs the actual convolution computation in hardware.

---

## 5. Repository Structure

```text
cnn_simple_vanthuc_24161421/
│
├── firmware/
│   └── main.c
│
├── model/
│   └── ...
│
├── rtl/
│   └── cnn_core.v
│   └── wb_cnn_mini.v
│   └── wb_decoder.v
│   └── wb_ram_dp.v
│
├── scripts/
│   └── ...
│
├── sim/
│   └── sim.py
│
├── tb/
│   └── ...
│
├── third_party/
│   └── vexriscv/
│
├── Makefile
├── README.md
└── .gitignore
```

Folder description:

| Folder | Description |
|---|---|
| `firmware/` | C firmware running on the RISC-V CPU |
| `rtl/` | Verilog RTL source files |
| `sim/` | Simulation files |
| `tb/` | Testbench files |
| `model/` | Reference models or test data |
| `scripts/` | Build or helper scripts |
| `third_party/vexriscv/` | VexRiscv CPU or external dependencies |
| `Makefile` | Build and simulation automation |

---

## 6. Memory Map

The CNN accelerator is mapped to the following base address:

```c
#define CNN_BASE 0x40000000
```

CNN register definitions:

```c
#define CNN_CTRL          (*(volatile unsigned int *)(CNN_BASE + 0x00))
#define CNN_STATUS        (*(volatile unsigned int *)(CNN_BASE + 0x04))
#define CNN_INPUT_INDEX   (*(volatile unsigned int *)(CNN_BASE + 0x08))
#define CNN_INPUT_DATA    (*(volatile unsigned int *)(CNN_BASE + 0x0C))
#define CNN_KERNEL_INDEX  (*(volatile unsigned int *)(CNN_BASE + 0x10))
#define CNN_KERNEL_DATA   (*(volatile unsigned int *)(CNN_BASE + 0x14))
#define CNN_OUTPUT_INDEX  (*(volatile unsigned int *)(CNN_BASE + 0x18))
#define CNN_OUTPUT_DATA   (*(volatile unsigned int *)(CNN_BASE + 0x1C))
```

Register description:

| Register | Offset | Description |
|---|---:|---|
| `CNN_CTRL` | `0x00` | Control register used to start CNN computation |
| `CNN_STATUS` | `0x04` | Status register used to check busy/done state |
| `CNN_INPUT_INDEX` | `0x08` | Selects the input element index |
| `CNN_INPUT_DATA` | `0x0C` | Writes input data to the selected index |
| `CNN_KERNEL_INDEX` | `0x10` | Selects the kernel element index |
| `CNN_KERNEL_DATA` | `0x14` | Writes kernel data to the selected index |
| `CNN_OUTPUT_INDEX` | `0x18` | Selects the output element index |
| `CNN_OUTPUT_DATA` | `0x1C` | Reads output data from the selected index |

---

## 7. Firmware Flow

The firmware controls the CNN accelerator using memory-mapped registers.

Main firmware flow:

```text
Step 1: Initialize a 5x5 input matrix
Step 2: Initialize a 3x3 kernel matrix
Step 3: Write input data to the CNN accelerator
Step 4: Write kernel data to the CNN accelerator
Step 5: Send the start command
Step 6: Wait until the CNN accelerator reports done
Step 7: Read 9 output values
Step 8: Store the results in result_store[9]
```

Data flow:

```text
main.c
  |
  | writes input and kernel
  v
CNN memory-mapped registers
  |
  | CNN core performs convolution
  v
Output buffer
  |
  | CPU reads result
  v
result_store[9]
```

---

## 8. Convolution Formula

For a 5x5 input and a 3x3 kernel, the output size is:

```text
Output size = Input size - Kernel size + 1
            = 5 - 3 + 1
            = 3
```

Therefore, the output is a 3x3 matrix containing 9 values.

The general formula is:

```text
output[y][x] =
    input[y+0][x+0] * kernel[0][0] +
    input[y+0][x+1] * kernel[0][1] +
    input[y+0][x+2] * kernel[0][2] +
    input[y+1][x+0] * kernel[1][0] +
    input[y+1][x+1] * kernel[1][1] +
    input[y+1][x+2] * kernel[1][2] +
    input[y+2][x+0] * kernel[2][0] +
    input[y+2][x+1] * kernel[2][1] +
    input[y+2][x+2] * kernel[2][2]
```

---

## 9. Meaning of the Output Result

In the current simple model, the output values may be the same, for example:

```text
6 6 6
6 6 6
6 6 6
```

This does not necessarily mean the CNN accelerator is incorrect.

The reason may be that:

- The input matrix has repeated patterns
- The kernel is simple
- Each 3x3 region produces the same sum
- There is no bias, activation function, pooling, or multiple filters yet

In this project, the output value represents the result of a convolution operation between one 3x3 input region and the 3x3 kernel.

In a real CNN application, if the input is an actual image, different output values can represent different image features such as edges, brightness, shapes, or patterns.

---

## 10. Main Hardware Modules

### 10.1. `cnn_core.v`

This is the main CNN computation module.

Responsibilities:

- Store input data
- Store kernel data
- Perform multiply-and-accumulate operations
- Generate the 3x3 output matrix
- Assert the done signal when computation is complete

### 10.2. `wb_cnn_mini.v`

This module is the Wishbone wrapper for the CNN core.

Responsibilities:

- Receive read/write transactions from the CPU
- Decode CNN register accesses
- Transfer input and kernel data to the CNN core
- Return output data to the CPU

### 10.3. `wb_decoder.v`

This module decodes the CPU address bus.

Responsibilities:

- Detect RAM address range
- Detect CNN accelerator address range
- Route bus transactions to the correct target

### 10.4. `wb_ram_dp.v`

This is a dual-port RAM module.

Responsibilities:

- Store firmware instructions
- Store data used by the CPU
- Support instruction and data memory access during simulation

---

## 11. Build and Run Simulation

You can use the Makefile to build and run the project.

Example:

```bash
make clean
make build
make sim
```

Or run the simulation script directly:

```bash
python3 sim/sim.py
```

If the firmware needs to be built separately:

```bash
make firmware
```

During simulation, you can observe:

- CPU writing input data to the CNN accelerator
- CPU writing kernel data to the CNN accelerator
- Start signal being asserted
- CNN computation process
- Done status
- Output data being read by the CPU

---

## 12. Expected Result

For the sample input and kernel, the accelerator generates 9 output values.

The firmware stores the results in:

```c
volatile int result_store[9];
```

The result can be verified using:

- Simulation log
- Waveform viewer
- Register readback
- Output memory inspection

---

## 13. Educational Value

This project demonstrates the relationship between software and hardware in a simple SoC system.

Through this project, we can understand that:

- A CPU does not need to perform every computation by itself
- Heavy computation can be offloaded to a hardware accelerator
- Memory-mapped I/O allows software to control hardware modules
- A CNN operation can be implemented in hardware
- Verilog can be used to build a basic AI accelerator
- Firmware and RTL must work together correctly in a complete system

---

## 14. Current Limitations

This project is currently a simplified learning version.

Current limitations include:

- Only supports 5x5 input
- Only supports 3x3 kernel
- Only one convolution layer
- No bias support
- No activation function
- No ReLU
- No pooling layer
- No real image input yet
- No multiple filters
- No hardware pipeline optimization
- Mainly designed for simulation and learning

---

## 15. Future Development

This project can be extended in several directions.

### 15.1. Larger Input Size

The current input size is 5x5. Future versions may support:

```text
8x8
16x16
28x28
32x32
```

A 28x28 input would be useful for simple handwritten digit recognition experiments such as MNIST-like data.

### 15.2. Multiple Kernels

The current design only uses one 3x3 kernel.

Future versions may support multiple kernels to extract different features.

Example:

```text
Kernel 1: Horizontal edge detection
Kernel 2: Vertical edge detection
Kernel 3: Brightness detection
Kernel 4: Pattern detection
```

### 15.3. Bias and Activation Function

A real CNN usually applies bias and an activation function after convolution.

Example:

```text
output = convolution + bias
```

Then the output may pass through ReLU:

```text
ReLU(x) = max(0, x)
```

Adding ReLU would make the accelerator closer to a real CNN layer.

### 15.4. Pooling Layer

Pooling can reduce the size of feature maps while preserving important information.

Future versions may support:

- Max pooling
- Average pooling

### 15.5. Hardware Optimization

The current implementation can be improved for performance.

Possible optimizations:

- Pipelined architecture
- Parallel MAC units
- Multiple convolution units
- Input buffering
- Output buffering
- Reduced computation latency

### 15.6. LiteX Integration

The CNN accelerator can be developed into a standard LiteX-compatible peripheral.

Possible integration methods:

- Wishbone peripheral
- CSR-based peripheral
- Memory-mapped accelerator
- Firmware-controlled hardware module

### 15.7. FPGA Deployment

After simulation is stable, the project can be deployed to a real FPGA board.

Possible development flow:

```text
RTL simulation
      |
      v
SoC integration
      |
      v
Bitstream generation
      |
      v
FPGA programming
      |
      v
Firmware execution on real hardware
```

### 15.8. Simple Image Recognition

In the future, this project may be extended for simple image recognition tasks such as:

- Binary image classification
- Edge detection
- Small pattern recognition
- Simple handwritten digit recognition
- 8x8 or 16x16 image feature extraction

---

## 16. Conclusion

`cnn_simple_vanthuc_24161421` is a simple but meaningful project for learning how a CNN accelerator can be connected to a RISC-V SoC.

The project shows how software and hardware cooperate:

```text
CPU controls the system
CNN accelerator performs computation
RAM stores firmware and data
Wishbone bus connects all components
```

Although the current CNN model is still simple, it provides a strong foundation for understanding hardware acceleration, SoC design, and AI-oriented digital hardware.

---

## 17. Author

**Van Thuc**  
Project: CNN Simple Accelerator on RISC-V SoC  
Repository: `cnn_simple_vanthuc_24161421`
