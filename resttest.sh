# Get the sequence and account numbers for user1 to construct the below requests
curl -s http://localhost:1317/auth/accounts/$(appcli keys show user1 -a)
# > {"type":"auth/Account","value":{"address":"cosmos127qa40nmq56hu27ae263zvfk3ey0tkapwk0gq6","coins":[{"denom":"user1Coin","amount":"1000"},{"denom":"nametoken","amount":"1010"}],"public_key":{"type":"tendermint/PubKeySecp256k1","value":"A9YxyEbSWzLr+IdK/PuMUYmYToKYQ3P/pM8SI1Bxx3wu"},"account_number":"0","sequence":"1"}}

# Get the sequence and account numbers for user2 to construct the below requests
curl -s http://localhost:1317/auth/accounts/$(appcli keys show user2 -a)
# > {"type":"auth/Account","value":{"address":"cosmos1h7ztnf2zkf4558hdxv5kpemdrg3tf94hnpvgsl","coins":[{"denom":"user2Coin","amount":"1000"},{"denom":"nametoken","amount":"980"}],"public_key":{"type":"tendermint/PubKeySecp256k1","value":"Avc7qwecLHz5qb1EKDuSTLJfVOjBQezk0KSPDNybLONJ"},"account_number":"1","sequence":"2"}}

# Buy another name for user1, first create the raw transaction
# NOTE: Be sure to specialize this request for your specific environment, also the "buyer" and "from" should be the same address
curl -X POST -s http://localhost:1317/nameservice/whois --data-binary '{"base_req":{"from":"'$(appcli keys show user1 -a)'","chain_id":"namechain"},"name":"user1.id","price":"5nametoken","buyer":"'$(appcli keys show user1 -a)'"}' > unsignedTx.json

# Then sign this transaction
# NOTE: In a real environment the raw transaction should be signed on the client side. Also the sequence needs to be adjusted, depending on what the query of user2's account has shown.
appcli tx sign unsignedTx.json --from user1 --offline --chain-id namechain --sequence 0 --account-number 0 > signedTx.json

# And finally broadcast the signed transaction
appcli tx broadcast signedTx.json
# > { "height": "266", "txhash": "C041AF0CE32FBAE5A4DD6545E4B1F2CB786879F75E2D62C79D690DAE163470BC", "logs": [  {   "msg_index": "0",   "success": true,   "log": ""  } ],"gas_wanted":"200000", "gas_used": "41510", "tags": [  {   "key": "action",   "value": "buy_name"  } ]}

# Set the data for that name that user1 just bought
# NOTE: Be sure to specialize this request for your specific environment, also the "owner" and "from" should be the same address
curl -X PUT -s http://localhost:1317/nameservice/whois --data-binary '{"base_req":{"from":"'$(appcli keys show user1 -a)'","chain_id":"namechain"},"name":"user1.id","value":"8.8.4.4","owner":"'$(appcli keys show user1 -a)'"}' > unsignedTx.json
# > {"check_tx":{"gasWanted":"200000","gasUsed":"1242"},"deliver_tx":{"log":"Msg 0: ","gasWanted":"200000","gasUsed":"1352","tags":[{"key":"YWN0aW9u","value":"c2V0X25hbWU="}]},"hash":"B4DF0105D57380D60524664A2E818428321A0DCA1B6B2F091FB3BEC54D68FAD7","height":"26"}

# Again we need to sign and broadcast
appcli tx sign unsignedTx.json --from user1 --offline --chain-id namechain --sequence 2 --account-number 0 > signedTx.json
appcli tx broadcast signedTx.json

# Query the value for the name user1 just set
$ curl -s http://localhost:1317/nameservice/whois/user1.id/resolve
# 8.8.4.4

# Query whois for the name user1 just bought
$ curl -s http://localhost:1317/nameservice/whois/user1.id
# > {"value":"8.8.8.8","owner":"cosmos127qa40nmq56hu27ae263zvfk3ey0tkapwk0gq6","price":[{"denom":"STAKE","amount":"10"}]}

# user2 buys name from user1
$ curl -X POST -s http://localhost:1317/nameservice/whois --data-binary '{"base_req":{"from":"'$(appcli keys show user2 -a)'","chain_id":"namechain"},"name":"user1.id","amount":"10nametoken","buyer":"'$(appcli keys show user2 -a)'"}' > unsignedTx.json

# Again we need to sign and broadcast
# NOTE: The account number has changed to 1 and the sequence is now 2, according to the query of user2's account
appcli tx sign unsignedTx.json --from user2 --offline --chain-id namechain --sequence 2 --account-number 1 > signedTx.json
appcli tx broadcast signedTx.json
# > { "height": "1515", "txhash": "C9DCC423E10E7E5E40A549057A4AA060DA6D6A885A394F6ED5C0E40AEE984A77", "logs": [  {   "msg_index": "0",   "success": true,   "log": ""  } ],"gas_wanted": "200000", "gas_used": "42375", "tags": [  {   "key": "action",   "value": "buy_name"  } ]}

# Now, user2 no longer needs the name she bought from user1 and hence deletes it
# NOTE: Only the owner can delete the name. Since she is one, she can delete the name she bought from user1
$ curl -XDELETE -s http://localhost:1317/nameservice/names --data-binary '{"base_req":{"from":"'$(appcli keys show user2 -a)'","chain_id":"namechain"},"name":"user1.id","owner":"'$(appcli keys show user2 -a)'"}' > unsignedTx.json

# And a final time sign and broadcast
# NOTE: The account number is still 1, but the sequence is changed to 3, according to the query of user2's account
appcli tx sign unsignedTx.json --from user2 --offline --chain-id namechain --sequence 3 --account-number 1 > signedTx.json
appcli tx broadcast signedTx.json

# Query whois for the name user2 just deleted
$ curl -s http://localhost:1317/nameservice/names/user11.id/whois
# > {"value":"","owner":"","price":[{"denom":"STAKE","amount":"1"}]}
