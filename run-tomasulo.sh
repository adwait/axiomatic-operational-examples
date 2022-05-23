#!/bin/bash

echo "Running tomasulo"
echo "Moving into tomasulo directory"
cd tomasulo

echo
echo "==========================="
echo "Running on the BUGGY design"
echo "time sby -f sec.sby taskBMC_bug"
time sby -f sec.sby taskBMC_bug
echo "==========================="
echo

echo
echo "==========================="
echo "Running on the CORRECTED design"
echo "time sby -f sec.sby taskBMC"
time sby -f sec.sby taskBMC
echo "==========================="
echo

echo "Completed example"
echo