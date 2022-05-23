#!/bin/bash

echo "Running vscale_ind"
echo "Moving into vscale_ind directory"
cd vscale_ind

echo
echo "==========================="
echo "Running PDR proof for R-type instructions"
echo "time sby -f sec-alu-ind.sby taskProve_r"
time sby -f sec-alu-ind.sby taskProve_r
echo "==========================="
echo

echo
echo "==========================="
echo "Running BMC (d=20) proof for R-type instructions"
echo "time sby -f sec-alu-ind.sby taskBMC_r"
time sby -f sec-alu-ind.sby taskBMC_r
echo "==========================="
echo

echo
echo "==========================="
echo "Running PDR proof for I-type instructions"
echo "time sby -f sec-alu-ind.sby taskProve_i"
time sby -f sec-alu-ind.sby taskProve_i
echo "==========================="
echo

echo
echo "==========================="
echo "Running BMC (d=20) proof for I-type instructions"
echo "time sby -f sec-alu-ind.sby taskBMC_i"
time sby -f sec-alu-ind.sby taskBMC_i
echo "==========================="
echo

echo
echo "==========================="
echo "Running PDR proof for Load+Store instructions"
echo "time sby -f sec-mem-ind.sby taskProve"
time sby -f sec-mem-ind.sby taskProve
echo "==========================="
echo

echo
echo "==========================="
echo "Running BMC (d=20) proof for Load+Store instructions"
echo "time sby -f sec-mem-ind.sby taskBMC"
time sby -f sec-mem-ind.sby taskBMC
echo "==========================="
echo

echo "Completed example"
echo