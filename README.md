# Kalman-Bhai

Commands to run base-cpp implementation
```
$ g++ -I /path/to/eigen-directory/ my_program.cpp
```
To compile and test bluespec files currently in the directory
1. For pe, go to src/bluespec
make pe
2. For mat_mult, go to src/bluespec
make mat_mult

To run baseC implementation
1. original.c
gcc original.c

///To test for gcc optimisations possible!
2. full_code_omp.c
gcc -fopenmp full_code_omp.c

The other codes are for HLS