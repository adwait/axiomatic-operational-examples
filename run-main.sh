#!/bin/bash

# Run vscale PDR examples
./run-vscale_ind.sh

echo
echo
echo "==========================="
echo "==========================="
echo
echo

# Run vscale memory examples
./run-vscale_mem.sh

echo
echo
echo "==========================="
echo "==========================="
echo
echo

# Run tomasulo examples
./run-tomasulo.sh

echo
echo
echo "==========================="
echo "==========================="
echo
echo

# Run sdram_ctrl examples
./run-sdram.sh



