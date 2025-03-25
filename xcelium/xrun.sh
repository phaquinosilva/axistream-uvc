#!/bin/bash

module load xcelium

export UVMHOME="/tools/cadence/XCELIUM2309/tools/methodology/UVM/CDNS-1.1d/"

echo "THIS: $(dirname -- $(readlink -fn -- "$0"))"

export CURRENT_PATH=$(dirname $(dirname -- $(readlink -fn -- "$0")))
export VIP_INTEG=$(dirname -- $(readlink -fn -- "$0"))

echo "PARENT: $CURRENT_PATH"

seed=$(((RANDOM % 999999999 )  + 100000000))

echo "Running seed: $seed"

VERBOSITY="+UVM_VERBOSITY=UVM_MEDIUM"
TEST="axis_test_base"
GUI=""

if [ $1 ]; then
  if [ "$1" == "-gui" ]; then
    GUI="$1"
    if [ $2 ]; then
      VERBOSITY="+UVM_VERBOSITY=$2"  # Use $2 for verbosity
    fi
  else
    VERBOSITY="+UVM_VERBOSITY=$1"
  fi
fi

xrun -lwdgen \
  -access rwc -uvm -uvmhome $UVMHOME \
  -svseed $seed -sv -f file_list.f \
  +UVM_TESTNAME=${TEST} ${VERBOSITY} ${GUI} 