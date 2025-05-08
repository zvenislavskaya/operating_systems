#include <iostream>

int fibonacci(int n) {
    if (n <= 1)
        return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
}

int main() {
    int num = 10;
    std::cout << "Fibonacci of " << num << " is " << fibonacci(num) << std::endl;
    return 0;
}
