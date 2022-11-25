## Steps

### Start local blockchain

1. `docker-compose -f tokentransfer.yml up checkersa`

### Start relayer and tx

1. Complete [relayer_hermes/theta.json](relayer_hermes/theta.json)
2. Start relayer `docker-compose -f tokentransfer.yml up --build relayer_hermes`
3. Start terminal in the relayer container with `docker exec -it relayer bash` and then run the commands one by one from [relayer_hermes/run-relayer.sh](relayer_hermes/run-relayer.sh) replacing values in *--src-channel*, *--denom* and *--receiver*.
4. Verify your new balance https://explorer.theta-testnet.polypore.xyz/
