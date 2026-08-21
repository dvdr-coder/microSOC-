#define GPIO_BASE   ((volatile unsigned int*)0x10000000)
#define UART_BASE   ((volatile unsigned int*)0x20000000)
#define FINISH_BASE ((volatile unsigned int*)0x30000000)

void uart_putchar(char c) {
    *UART_BASE = (unsigned int)c;
}

void print(const char *s) {
    while (*s) uart_putchar(*s++);
}

int main() {
    print("Hello MicroSoC!\n");
    *GPIO_BASE = 0xDEADBEEF;
    *FINISH_BASE = 0x1;
    return 0;
}
