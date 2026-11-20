#!/bin/bash
# file: test_DCHdigi.sh
# author: Alvaro Tolosa-Delgado, CERN 2024
# to run: sh + test_DCHdigi.sh
# goal: run sim-digitizer of the DCH v2, and return code printed by check_DCHdigi_output.py

dir=`dirname $0`

# clean up previous output files
rm -f dch_proton_10GeV.root

# run simulation with the drift chamber alone
rm -f compact
ln -sf $dir/compact .
echo aaa ddsim --steeringFile $dir/sim_steering.py --outputFile 'dch_proton_10GeV.root' -N 10 --runType batch --random.seed 42
ddsim --steeringFile $dir/sim_steering.py --outputFile 'dch_proton_10GeV.root' -N 10 --runType batch --random.seed 42

# download file for cluster counting technique
ifilename="https://fccsw.web.cern.ch/fccsw/filesForSimDigiReco/IDEA/DataAlgFORGEANT.root"
# -nc, --no-clobber: skip downloads that would download to existing files
wget --no-clobber $ifilename

# Check if the input file exists
if [[ ! -f "$(basename $ifilename)" ]]; then
    echo "Error: File '$(basename $ifilename)' not found."
    exit 1
fi

# run digitizer for position smearing and cluster counting calculation
k4run $dir/runDCHdigi.py

# check distribution of distance from hit position to the wire
python3 $dir/check_DCHdigi_output.py
