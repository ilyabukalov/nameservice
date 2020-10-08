#!/bin/bash

appcli query account $(appcli keys show user1 -a) | jq ".value.coins[0]"
appcli query account $(appcli keys show user2 -a) | jq ".value.coins[0]"

# Buy your first name using your coins from the genesis file
appcli tx nameservice buy-name user1.id 5nametoken --from user1 -y | jq ".txhash" |  xargs $(sleep 6) appcli q tx

# Set the value for the name you just bought
appcli tx nameservice set-name user1.id 8.8.8.8 --from user1 -y | jq ".txhash" |  xargs $(sleep 6) appcli q tx

# Try out a resolve query against the name you registered
appcli query nameservice resolve user1.id | jq ".value"
# > 8.8.8.8

# Try out a whois query against the name you just registered
appcli query nameservice whois user1.id
# > {"value":"8.8.8.8","owner":"cosmos1l7k5tdt2qam0zecxrx78yuw447ga54dsmtpk2s","price":[{"denom":"nametoken","amount":"5"}]}

# Alice buys name from user1
appcli tx nameservice buy-name user1.id 10nametoken --from user2 -y | jq ".txhash" |  xargs $(sleep 6) appcli q tx

# Alice decides to delete the name she just bought from user1
appcli tx nameservice delete-name user1.id --from user2 -y | jq ".txhash" |  xargs $(sleep 6) appcli q tx

# Try out a whois query against the name you just deleted
appcli query nameservice whois user1.id
# > {"value":"","owner":"","price":[{"denom":"nametoken","amount":"1"}]}