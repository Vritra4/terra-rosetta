docker run -d -p 1317:1317 -p 26657:26657 -p 26656:26656 -p 8081:8080 -e NETWORK=mainnet -e MAX_OUTBOUND=40 --name terra-mainnet-default terramoney/rosetta:0.4
