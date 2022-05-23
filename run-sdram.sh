#!/bin/bash

echo "Running sdram"
echo "Moving into sdram directory"
cd sdram

echo
echo "==========================="
echo "Running PDR proof for Pipeline axioms"
echo "time sby -f sec.sby taskPipeline"
time sby -f sec.sby taskPipeline
echo "==========================="
echo

echo
echo "==========================="
echo "Running PDR proof for Interrupt axioms"
echo "time sby -f sec.sby taskRefreshInterrupt"
time sby -f sec.sby taskRefreshInterrupt
echo "==========================="
echo

echo "Completed example"
echo