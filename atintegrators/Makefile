
PYTHON=/usr/include/python2.7
FLAGS=-std=c99 -fPIC -shared -DPYAT
NUMPY=/usr/lib/python2.7/dist-packages/numpy/core/include/numpy

SRC=$(wildcard *.c)
OBJ=$(SRC:.c=.so)

main: $(OBJ)

%.so: %.c
	$(CC) -I$(NUMPY) -I$(PYTHON) $(FLAGS) -lpython2.7   $^ -o $@

clean:
	rm -rf *.so
