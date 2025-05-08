<div align="center">
  
#  Лабораторные работы по дисциплине "Операционные системы"

</div>

***

## Содержание


1. [Лабораторная работа №1](#lab1)
2. [Лабораторная №2](#lab2)
3. [Лабораторная №3a. - Реализация скрипта bash](#lab3)

***

## <a id="lab1">Лабораторная работа №1</a>
Исходный код программы (fibonacci.cpp)
```cpp
#include <iostream>

int fibonacci(int n) {
    if (n <= 1)  
        return n;
    // Рекурсивный случай: F(n) = F(n-1) + F(n-2)
    return fibonacci(n - 1) + fibonacci(n - 2);
}

int main() {
    int num = 10; 
    std::cout << "Fibonacci of " << num << " is " << fibonacci(num) << std::endl;
    return 0;
}
```
Для генерации ассемблерного кода используются команды:
```bash
# Без оптимизации
g++ -S -O0 -o fibonacci_O0.s fibonacci.cpp

# С оптимизациями уровней 1-3
g++ -S -O1 -o fibonacci_O1.s fibonacci.cpp
g++ -S -O2 -o fibonacci_O2.s fibonacci.cpp
g++ -S -O3 -o fibonacci_O3.s fibonacci.cpp

# С оптимизацией по размеру кода
g++ -S -Os -o fibonacci_Os.s fibonacci.cpp

# С отладочной информацией
g++ -S -g -o fibonacci_g.s fibonacci.cpp
```
<div align="center">
  
# Анализ ассемблерного кода

</div>

Рассмотрим функцию fibonacci в варианте без оптимизаций:

```asm
_Z9fibonaccii:          # имя функции
.LFB0:                  # Метка начала функции
    pushq   %rbp        
    movq    %rsp, %rbp  
    subq    $16, %rsp   # Выделяем 16 байт в стеке для локальных переменных
    
    # Сохранение параметра n в стеке
    movl    %edi, -4(%rbp)  
    
    # Проверка условия n <= 1
    cmpl    $1, -4(%rbp)    # Сравниваем n с 1
    jg      .L2             # Если n > 1, переходим к метке .L2
    
    # Случай n <= 1 (возвращаем n)
    movl    -4(%rbp), %eax  
    jmp     .L3             # Переходим к завершению функции
    
.L2:    
    # Первый рекурсивный вызов (fibonacci(n-1))
    movl    -4(%rbp), %eax  # 
    subl    $1, %eax         # 
    movl    %eax, %edi       # 
    call    _Z9fibonaccii    # Вызываем fibonacci(n-1)
    movl    %eax, -8(%rbp)   # Сохраняем результат в стеке 
    
    # Второй рекурсивный вызов (fibonacci(n-2))
    movl    -4(%rbp), %eax  
    subl    $2, %eax        
    movl    %eax, %edi       
    call    _Z9fibonaccii    # Вызываем fibonacci(n-2)
    
    # Суммирование результатов
    movl    -8(%rbp), %edx  # Загружаем fibonacci(n-1) в edx
    addl    %edx, %eax       # Складываем с fibonacci(n-2) (результат уже в eax)
    
.L3:    # Выход из функции
    leave          
    ret          
```

Рассмотрим код для функции fibonacci с оптимизацией -O2:
```asm
_Z9fibonaccii:
.LFB0:
    testl   %edi, %edi       # Проверка n <= 0
    jle     .L4             # Если n <= 0, переход к .L4
    cmpl    $1, %edi        # Сравнение n с 1
    je      .L5             # Если n == 1, переход к .L5
    pushq   %rbx            # Сохраняем регистр rbx
    movl    %edi, %ebx      # Сохраняем n в ebx
    
    # Первый рекурсивный вызов (n-1)
    leal    -1(%rdi), %edi  
    call    _Z9fibonaccii   # Вызов fibonacci(n-1)
    movl    %eax, %edi      # Сохраняем результат в edi
    
    # Второй рекурсивный вызов (n-2)
    leal    -2(%rbx), %eax  
    movl    %eax, %esi      # Копируем в esi для вызова
    call    _Z9fibonaccii   # Вызов fibonacci(n-2)
    
    addl    %esi, %eax      # Суммируем результаты
    popq    %rbx           
    ret                     
    
.L4:
    xorl    %eax, %eax      # Возвращаем 0 (случай n <= 0)
    ret
    
.L5:
    movl    $1, %eax        # Возвращаем 1 (случай n == 1)
    ret
```

На уровне оптимизации O2 получаем следующее: удаление frame pointer (не используем %rbp),
более эффективное использование регистров, удаление избыточных загрузок/сохранений.

<div align="center">
  
# Модульная структура и Makefile

</div>

```
project/
├── include/
│   └── fibonacci.h    # Заголовочный файл
├── src/
│   ├── fibonacci.cpp    # Реализация 
│   └── main.cpp          # Вход
└── Makefile              # Файл сборки
```

fibonacci.h (заголовочный файл):
```h
#pragma once  // Защита от множественного включения

// Объявление функции вычисления чисел Фибоначчи
int fibonacci(int n);
```
fibonacci0.cpp (реализация):
```cpp
#include "fibonacci.h"  // Включаем наш заголовочный файл

// Реализация рекурсивной функции Фибоначчи
int fibonacci(int n) {
    if (n <= 1)  // Базовый случай
        return n;
    return fibonacci(n - 1) + fibonacci(n - 2);  // Рекурсивный вызов
}
```
main.cpp (точка входа):
```cpp
#include <iostream>  // Для ввода/вывода
#include "fibonacci.h"  // Наша функция Фибоначчи

int main() {
    const int num = 10;  // Номер числа Фибоначчи для вычисления
    
    // Вычисление и вывод результата
    std::cout << "Fibonacci of " << num << " is " 
              << fibonacci(num) << std::endl;
    
    return 0;
}
```
Makefile:
```Makefile
# Настройки компилятора
CXX := g++                  # Используем компилятор g++
CXXFLAGS := -Wall -Wextra    # Включаем все предупреждения
LDFLAGS :=                   # Флаги компоновщика (пока пустые)

# Уровни оптимизации для генерации ассемблера
OPTIMIZATIONS := -O0 -O1 -O2 -O3 -Os

# Исходные файлы
SRCS := main.cpp fibonacci.cpp
OBJS := $(SRCS:.cpp=.o)      # Объектные файлы
EXEC := fibonacci            # Имя исполняемого файла

# Цели по умолчанию
.PHONY: all clean asm

all: $(EXEC)                 # Основная цель - сборка программы

# Правило для сборки исполняемого файла
$(EXEC): $(OBJS)
	$(CXX) $(CXXFLAGS) $^ -o $@ $(LDFLAGS)

# Правило для компиляции .cpp в .o
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Генерация ассемблерного кода с разными оптимизациями
asm:
	@echo "Generating assembly with different optimizations..."
	$(foreach opt,$(OPTIMIZATIONS),\
	  $(CXX) -S $(CXXFLAGS) $(opt) -o fibonacci_$(opt:O%=%).s fibonacci.cpp;)

# Очистка
clean:
	rm -f $(OBJS) $(EXEC) *.s *.o

# Зависимости (для правильного учёта заголовочных файлов)
main.o: fibonacci.h
fibonacci.o: fibonacci.h
```
<div align="center">
  
# Параллельная реализация

</div>

parallel_fibonacci.cpp:
```cpp
#include <iostream>
#include <unistd.h>      // Для fork()
#include <sys/wait.h>    // Для wait()
#include <sys/mman.h>    // Для shared memory
#include <sys/stat.h>    // Для констант режимов
#include <fcntl.h>       // Для shm_open()
#include <cerrno>        // Для обработки ошибок
#include <cstring>       // Для strerror()

// Функция вычисления Фибоначчи (без изменений)
int fibonacci(int n) {
    if (n <= 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
}

int main() {
    const int num = 10;               // Число для вычисления
    const char* shm_name = "/fib_shm"; // Имя области shared memory
    
    // 1. Создаем/открываем область shared memory
    int shm_fd = shm_open(shm_name, O_CREAT | O_RDWR, 0666);
    if (shm_fd == -1) {
        std::cerr << "shm_open failed: " << strerror(errno) << std::endl;
        return 1;
    }
    
    // 2. Устанавливаем размер области
    if (ftruncate(shm_fd, sizeof(int)) == -1) {
        std::cerr << "ftruncate failed: " << strerror(errno) << std::endl;
        shm_unlink(shm_name);
        return 1;
    }
    
    // 3. Отображаем shared memory в адресное пространство процесса
    int* result = (int*)mmap(0, sizeof(int), PROT_READ | PROT_WRITE, 
                            MAP_SHARED, shm_fd, 0);
    if (result == MAP_FAILED) {
        std::cerr << "mmap failed: " << strerror(errno) << std::endl;
        shm_unlink(shm_name);
        return 1;
    }
    
    *result = 0;  // Инициализируем результат
    
    // 4. Создаем дочерний процесс
    pid_t pid = fork();
    
    if (pid == -1) {  // Ошибка при создании процесса
        std::cerr << "Fork failed: " << strerror(errno) << std::endl;
        munmap(result, sizeof(int));
        shm_unlink(shm_name);
        return 1;
    }
    else if (pid == 0) {  // Дочерний процесс
        // Вычисляем число Фибоначчи
        int fib = fibonacci(num);
        
        // Записываем результат в shared memory
        *result = fib;
        
        // Завершаем дочерний процесс
        exit(0);
    }
    else {  // Родительский процесс
        // Ждем завершения дочернего процесса
        wait(NULL);
        
        // Выводим результат
        std::cout << "Fibonacci of " << num << " is " << *result << std::endl;
        
        // 5. Освобождаем ресурсы
        munmap(result, sizeof(int));  // Удаляем отображение памяти
        shm_unlink(shm_name);        // Удаляем shared memory
        
        return 0;
    }
}
```
Обновленный Makefile:

```Makefile
# Настройки компилятора
CXX := g++
CXXFLAGS := -Wall -Wextra -std=c++11
LDFLAGS := -lrt  # Для shared memory (shm_open, shm_unlink)

# Исходные файлы
SRCS := main.cpp fibonacci.cpp
OBJS := $(SRCS:.cpp=.o)
EXEC := fibonacci
PARALLEL_EXEC := parallel_fibonacci

# Основные цели
.PHONY: all clean

all: $(EXEC) $(PARALLEL_EXEC)

# Обычная версия
$(EXEC): $(OBJS)
	$(CXX) $(CXXFLAGS) $^ -o $@

# Параллельная версия
$(PARALLEL_EXEC): parallel_fibonacci.cpp
	$(CXX) $(CXXFLAGS) $< -o $@ $(LDFLAGS)

# Общее правило для объектных файлов
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Очистка
clean:
	rm -f $(OBJS) $(EXEC) $(PARALLEL_EXEC) *.s
```

<div align="center">
  
# Итоги:

</div>

В ходе лабораторной работы я: асследовала процесс компиляции C++ кода в ассемблер, проанализировала влияние разных уровней оптимизации,
организовала модульную структуру программы, создала эффективный Makefile для сборки, реализовала параллельные вычисления с использованием:
системных вызовов (fork, wait); разделения памяти (shm_open, mmap); синхронизации процессов.
