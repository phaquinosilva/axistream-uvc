#!/bin/bash
module load xcelium vmanager

export UVMHOME="/tools/cadence/XCELIUM2309/tools/methodology/UVM/CDNS-1.1d/"

declare -a arr=(
                # "axis_test_base"
                "axis_transfer_smoke_test"
                # "element3"
              )

# ------------------------------------------------------------------------------

if [ -z $1 ]
then
  NUM_RUNS=10
else
  NUM_RUNS=$1
fi

# export CURRENT_PATH=$(dirname -- $(readlink -fn -- "$0"))
export CURRENT_PATH=$(dirname $(dirname -- $(readlink -fn -- "$0")))

## now loop through the above array
for test in "${arr[@]}"
do

  for ((i=1; i<=${NUM_RUNS}; i++))
  do

    seed=$(((RANDOM % 999999999 )  + 100000000))

    echo "Running simulation for test '${test}' with seed ${seed} ($i/$NUM_RUNS)."
    xrun -lwdgen -access rwc -uvm -uvmhome $UVMHOME -svseed $seed -coverage all -sv -f file_list.f +UVM_VERBOSITY=UVM_DEBUG

    #cp -r cov_work cov_work_temp

    echo "Merging coverage from test '${test}' with seed ${seed} ($i/$NUM_RUNS)."
    imc -execcmd "merge cov_work/scope/merged cov_work/scope/test_sv${seed} -out cov_work/scope/merged -overwrite -metrics all -initial_model union_all"

    echo "Done with test '${test}' with seed ${seed} ($i/$NUM_RUNS)."
  done

done