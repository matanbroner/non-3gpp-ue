# Creating a Non-3GPP Session

## Description
This document describes the procedure for creating a Non-3GPP session. It expects that you are using the Open5GS-Free5GC combination as developed in 5G-MANTRA.

## Prerequisites
- Open5GS network functions running (for 5G SA exclusively)
    - AMF
    - SMF
    - UPF
    - PCF
    - UDR
    - NRF
    - NSSF
    - AUSF
    - UDM
    - UDR
    - BSF
    - SCP


If you are intending to create a 4G-LTE 3GPP session as well, run the remaining Open5GS network functions:
- HSS
- MME
- SGW-C
- SGW-U
- PCRF

Refer to the `run-open5gs.sh` script in the `script` folder of the `5G-Core-Network` LENSS repository for an example of how to run the Open5GS network functions. 

It is important to follow this script as it sets up necessary routing table rules and IP addresses for the network functions to not have clashing IPs and for traffic to be forwarded properly.

## Setup
Refer to the `Makefile` located in the `5G-Core-Network` LENSS repository for an understanding of how the core network environment is set up.
In short, you require the following:
- MongoDB
- Python3
- Python3-pip
- GoLang
- NodeJS (ideally through NVM)

### Running the Setup
You can use the `Makefile` to set up your environment. Note that the file only works on Ubuntu and Arch Linux at the moment.
```bash
make init-mongodb # Installs MongoDB
make validate # Validates that MongoDB, Go, Python3, and NodeJS are installed
make init # Clones submodules and builds the core, copying configuration files as needed
make start # Starts the core network as background processes
make stop # Stops the core network
```

If you are using the `Makefile` to run the core, you can run `script/run-bg-process.sh` to see the active status of all network functions, and tails their logs.

## Configuration Files Used
Open5GS has updated its configuration file template since we first began experimentation. As such, we have a set of frozen "stable configs" that we use for our experiments. These are located in the `config` folder of the `open5gs` LENSS repository. 

Free5GC only has one configuraiton file that we currently manage, which is located in the `config` folder of the `free5gc` LENSS repository as `n3iwfcfg.yaml`.

You will need to update configurations including but not limited to:
- IP addresses
- MongoDB connection strings
- Location of other NFs (ex. N3WIF needs to know where AMF is)
- Log file locations

Be sure to walk through each configuration file and update it as needed.

## Running the Non-3GPP Client
We wrap the Non-3GPP Client located at `https://github.com/fasferraz/NWu-Non3GPP-5GC`. Our client repository is located at `https://github.com/matanbroner/non-3gpp-ue`. 
You can use the `setup.sh` script to install the dependencies and set up the virtual environment. You can then run the client using the `run.sh` script.
Before running the client, you need to register a UE with the 5G core network. You will then need to have the following information to replace in `run.sh`:
- UE IMSI
- UE Key (K)
- UE OPc (OPC)
- UE IP 
    - This is the IP address of the UE, and should be the IP of your WiFi interface (or a virtual IP attached to said interface) in order to make sure that non-3GPP traffic is routed through the WiFi AP.
- N3IWF IP (`IKEBindAddress` in `free5gc/n3iwfcgf.yaml`)
- MCC (default is 901)
- MNC (default is 70)

When you execute the `run.sh` script, you will see the dialer run through seven states, each with a header `STATE: <state>`. When you see `Signaling SA CHILD created. Esatblishing TCO session towards NAS..`, the dialer may hang for a few seconds. Do not be worried. After the wait, you should see a few instances of `STATE 7` and a message similar to the following:

```
STATE 7:
--------
...
...
USERPLANE SESSION IPV4 ADDRESS: 10.45.0.2
...
...
cmd: ip netns exec ue ip link set dev tun3 up
...
...
```
This means that the Non-3GPP session has been established. A tunnel interface has been created to send IPSec encrypted data to the UPF.

Note that the script tells the dialer to create the data plane access tunnel in a seperate namespace, `ue`. As such, you will not see the generated tunnel interface when you simply run `ip a`. In order to use the tunnel interface, you will need to run `ip netns exec ue ip a` to see the interface. You can then use `ip netns exec ue <command>` to run commands in the `ue` namespace.

For example, to ping google.com over the tunnel interface (assuming it is named `tun3`), you would run:
```bash
ip netns exec ue ping -I tun3 google.com
```

The author of the dialer has stated that there are issues where an MTU above 1500 causes the N3IWF to crash. As such, after creating the tunnel, run the following command to set the tunnel's MTU to 1300:
```bash
ip netns exec ue ip link set tun3 mtu 1300
```

## FAQ (Debug)

### I cannot create a session after quitting a previous session.
The N3IWF and AMF need to be restarted after a session is terminated. This is a known issue with the N3IWF. You can optionally just restart the entire core network.

### Traffic is not going to the internet.
First be sure that you can reach the core network machine using your tunnel:

```bash
ip netns exec ue ping -I tun3 <core network machine IP>
```

If this works, you likely did not set up your `iptables` rules properly when starting the core network. See the `run-open5gs.sh` script in the `script` folder of the `5G-Core-Network` LENSS repository for an example of how to set up the rules.
