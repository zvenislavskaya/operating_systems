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
