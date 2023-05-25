#!/usr/bin/env bash

# This script is used to setup the virtual environment for the Non3GPP-UE

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $SCRIPT_DIR

# Create virtual environment (if it doesn't exist in the current directory)
if [ ! -d "env" ]; then
    python3 -m venv env
fi

# Activate virtual environment
source env/bin/activate

# Install required packages
pip install -r requirements.txt

# Check if "card" and "CryptoMobile" are cloned in the packages directory
if [ ! -d "packages/card" ]; then
    git clone https://github.com/mitshell/card.git
    mv card packages/
fi

if [ ! -d "packages/CryptoMobile" ]; then
    git clone https://github.com/mitshell/CryptoMobile.git
    mv CryptoMobile packages/
fi

# Install "card" from source
cd $SCRIPT_DIR/packages/card
python setup.py install

# Install "CryptoMobile" from source
cd $SCRIPT_DIR/packages/CryptoMobile
python setup.py install
