#include <iostream>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>

int fibonacci(int n) {
    if (n <= 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
}

int main() {
    const int num = 10;
    const char* shm_name = "/fibonacci_shm";
    
    // Создаем разделяемую память
    int shm_fd = shm_open(shm_name, O_CREAT | O_RDWR, 0666);
    ftruncate(shm_fd, sizeof(int));
    int* result = (int*)mmap(0, sizeof(int), PROT_READ | PROT_WRITE, MAP_SHARED, shm_fd, 0);
    *result = 0;

    pid_t pid = fork();
    
    if (pid == 0) { // Дочерний процесс
        int fib = fibonacci(num);
        *result = fib;
        exit(0);
    } else if (pid > 0) { // Родительский процесс
        wait(NULL); // Ждем завершения дочернего процесса
        std::cout << "Fibonacci of " << num << " is " << *result << std::endl;
        
        // Освобождаем ресурсы
        munmap(result, sizeof(int));
        shm_unlink(shm_name);
    } else {
        std::cerr << "Fork failed" << std::endl;
        return 1;
    }
    
    return 0;
}
