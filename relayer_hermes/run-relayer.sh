#!/bin/sh

hermes keys add --chain checkersa --mnemonic-file "alice.json"
hermes keys add --chain theta-testnet-001 --mnemonic-file "theta.json"

hermes create channel --a-chain checkersa --b-chain theta-testnet-001 --a-port transfer --b-port transfer --new-client-connection # check both ChannelId from checkersa and theta-testnet-001 in the output
hermes start

# replace denom and receiver with correct parameters
hermes tx ft-transfer --src-chain checkersa --dst-chain theta-testnet-001 --src-port transfer --src-channel channel-0 --amount 1 --denom token1yyfk5cjdman0uxzln8quampnmnddsqqxks2nen --timeout-height-offset 1000 --receiver cosmos1yyfk5cjdman0uxzln8quampnmnddsqqxks2nen

# replace channel-1 with checkersa side channel
hermes tx packet-recv --dst-chain theta-testnet-001 --src-chain checkersa --src-port transfer --src-channel channel-0

# replace channel-1068 with channel from theta testnet side (returned in create channel command logs)
hermes tx packet-ack --dst-chain checkersa --src-chain theta-testnet-001 --src-port transfer --src-channel channel-1079
