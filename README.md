# cosmos-blockchains-ibc-communication

## Description

This is the IBC operations part of the exam for the second cohort of the ICF academy (Cosmos Academy 2022 https://academy.cosmos.network/)


>IBC operations
>This is the IBC operations part of the exam for the second cohort of the ICF academy.
>For this exercise, you have to:
>
>Set up an IBC relayer between a Cosmos blockchain on your local computer and the Cosmos Hub's Theta public testnet (theta-testnet-001).
>Send tokens from your local chain across to a precise recipient on Theta.
>
>To test that you have completed the task:
>
>We use identifiers that are unique to you. The identifiers are:
>
>The recipient on Theta to which you have to send some tokens is <StudentInfo.addressRecipient>. This is where you have to send the tokens.
>On your local blockchain, the denomination of the token you have to send to the recipient is <StudentInfo.homeDenom>. This is one of the denoms on your local blockchain.
>
>
>We only check the recipient's balances on the testnet. This means you are free to decide how you reach this goal.
>
>We are looking for a balance with a denom that is ibc/${sha256Of("transfer/channel-A-NUMBER/<StudentInfo.homeDenom>")} and an amount strictly greater than 0.
>We are agnostic as to what channel number you are using as long as it is between 1 and 10,000 inclusive. If your channel number is any different, you should alert us, for instance on Discord.
>
>Some pointers to assist you along the way:
>
>Your local chain has to declare a token with the <StudentInfo.homeDenom> denom. This token does not need to be the staking token.
>Your local chain can declare other denoms such as stake too, but that is irrelevant for the exercise.
>If you use Ignite to start your local blockchain, have a look at config.yml to declare new denoms.
>If you use a compiled version, like simd, have a look at the genesis to declare new denoms.
>To get testnet tokens, ask the faucet here. You need an account on the testnet in order to pay the fees.
>To find a Theta testnet RPC end point, look here. At the time of writing, sentry--02 was working well.
>We recommend the use of the Hermes relayer for this assignment. You can use the ws://rpc.state-sync-02.theta-testnet.polypore.xyz:26657/websocket endpoint for the websocker_addr in the Hermes configuration. Remember to adjust the gas prices to be uatom.
>To see the balances of your recipient, and confirm your success, head to a block explorer, for instance here.
>When you have established the IBC channel, and have its channelId, you can find out the denom that will be created when you transfer tokens. Go here and input the string transfer/channel-channelId/<StudentInfo.homeDenom>.
>
>Good luck.

## Solution

The steps to solve this exercise are:

1. Start a local blockchain (made with Cosmos SDK) and create a custom token.
2. Start a relayer (Hermes) between the previous blockchain and a known testnet (theta-testnet-001)
3. Send the tokens
4. Validate that the tokens in the receiver account

### Start local blockchain and create a custom token

You can create a blockchain following this guide https://tutorials.cosmos.network/hands-on-exercise/1-ignite-cli/1-ignitecli.html or using the blockchain "checkersa" from this repository https://github.com/b9lab/cosmos-ibc-docker. I used the last one [comos-ibc/checkers](comos-ibc/checkers).

After that, update this file [checkers/configa.yml](checkers/configa.yml) adding your custom token. In my case the token was "token1yyfk5cjdman0uxzln8quampnmnddsqqxks2nen" and I added 20000 to "alice" (line 3) account and 10000 to "bob" account (line 6). Optionally, you can configure the maximum amount of token that the faucet can give (line 18) from "bob" account. 

This file will be used here [checkers/Dockerfile](checkers/Dockerfile) to override the default configuration so you have to build the new Docker Image before starting the container:

 `docker-compose -f tokentransfer.yml up --build checkersa`

### Start the relayer (Hermes)

1. Download the Keplr wallet https://www.keplr.app/, create an account and export your seed phrase. Add it here [relayer_hermes/theta.json](relayer_hermes/theta.json)
2. Ask for some *uatom* in this discord faucet [https://discord.com/channels/669268347736686612/953697793476821092](https://discord.com/channels/669268347736686612/953697793476821092): send a message like this **$request address_goes_here theta**. Wait until you get it.
3. Even though it's configured you can check the custom configuration of the relayer here [relayer_hermes/config.toml](relayer_hermes/config.toml), for example, the section called **[[chains]]** (line 241).
4. Build the Docker image and start the container using the command: `docker-compose -f tokentransfer.yml up --build relayer_hermes`

### Configure the relayer

Start a new terminal in the relayer container with the command `docker exec -it relayer bash` and then configure the relayer

#### Adding private keys

*For each chain configured you need to add a private key for that chain in order to submit transactions.*

1. Add the seed phrase that has your custom tokens in the local blockchain. In my case is the seed phrase of "alice" account used in my "checkersa" blockchain: `hermes keys add --chain checkersa --mnemonic-file "alice.json"`

2. Insert the seed phrase of the account created using Keplr here [theta.json](theta.json) and add it to hermes: `hermes keys add --chain theta-testnet-001 --mnemonic-file "theta.json"`

#### Create a channel between your local blockchain and the testnet

*Connections and clients comprise the main components of the transport layer in IBC. However, application to application communication in IBC is conducted over channels, which route between an application module such as the module which handles Interchain Standard (ICS) 20 token transfers on one chain, and the corresponding application module on another one.*

1. Create the channel between the blockchains
`hermes create channel --a-chain checkersa --b-chain theta-testnet-001 --a-port transfer --b-port transfer --new-client-connection`
2. Copy both channel ids from your local blockchain and the testnet (it's below the message "Success: Channel").
3. Start the relayer with the command: `hermes start`

#### Fungible token transfer

**Now we will transfer some tokens**

1. Send packet with the command `hermes tx ft-transfer --src-chain checkersa --dst-chain theta-testnet-001 --src-port transfer --src-channel channel-0 --amount 1 --denom token1yyfk5cjdman0uxzln8quampnmnddsqqxks2nen --timeout-height-offset 1000 --receiver cosmos1yyfk5cjdman0uxzln8quampnmnddsqqxks2nen`. Remember to replace there the values of:

- --src-chain
- --dst-chain
- --src-channel 
- --amount
- --denom
- --receiver: the account that will receive the token. You can create a new account with Keplr wallet. 

2. Send recv_packet to the testnet with the command `hermes tx packet-recv --dst-chain theta-testnet-001 --src-chain checkersa --src-port transfer --src-channel channel-0`

- --src-chain
- --dst-chain
- --src-channel 

3. Send ack to the local blockchain with the command `hermes tx packet-ack --dst-chain checkersa --src-chain theta-testnet-001 --src-port transfer --src-channel channel-1079`

- --src-chain
- --dst-chain
- --src-channel 

4. Verify your new balance checking the receiver account here https://explorer.theta-testnet.polypore.xyz/. You can check there the new balance and the transaction, in my case it was https://explorer.theta-testnet.polypore.xyz/transactions/03136FBAF877B57B79C9A232CDA573D82BAF5D10022E8A74F1517CC60ED4CB5A. 