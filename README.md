# CNN Simple Accelerator on RISC-V SoC

## 1. Giới thiệu dự án

`cnn_simple_vanthuc_24161421` là một project mô phỏng hệ thống SoC đơn giản sử dụng CPU RISC-V kết hợp với một khối phần cứng CNN Accelerator được viết bằng Verilog.

Mục tiêu của project là xây dựng một mô hình cơ bản cho việc tăng tốc tính toán CNN bằng phần cứng, trong đó CPU RISC-V đóng vai trò điều khiển, còn khối CNN thực hiện phép tính tích chập đơn giản trên dữ liệu đầu vào.

Dự án này phù hợp cho việc học và thực hành các nội dung:

- Thiết kế SoC đơn giản
- Giao tiếp CPU với ngoại vi qua bus
- Thiết kế phần cứng bằng Verilog
- Viết firmware C chạy trên CPU RISC-V
- Mô phỏng luồng dữ liệu giữa phần mềm và phần cứng
- Hiểu nguyên lý cơ bản của CNN trong xử lý ảnh và AI

---

## 2. CNN là gì?

CNN là viết tắt của **Convolutional Neural Network**, hay tiếng Việt là **mạng nơ-ron tích chập**.

CNN là một loại mạng học sâu thường dùng trong các bài toán xử lý ảnh, nhận dạng hình ảnh, phân loại vật thể, nhận dạng chữ viết, phát hiện khuôn mặt và nhiều ứng dụng AI khác.

Ý tưởng chính của CNN là dùng các bộ lọc nhỏ, gọi là **kernel** hoặc **filter**, trượt trên ma trận dữ liệu đầu vào để trích xuất đặc trưng.

Ví dụ, với ảnh đầu vào dạng ma trận:

```text
1 2 3 4 5
1 2 3 4 5
1 2 3 4 5
1 2 3 4 5
1 2 3 4 5
```
và kernel 3x3:
```
-1 0 1
-1 0 1
-1 0 1
```
phép tích chập sẽ lấy từng vùng 3x3 của ảnh đầu vào, nhân với kernel, sau đó cộng lại để tạo ra một giá trị đầu ra.

Trong project này, mô hình CNN được đơn giản hóa để dễ hiểu và dễ mô phỏng trên phần cứng.

3. Mục tiêu của project

Project này được xây dựng với các mục tiêu chính:

Thiết kế một khối CNN Accelerator đơn giản bằng Verilog.
Kết nối khối CNN vào hệ thống SoC thông qua bus.
Viết firmware C để CPU nạp dữ liệu input và kernel vào CNN.
Cho CNN tính toán kết quả tích chập.
CPU đọc kết quả output từ CNN.
Mô phỏng toàn bộ hệ thống để quan sát luồng dữ liệu.

4. Kiến trúc tổng quan hệ thống

Hệ thống gồm các thành phần chính:
```
+------------------+
|   Firmware C     |
|  chạy trên CPU   |
+--------+---------+
         |
         v
+------------------+
|   RISC-V CPU     |
|   VexRiscv       |
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
|      RAM         |    | CNN Accelerator  |
| Instruction/Data |    |  Verilog module  |
+------------------+    +------------------+
```
CPU RISC-V không trực tiếp tính toán CNN. CPU chỉ làm nhiệm vụ:

ghi dữ liệu input vào CNN
ghi kernel vào CNN
gửi tín hiệu start
chờ CNN tính xong
đọc kết quả output

Khối CNN Accelerator sẽ đảm nhiệm phần tính toán chính.

5. Cấu trúc thư mục
```
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
Ý nghĩa các thư mục:
| Thư mục                 | Chức năng                                            |
| ----------------------- | ---------------------------------------------------- |
| `firmware/`             | Chứa chương trình C chạy trên CPU RISC-V             |
| `rtl/`                  | Chứa các module Verilog của phần cứng                |
| `sim/`                  | Chứa file mô phỏng hệ thống                          |
| `tb/`                   | Chứa testbench kiểm thử                              |
| `model/`                | Có thể chứa mô hình tham chiếu hoặc dữ liệu kiểm thử |
| `scripts/`              | Chứa script hỗ trợ build, chạy mô phỏng              |
| `third_party/vexriscv/` | Chứa CPU VexRiscv hoặc thành phần phụ thuộc          |
| `Makefile`              | Tự động hóa quá trình build và chạy project          |

6. Memory Map

Khối CNN được ánh xạ vào vùng địa chỉ:
#define CNN_BASE 0x40000000
Các thanh ghi điều khiển của CNN:
#define CNN_CTRL          (*(volatile unsigned int *)(CNN_BASE + 0x00))
#define CNN_STATUS        (*(volatile unsigned int *)(CNN_BASE + 0x04))
#define CNN_INPUT_INDEX   (*(volatile unsigned int *)(CNN_BASE + 0x08))
#define CNN_INPUT_DATA    (*(volatile unsigned int *)(CNN_BASE + 0x0C))
#define CNN_KERNEL_INDEX  (*(volatile unsigned int *)(CNN_BASE + 0x10))
#define CNN_KERNEL_DATA   (*(volatile unsigned int *)(CNN_BASE + 0x14))
#define CNN_OUTPUT_INDEX  (*(volatile unsigned int *)(CNN_BASE + 0x18))
#define CNN_OUTPUT_DATA   (*(volatile unsigned int *)(CNN_BASE + 0x1C))

Bảng ý nghĩa:
| Thanh ghi          | Địa chỉ offset | Chức năng                     |
| ------------------ | -------------: | ----------------------------- |
| `CNN_CTRL`         |         `0x00` | Gửi lệnh start cho CNN        |
| `CNN_STATUS`       |         `0x04` | Kiểm tra trạng thái done/busy |
| `CNN_INPUT_INDEX`  |         `0x08` | Chọn vị trí input cần ghi     |
| `CNN_INPUT_DATA`   |         `0x0C` | Ghi dữ liệu input             |
| `CNN_KERNEL_INDEX` |         `0x10` | Chọn vị trí kernel cần ghi    |
| `CNN_KERNEL_DATA`  |         `0x14` | Ghi dữ liệu kernel            |
| `CNN_OUTPUT_INDEX` |         `0x18` | Chọn vị trí output cần đọc    |
| `CNN_OUTPUT_DATA`  |         `0x1C` | Đọc kết quả output            |

7. Luồng hoạt động của firmware

Firmware C thực hiện các bước sau:
  
Bước 1: Khởi tạo dữ liệu input 5x5
Bước 2: Khởi tạo kernel 3x3
Bước 3: Ghi input vào CNN Accelerator
Bước 4: Ghi kernel vào CNN Accelerator
Bước 5: Gửi tín hiệu start
Bước 6: Chờ CNN báo done
Bước 7: Đọc 9 giá trị output
Bước 8: Lưu kết quả vào result_store

Luồng dữ liệu:
```
main.c
  |
  | ghi input, kernel
  v
CNN registers
  |
  | CNN core xử lý
  v
Output buffer
  |
  | CPU đọc lại
  v
result_store[9]
```
8. Công thức tích chập

Với input 5x5 và kernel 3x3, output tạo ra có kích thước:

Output size = Input size - Kernel size + 1
            = 5 - 3 + 1
            = 3
Do đó output là ma trận 3x3, gồm 9 giá trị.

Công thức tổng quát:
```
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
9. Ý nghĩa kết quả

Trong mô hình hiện tại, kết quả tính ra có thể là các giá trị giống nhau, ví dụ toàn bộ output đều bằng 6.

Điều này không có nghĩa là CNN bị sai. Nguyên nhân thường là do:

input được lặp lại theo từng hàng
kernel đơn giản
dữ liệu đầu vào có quy luật đều
chưa có bias, activation, pooling hoặc nhiều kernel

Kết quả 6 thể hiện rằng tại mỗi vùng 3x3, phép nhân chập giữa input và kernel cho ra cùng một tổng.

Trong thực tế, nếu input là ảnh thật, các giá trị output sẽ khác nhau và thể hiện các đặc trưng khác nhau của ảnh như cạnh, vùng sáng, vùng tối hoặc hình dạng.

10. Các module phần cứng chính
10.1. cnn_core.v

Đây là module xử lý chính của CNN.

Chức năng:

lưu input
lưu kernel
thực hiện phép nhân và cộng
sinh output 3x3
báo trạng thái done sau khi tính xong
10.2. wb_cnn_mini.v

Đây là module wrapper giúp CNN giao tiếp với bus Wishbone.

Chức năng:

nhận tín hiệu đọc/ghi từ CPU
ánh xạ thanh ghi CNN
chuyển dữ liệu từ bus vào CNN core
trả dữ liệu output về CPU
10.3. wb_decoder.v

Module giải mã địa chỉ bus.

Chức năng:

xác định địa chỉ nào thuộc RAM
xác định địa chỉ nào thuộc CNN
điều hướng tín hiệu bus tới đúng ngoại vi
10.4. wb_ram_dp.v

RAM hai cổng dùng cho instruction/data memory.

Chức năng:

lưu chương trình firmware
lưu dữ liệu tạm
cho phép CPU truy cập bộ nhớ trong quá trình mô phỏng

11. Build và chạy mô phỏng

Có thể sử dụng Makefile để build và chạy project.

Ví dụ:
make clean
make sim
make wave

make all

Sau khi chạy mô phỏng, có thể quan sát:

CPU ghi input vào CNN
CPU ghi kernel vào CNN
tín hiệu start
trạng thái done
dữ liệu output trả về CPU

12. Kết quả mong đợi

Với input và kernel mẫu, hệ thống sẽ sinh ra 9 giá trị output:
output[0]
output[1]
output[2]
...
output[8]

Các giá trị này được firmware đọc về và lưu trong:
volatile int result_store[9];

Có thể kiểm tra kết quả bằng waveform hoặc log mô phỏng.

13. Ý nghĩa học thuật của project

Project này giúp làm rõ mối liên hệ giữa phần mềm và phần cứng trong một hệ thống SoC.

Thông qua project, có thể hiểu được:

CPU không nhất thiết phải tự xử lý mọi phép toán
Các tác vụ nặng có thể được đẩy sang phần cứng chuyên dụng
Memory-mapped I/O giúp CPU điều khiển ngoại vi giống như ghi/đọc biến trong C
CNN có thể được tăng tốc bằng phần cứng
Verilog có thể dùng để thiết kế các bộ tăng tốc AI đơn giản
14. Hướng phát triển trong tương lai

Project hiện tại mới là phiên bản đơn giản. Trong tương lai có thể mở rộng theo các hướng sau:

14.1. Mở rộng kích thước input

Hiện tại input chỉ là 5x5. Có thể mở rộng lên:

8x8
16x16
28x28, tương tự ảnh MNIST
32x32, tương tự ảnh CIFAR nhỏ
14.2. Hỗ trợ nhiều kernel

Phiên bản hiện tại chỉ dùng một kernel 3x3. Có thể mở rộng để hỗ trợ nhiều kernel nhằm trích xuất nhiều đặc trưng khác nhau.

Ví dụ:

Kernel 1: phát hiện cạnh ngang
Kernel 2: phát hiện cạnh dọc
Kernel 3: phát hiện vùng sáng
Kernel 4: phát hiện vùng tối
14.3. Thêm bias và activation function

CNN thực tế thường có thêm:

output = convolution + bias

Sau đó đi qua hàm kích hoạt như:

ReLU(x) = max(0, x)

Có thể thêm module ReLU để mô hình gần với CNN thật hơn.

14.4. Thêm pooling layer

Pooling giúp giảm kích thước dữ liệu và giữ lại đặc trưng quan trọng.

Có thể thêm:

Max Pooling
Average Pooling
14.5. Tối ưu hiệu năng phần cứng

Phiên bản đầu có thể tính toán tuần tự. Trong tương lai có thể tối ưu bằng:

pipeline
parallel multiply-accumulate
nhiều MAC unit
buffer dữ liệu
giảm số chu kỳ tính toán
14.6. Tích hợp với LiteX SoC

Có thể phát triển project thành một peripheral chuẩn trong LiteX, cho phép CPU truy cập CNN thông qua CSR hoặc Wishbone bus.

14.7. Chạy trên FPGA thật

Sau khi mô phỏng ổn định, project có thể được đưa lên FPGA thật để kiểm chứng phần cứng.

Các bước tương lai:

Mô phỏng bằng Verilator/Icarus
        |
        v
Tích hợp LiteX SoC
        |
        v
Build bitstream
        |
        v
Nạp lên FPGA
        |
        v
Chạy firmware thật

14.8. Ứng dụng nhận dạng ảnh đơn giản

Khi hệ thống hoàn thiện hơn, có thể dùng để nhận dạng các mẫu ảnh nhỏ như:

chữ số đơn giản
ký tự nhị phân
biên ảnh
mẫu đen trắng 8x8 hoặc 16x16
15. Hạn chế hiện tại

Phiên bản hiện tại còn một số giới hạn:

Chỉ hỗ trợ input 5x5
Chỉ hỗ trợ kernel 3x3
Chỉ có một lớp convolution
Chưa có bias
Chưa có ReLU
Chưa có pooling
Chưa hỗ trợ ảnh thật
Chưa tối ưu pipeline
Chủ yếu phục vụ mục đích học tập và mô phỏng
16. Kết luận

Project cnn_simple_vanthuc_24161421 là một bước khởi đầu để hiểu cách xây dựng một bộ tăng tốc CNN đơn giản trên hệ thống RISC-V SoC.

Dự án cho thấy cách CPU và phần cứng chuyên dụng có thể phối hợp với nhau:

CPU điều khiển
CNN tính toán
RAM lưu chương trình và dữ liệu
Bus kết nối toàn hệ thống

Mặc dù mô hình còn đơn giản, project này là nền tảng tốt để phát triển các hệ thống AI Accelerator phức tạp hơn trong tương lai.

17. Author

Van Thuc
Project: CNN Simple Accelerator on RISC-V SoC
Repository: cnn_simple_vanthuc_24161421

=================================================

18. Contact

Nguyen Van Thuc  MSSV 24161421
gmail: chuantinh2407@gmail.com
sdt: 84+ 961072793

==================================================
