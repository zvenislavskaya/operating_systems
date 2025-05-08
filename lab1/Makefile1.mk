CXX = g++
CXXFLAGS = -Wall -Wextra
OPTIMIZATIONS = -O0 -O1 -O2 -O3

SRCS = main.cpp fibonacci.cpp
OBJS = $(SRCS:.cpp=.o)
EXEC = fibonacci

.PHONY: all clean

all: $(EXEC)

$(EXEC): $(OBJS)
	$(CXX) $(CXXFLAGS) $^ -o $@

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

asm: $(SRCS)
	$(foreach opt,$(OPTIMIZATIONS),\
		$(CXX) -S $(CXXFLAGS) $(opt) -o fibonacci_$(opt).s fibonacci.cpp;)

clean:
	rm -f $(OBJS) $(EXEC) *.s
