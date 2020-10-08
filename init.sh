#!/usr/bin/env bash

rm -rf ~/.appd
rm -rf ~/.appcli

appd init test --chain-id=namechain

appcli config output json
appcli config indent true
appcli config trust-node true
appcli config chain-id namechain
appcli config keyring-backend test

appcli keys add user1
appcli keys add user2

appd add-genesis-account $(appcli keys show user1 -a) 1000nametoken,100000000stake
appd add-genesis-account $(appcli keys show user2 -a) 1000nametoken,500000000stake

appd gentx --name user1 --keyring-backend test

echo "Collecting genesis txs..."
appd collect-gentxs

echo "Validating genesis file..."
appd validate-genesis