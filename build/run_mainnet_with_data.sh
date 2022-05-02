docker run -d -p 1317:1317 -p 26657:26657 -p 26656:26656 -p 9080:8080 -e MAX_OUTBOUND=40 -e NETWORK=mainnet -v "$(pwd)"/data:/root/.terra/data  --name terra-mainnet terramoney/rosetta:0.4
