docker run -d -p 2317:1317 -p 27657:26657 -p 27656:26656 -p 9080:8080 -e NETWORK=testnet -e MAX_OUTBOUND=40 --name terra-testnet terramoney/rosetta:0.4
