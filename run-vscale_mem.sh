#!/bin/bash

echo "Running vscale_mem"
echo "Moving into vscale_mem directory"
cd vscale_mem

echo
echo "==========================="
echo "Running BMC proof for ReadValues with 4 instructions"
echo "time sby -f sec-mem-2.sby"
time sby -f sec-mem-2.sby
echo "==========================="
echo

echo
echo "==========================="
echo "Running BMC proof for ReadValues with 6 instructions"
echo "time sby -f sec-mem-3.sby"
time sby -f sec-mem-3.sby
echo "==========================="
echo

echo
echo "==========================="
echo "Running BMC proof for ReadValues with 8 instructions"
echo "time sby -f sec-mem-4.sby"
time sby -f sec-mem-4.sby
echo "==========================="
echo

echo "Completed example"
echo