#!/bin/bash
#
# Calculate the optimal starting partition offset for a block device


if [[ $# -ne 1 ]] || [[ ! -d /sys/block/${1} ]]; then
  _BLKDEVS="["
  for ii in /sys/block/*; do 
    _BLKDEVS+=" ${ii##*/}"
  done
  _BLKDEVS+=" ]"
  echo "Block devices detected: ${_BLKDEVS}"
  echo " Usage: $0 <block device>"
  echo " Example: $0 sda"
  exit 1
fi

OPT=$(cat /sys/block/${1}/queue/optimal_io_size)
OFF=$(cat /sys/block/${1}/alignment_offset)
BLK=$(cat /sys/block/${1}/queue/physical_block_size)

if [[ ${OPT} -eq 0 ]]; then
  echo "Optimal I/O is zero, use 2048s (sectors)"
else
  _RES=$(( ($OPT+$OFF)/$BLK ))
  # ensure minimum 2048s offset
  while [[ ${_RES} -lt 2048 ]]; do
    _RES=$(( ${_RES}+${_RES} ))
  done
  echo "Optimal I/O is set, use ${_RES}s (sectors)"
fi

exit 0

