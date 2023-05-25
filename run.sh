#!/usr/bin/env bash

# This script is used to run the Non3GPP-UE

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CODE_DIR="$SCRIPT_DIR/NWu-Non3GPP-5GC"

# UE Configuration
DNN="internet"
UE_IP="192.168.2.238"
N3IWF_IP="192.168.2.179"
MCC=901
MNC=70
IMSI="901700000031744"
K="D479154A5C1D129F7F7665D49124F798"
OPC="F58F5C0205481B0C4E80CB3438DEAE01"
NAMESPACE="ue"
MTU=1300

# Run UE
cd $SCRIPT_DIR
source env/bin/activate
cd $CODE_DIR
python3 nwu_emulator.py \
    -a $DNN \
    -d $N3IWF_IP \
    -s $UE_IP \
    -M $MCC \
    -N $MNC \
    -I $IMSI \
    -K $K \
    -C $OPC \
    -n $NAMESPACE \
    -U $MTU \
    -F
