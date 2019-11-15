#!/bin/bash

# Create clients on two different IBC nodes

# Each chain needs to have an RPC endpoint to run transactions against
NODE0="http://127.0.0.1:26657"
NODE1="http://127.0.0.1:16657"

# Input the two chains you would like to begin connecting CHAINID0 should be "your" chain
CHAINID0="chainl1"
CHAINID1="chainl2"

# For spec compatability we will only use letter characters for some identifiers
ANCID0="ibczero"
ANCID1="ibcone"

# I've taken the naming convention "{{ .ChainID }}client" for clients. Note that the `testnetibc1client` is created on `testnetibc0`
CLIENT0="${ANCID1}client"
CLIENT1="${ANCID0}client"

# Note, the account key creating these transactions must have tokens on each chain
KEY0="faucet"
KEY1="faucet"

# Name for connection strings
CONNID0="${ANCID1}conn"
CONNID1="${ANCID0}conn"

# Name for channel strings
CHANID0="${ANCID1}chan"
CHANID1="${ANCID0}chan"
CHANTYPE="bank"

# Create testnetibc1client on testnetibc0
gaiacli tx ibc client create $CLIENT0 --chain-id $CHAINID0 --node $NODE0 $(gaiacli q ibc client node-state --node $NODE1 --chain-id $CHAINID1 -o json) --from $KEY0 -o text


# Create testnetibc0client on testnetibc1
gaiacli tx ibc client create $CLIENT1 --chain-id $CHAINID1 --node $NODE1 $(gaiacli q ibc client node-state --node $NODE0 --chain-id $CHAINID0 -o json) --from $KEY1 -o text

sleep 5

# Query clients on both nodes:
gaiacli --node $NODE0 --chain-id $CHAINID0 q ibc client consensus-state $CLIENT0 --indent
gaiacli --node $NODE1 --chain-id $CHAINID1 q ibc client consensus-state $CLIENT1 --indent

# Create the connection:
gaiacli \
tx ibc connection handshake \
--node $NODE0 --chain-id $CHAINID0 \
$CONNID0 $CLIENT0 $(gaiacli q ibc client path --node $NODE1 --chain-id $CHAINID1) \
$CONNID1 $CLIENT1 $(gaiacli q ibc client path --node $NODE0 --chain-id $CHAINID0) \
--chain-id2 $CHAINID1 \
--from1 $KEY0 --from2 $KEY1 \
--node1 $NODE0 \
--node2 $NODE1

# Query the connetion from both nodes:
gaiacli --node $NODE0 q ibc connection end $CONNID0 --indent --trust-node
gaiacli --node $NODE1 q ibc connection end $CONNID1 --indent --trust-node

sleep 3

# Create the channel:
gaiacli \
tx ibc channel handshake \
--node $NODE0 --chain-id $CHAINID0 \
$CLIENT0 $CHANTYPE $CHANID0 $CONNID0 \
$CLIENT1 $CHANTYPE $CHANID1 $CONNID1 \
--node1 $NODE0 \
--node2 $NODE1 \
--chain-id2 $CHAINID1 \
--from1 $KEY0 --from2 $KEY1

# Query the channel from both nodes:
gaiacli --node $NODE0 --chain-id $CHAINID0 q ibc channel end $CHANTYPE $CHANID0 --indent --trust-node
gaiacli --node $NODE1 --chain-id $CHAINID1 q ibc channel end $CHANTYPE $CHANID1 --indent --trust-node
