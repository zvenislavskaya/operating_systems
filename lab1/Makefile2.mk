CXX = g++
CXXFLAGS = -Wall -Wextra -lrt  # Добавляем -lrt для работы с разделяемой памятью

SRCS = main.cpp fibonacci.cpp
OBJS = $(SRCS:.cpp=.o)
EXEC = fibonacci
PARALLEL_EXEC = parallel_fibonacci

.PHONY: all clean

all: $(EXEC) $(PARALLEL_EXEC)

$(EXEC): $(OBJS)
	$(CXX) $(CXXFLAGS) $^ -o $@

$(PARALLEL_EXEC): parallel_fibonacci.cpp
	$(CXX) $(CXXFLAGS) $< -o $@

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(EXEC) $(PARALLEL_EXEC)
