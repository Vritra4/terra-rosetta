FROM ubuntu:latest AS builder

RUN set -eux; apt update; apt install -y build-essential ca-certificates git curl

# NOTE: add these to run with LEDGER_ENABLED=true
# RUN apk add libusb-dev linux-headers

# install golang
ADD https://go.dev/dl/go1.17.6.linux-amd64.tar.gz /root/go1.17.6.linux-amd64.tar.gz
RUN tar -C /usr/local -xzf /root/go1.17.6.linux-amd64.tar.gz
RUN cp -fp /usr/local/go/bin/* /bin/

# build core

RUN git clone https://github.com/terra-money/core.git -b feature/rosetta /code

WORKDIR /code

RUN LEDGER_ENABLED=false make build

RUN go env

FROM ubuntu:latest

RUN apt-get update 
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y wget lz4 aria2 curl jq gawk python3 python3-pip
RUN pip install toml-cli

WORKDIR /root

COPY --from=builder /root/go/pkg/mod/github.com/\!cosm\!wasm/wasmvm@v*/api/libwasmvm.so /lib/libwasmvm.so
COPY --from=builder /code/build/terrad /usr/local/bin/terrad

ARG MONIKER
ENV MONIKER=${MONIKER:-coinbase-node}

ARG MODE
ENV MODE=${MODE:-online}

ARG NETWORK 
ENV NETWORK=${NETWORK:-testnet}

# rest server
EXPOSE 1317
# grpc
EXPOSE 9090
# tendermint p2p
EXPOSE 26656
# tendermint rpc
EXPOSE 26657
# rosetta
EXPOSE 8080

RUN wget -O ~/testnet.genesis.json https://raw.githubusercontent.com/terra-money/testnet/master/bombay-12/genesis.json
RUN wget -O ~/mainnet.genesis.json https://columbus-genesis.s3.ap-northeast-1.amazonaws.com/columbus-5-genesis.json

RUN terrad init $MONIKER

ADD entrypoint.sh ./entrypoint.sh
ENTRYPOINT [ "./entrypoint.sh" ]

CMD [ "/usr/local/bin/terrad", "start", "--x-crisis-skip-assert-invariants" ]
