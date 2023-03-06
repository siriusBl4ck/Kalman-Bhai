# Kalman-Bhai
Kalman Filter is an algorithm that produces estimates of state variables of a discrete data controlled system (thus an estimate
of the state of the system) based on measurements which can typically be noisy.

[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/uaDeUbCFaJg/0.jpg)](https://www.youtube.com/watch?v=uaDeUbCFaJg)

## A study of Hardware Acceleration of Kalman Filter

To run baseC implementation
```gcc basecode_time.c```

To run openmp implementation
```gcc -fopenmp code_omp_time.c```

To compile and test bluespec files currently in the directory
1. For pe, go to src/bluespec ```make pe```
2. For mat_mult, go to src/bluespec```make mat_mult```
3. For top module (KalmanAlgo), go to src/bluespec```make Kalman```

```./a.out```

For using profiling tools
g++ -I . basecode_time.c -o basecode_output.out
valgrind --tool=callgrind --dump-instr=yes --toggle-collect=main --collect-jumps=yes ./basecode_output.out
kcachegrind callgrind.out.<process ID>

