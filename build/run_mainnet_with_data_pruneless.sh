docker run -d -p 1317:1317 -p 26657:26657 -p 26656:26656 -p 8080:8080 -e NO_PRUNE=true -e MAX_OUTBOUND=40 -v "$(pwd)"/data:/root/.terra/data --name terra-mainnet terramoney/rosetta-mainnet:0.2
