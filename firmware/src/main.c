#define CNN_BASE          0x40000000

#define CNN_CTRL          (*(volatile unsigned int *)(CNN_BASE + 0x00))
#define CNN_STATUS        (*(volatile unsigned int *)(CNN_BASE + 0x04))
#define CNN_INPUT_INDEX   (*(volatile unsigned int *)(CNN_BASE + 0x08))
#define CNN_INPUT_DATA    (*(volatile unsigned int *)(CNN_BASE + 0x0C))
#define CNN_KERNEL_INDEX  (*(volatile unsigned int *)(CNN_BASE + 0x10))
#define CNN_KERNEL_DATA   (*(volatile unsigned int *)(CNN_BASE + 0x14))
#define CNN_OUTPUT_INDEX  (*(volatile unsigned int *)(CNN_BASE + 0x18))
#define CNN_OUTPUT_DATA   (*(volatile unsigned int *)(CNN_BASE + 0x1C))

volatile int result_store[9];

int main(void)
{
    int input[25] = {
        1, 2, 3, 4, 5,
        1, 2, 3, 4, 5,
        1, 2, 3, 4, 5,
        1, 2, 3, 4, 5,
        1, 2, 3, 4, 5
    };

    int kernel[9] = {
        -1, 0, 1,
        -1, 0, 1,
        -1, 0, 1
    };

    for (int i = 0; i < 25; i++) {
        CNN_INPUT_INDEX = i;
        CNN_INPUT_DATA  = input[i];
    }

    for (int i = 0; i < 9; i++) {
        CNN_KERNEL_INDEX = i;
        CNN_KERNEL_DATA  = kernel[i];
    }

    CNN_CTRL = 2; // clear done
    CNN_CTRL = 1; // start

    while ((CNN_STATUS & 1) == 0);

    for (int i = 0; i < 9; i++) {
        CNN_OUTPUT_INDEX = i;
        result_store[i] = CNN_OUTPUT_DATA;
    }

    while (1);

    return 0;
}
