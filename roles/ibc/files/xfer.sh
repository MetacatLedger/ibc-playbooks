# Create clients on two different IBC nodes

set -x

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

# Name for channel strings
CHANID0="${ANCID1}chan"
CHANID1="${ANCID0}chan"
CHANTYPE="bank"
PASS="12345678"

# Amount to send
AMOUNT="10stake"
SEQUENCE="1"

echo "Send packets from $CHAINID0, they will need to be recieved on $CHAINID1 in another transaction"

echo -e '12345678\n' | gaiacli --node $NODE0 --chain-id $CHAINID0 tx ibc transfer transfer $CHANTYPE $CHANID0 $(gaiacli keys show $KEY0 -a) $AMOUNT --from $KEY0 --source --yes

echo "Enter height:"

#read -r HEIGHT
HEIGHT=0 # Why are we asking this?

TIMEOUT=$(echo "$HEIGHT + 1000" | bc -l)

sleep 3

echo "Balance on $CHAINID1 before transfer:"

gaiacli --node $NODE1 --chain-id $CHAINID1 q account $(gaiacli keys show $KEY1 -a) --indent --trust-node

echo "Create transaction to recieve tokens on $CHAINID1"

sleep 5

gaiacli tx ibc transfer recv-packet \
  $CHANTYPE $CHANID0 $CLIENT1 \
  --node $NODE1 \
  --chain-id $CHAINID1 \
  --packet-sequence $SEQUENCE \
  --timeout $TIMEOUT \
  --from $KEY1 \
  --node2 $NODE0 \
  --chain-id2 $CHAINID0 \
  --source --yes

echo "Balance on $CHAINID1 after transfer:"

gaiacli --node $NODE1 --chain-id $CHAINID1 q account $(gaiacli keys show $KEY1 -a) --indent --trust-node
