#!/usr/bin/bash

# Default to "data".
DATADIR="${DATADIR:-/root/.terra/data}"
MONIKER="${MONIKER:-coinbase-node-$RANDOM}"
ENABLE_LCD="${ENABLE_LCD:-true}"
MINIMUM_GAS_PRICES="${MINIMUM_GAS_PRICES:-0.01133uluna,0.104938usdr,0.15uusd,169.77ukrw,428.571umnt,0.125ueur,0.98ucny,16.37ujpy,0.11ugbp,10.88uinr,0.19ucad,0.14uchf,0.19uaud,0.2usgd,4.62uthb,1.25usek,1.25unok,0.9udkk,2180.0uidr,7.6uphp,1.17uhkd,0.6umyr,4.0utwd}"
SNAPSHOT_NAME="${SNAPSHOT_NAME}"
SNAPSHOT_BASE_URL="${SNAPSHOT_BASE_URL:-https://get.quicksync.io}"
RETRIES="${RETRIES:-100}"
MAX_OUTBOUND="${MAX_OUTBOUND:-40}"
SUGGEST_GAS="${SUGGEST_GAS:-200000}"
SUGGEST_DENOM="${SUGGEST_DENOM:-uluna}"

if [ "$NETWORK" = "mainnet" ]; then
	export CHAINID=columbus-5 
elif [ "$NETWORK" = "testnet" ]; then
	export CHAINID=bombay-12 
else
	echo invalid network type: $NETWORK
	exit	
fi

# Backup for templating
mv ~/.terra/config/config.toml ~/config.toml
mv ~/.terra/config/app.toml ~/app.toml

# copy genesis
if [ "$NETWORK" = "mainnet" ]; then
	cp -fp ~/mainnet.genesis.json ~/.terra/config/genesis.json
else 
	cp -fp ~/testnet.genesis.json ~/.terra/config/genesis.json
fi

if [ "$MODE" = "offline" ]; then
	export IS_OFFLINE=true
else
	export IS_OFFLINE=false
fi


# First sed gets the app.toml moved into place.
# app.toml updates
sed 's/minimum-gas-prices = "0uluna"/minimum-gas-prices = "'"$MINIMUM_GAS_PRICES"'"/g' ~/app.toml > ~/.terra/config/app.toml

# Needed to use awk to replace this multiline string.
if [ "$ENABLE_LCD" = true ] ; then
  toml set --toml-path ~/.terra/config/app.toml api.enable true
fi

# rosetta config updates
toml set --toml-path ~/.terra/config/app.toml rosetta.enable true
sed -i 's/^denom-to-suggest = "uatom"/denom-to-suggest = "uluna"/g' ~/.terra/config/app.toml
sed -i 's/^blockchain = "app"/blockchain = "terra"/g' ~/.terra/config/app.toml
sed -i "s/^network = \"network\"/network = \"${CHAINID}\"/g" ~/.terra/config/app.toml
sed -i "s/^offline = false/offline = ${IS_OFFLINE}/g" ~/.terra/config/app.toml
sed -i "s/^retries = 3/retries = ${RETRIES}/g" ~/.terra/config/app.toml
sed -i "s/^enable-fee-suggestion = false/enable-fee-suggestion = true/g" ~/.terra/config/app.toml

if [ "$NO_PRUNE" = true ]; then
	# prune nothing
	sed -i 's/^pruning = "default"/pruning = "nothing"/g' ~/.terra/config/app.toml
fi

# config.toml updates
#sed 's/moniker = "moniker"/moniker = "'"$MONIKER"'"/g' ~/config.toml > ~/.terra/config/config.toml
sed 's/laddr = "tcp:\/\/127.0.0.1:26657"/laddr = "tcp:\/\/0.0.0.0:26657"/g' ~/config.toml > ~/.terra/config/config.toml

# more outbound peers..
sed -i "s/^max_num_outbound_peers = 10/max_num_outbound_peers = ${MAX_OUTBOUND}/g" ~/.terra/config/config.toml

if [ "$IS_OFFLINE" = false ]; then
	if [ "$NETWORK" = "mainnet" ]; then
		sed -i 's/^seeds = ""/seeds = "e999fc20aa5b87c1acef8677cf495ad85061cfb9@seed.terra.delightlabs.io:26656,6d8e943c049a80c161a889cb5fcf3d184215023e@public-seed2.terra.dev:26656,87048bf71526fb92d73733ba3ddb79b7a83ca11e@public-seed.terra.dev:26656,3ddf51347ba7c2bc4a8e1e26ee9d1cbf81034516@162.55.244.250:27656,5618b310cfac1271a34f5c38576a5dceb1a641e6@162.55.132.48:15606,58c9a742184ff7d0bdd65315cf6ea8fab462d66f@162.55.131.238:15606,7cd549f6dab19000c260336c1a34479f8ff42964@54.154.91.139:26656,6ddd22cca53d2f0d03043614fc9f76acc72def8c@seed.terra-mainnet.everstake.one:26656,8026dbfb33bf83a2b8989c96c82c983070d26e40@35.86.26.38:26656,e5daf41330c94ea81e80a3c52e52baa1b6d14fe1@terra-mainnet.0base.vc:26656,12e5d8f3602f63644cf548ffc83d886b5715a29f@kenaz.coinbevy.com:26656,c94edbb749dccc61558049c8050cdac95c894cc9@35.227.90.116:26656,1600175a7a05f67ee0231cd94d24e7d1eb52ba53@terra-seed-mainnet.blockngine.io:26676,65d86ab6024153286b823a3950e9055478effb04@terra.inotel.ro:26656,42928a07c8fe3313cfbfba78f296bf713e12a0a1@seed-columbus.terra.01node.com:26656,2b5ecb577e0fec2f15bc6c855dfe158f072a32a8@mnet-seed.terra.nitawa.systems:26656,73ff2b4253a8cc44d7527364ccfa220a60091298@3.237.91.53:26656,66aa2bac58b137e17865035567fc85f06953d4af@terra-seed01.stakers.finance:26656,2934a56f925fe7e7dcbe8ad0de10ae23791cf9b3@65.108.72.121:26656,235b5e97d7932e72fc846adcc712cd71e2a1b1be@seed.terra.lunarnode.org:26656,21eb4b16acaacea0c09a68faf73e618c6318aa26@seed01.autismcapital.xyz:26656,11aa3f340ff138d39a27c223f9ac0987bb605c5c@3.34.160.113:26656,7575f4fdf92c4b63b2bf3e57ea0bced03b004792@3.35.101.38:26656,48fca58b12438e618a596e9aab634b4ef46ea67b@34.218.166.180:26656,80d1436ad592423a534a9223baf04ce12a616a76@columbus-seed.onestar.ee:26656,1757b212d15840d9a8781bb4a8c201a9dd70d0fa@seed-mainnet.moonshot.army:26656,5e7cdd3f0684dbab8d7fa5d18de3e9194859be03@seed.terra.btcsecure.io:26656,091bc80f53802020b7573487eda01083c942a2cf@terra2.aurastake.com:26656,69955cf4521f10cccf20c7bbec38ed5c4cb47145@seed.terradactyl.io:26656,641645367d4546a6d12d01fbf75cb40117e1a19b@63.35.218.188:26656,4caf3c19f1a1d1436c6f7837aabd50ca5bfad027@seed.leviathan.monster:26656,73c0ec0bf48b32e0670e4d805ac383b592db9a22@20.79.223.3:26656,902108566ccbd8e48ce77923a8fb060a6866e7c2@20.79.222.189:26656,058831b15272669d2de342862fc2667d5ef8be1d@seed.terra.stakewith.us:48856,b1bdf6249fb58b4c8284aff8a9c5b2804d822261@seed.terra.synergynodes.com:26656,4f40e721ef9d43e540ab853e4d178ee4814712ea@35.228.229.136:26656,69691fcb39455940693133dfaac3e4e337c1f7ef@35.189.155.44:26656,9849507ea2a33960678c517d2d774f802a4b2d65@138.91.27.245:26656,af55a55a67ca0c000a7f768559ff38883d17f694@seed.terra.staker.space:26656,be6cfededb21063e5c37e4046f0cefcc4a9840da@seed.terra.setten.io:26656,b363afa79d81bbc9d3b63657088a484398790ced@91.193.116.34:26656,d58cd901c30441df6d32323ca0935c1d6ef801d9@95.217.226.95:26099,92bcd725fb130530263704a4716da9c942becfa7@seed.mcontrol.ml:26656,7080247c1c78f86c6df77f3e714fb4983ac3c94f@seed.terra-mainnet.sabai.finance:26656,fd777409b042fe41691011eb6ecdeaad5317f8e9@35.240.133.1:26656,88d4b1517ccf60be0a7a41793948ab7af3750315@terra-mainnet-seed-1.stakin-nodes.com:26656,e86d50d69f9219839f9cd85d3329f186ec741478@terrabackup.stakely.io:26656,eb67380db62292506d41f28b1b77785a62a0f298@seed.terra.kkvalidator.com:26656,0915d3431ff7af14a6749afc12e6ba45c1b737da@34.152.3.90:26656,4f2d05162119a665b267599d3c86a936d65a9af0@seed.terra.rockx.com:26656,406bcf90a7b29df6ae475a1f94abe04ebde805af@mainnet.seed.terraindia.info:26656,1690a0c809314f2ff7f8e3ac559d5f30e7ba047b@65.108.9.149:26656,2c1b557739450f946ba38aebe113cad69c23cf98@20.199.97.106:26656,b976e8d1f94f4e2d554be4ca590929fa5ce320c0@188.166.95.126:26656,9825d4993fe6e948f6c800f9a4bbdb89ad120e76@34.79.212.227:26656,85963d3827ceab08be38285fbe354b90a2e45fef@seed-mainnet.terra.lunastations.online:36656,4df743bfcf507e603411c712d8a9b3adb5e44498@seed.terra.genesislab.net:26656,b65bc05a140f2d292055d2afbb00997023aed5ed@52.196.61.226:26656,bd8504b7c84472e1b15589c2adbb2c62ecd36e02@terra-mainnet-seed.orbitalcommandvalidator.com:26302,fb75d47bdcfe1924bb67d05b78d02ebf68ddc971@ec2-54-183-112-31.us-west-1.compute.amazonaws.com:26656,b96b058af0637613c47f0fc7affc07446ebac343@terra-mainnet-seed.blockstake.xyz:26656,b977f4a6fe45b2621c2e009cdedc1d57c7f977ff@65.0.190.90:26656,ad2c60e2d9b5566385a192fac79ed540955266a4@194.163.167.27:26656,a4950a460b60de640432701d0c5b964ba680254f@162.55.244.169:26656,0e2ddf13890eaaceb7f177432f6c3f764af16782@95.168.167.83:26656,877c6b9f8fae610a4e886604399b33c0c7a985e2@terra.mainnet.seed.forbole.com:10056,9d08e286bd1fd1bb29c52ee8bb199b62a8ac564c@85.118.207.63:26656"/g' ~/.terra/config/config.toml
	else
		sed -i 's/^seeds = ""/seeds = "e14dcea40de9b7cc31ea3e843c25bcdd8d91c36d@solarsys.noip.me:38656,7261b247dc05b8f8aca7a74529e5caf9c51d5379@162.55.132.48:15635,347e81ce9380e10b2c9838eb92a4f35b1ff5eb7a@162.55.131.238:15635,2b7150ff60df7b8bc1aa50ab586c18c7d9550171@3.130.148.2:26656,d61ee248c1b53a55cf93c60af4f4e9f7dd48b57b@seed.terra-testnet.everstake.one:26656,349aa6d91c5c072c0ae9d8f5412e3920ada71732@65.21.134.243:26656,d89ce884e0b431984fc8848efa9ecea8855ca070@terra-testnet.0base.vc:26656,1fffb76a7f6bcc0c8e1e25ec8e73171b38208522@laguz.coinbevy.com:26656,b583acaf6612b78cc0927614f2f60292bc58f6fc@35.81.139.246:26656,5f596c72e18e5e2a25684bb7b73974790268b36f@34.73.168.168:26656,3da66974005f1fc284e5a9aef869e45ee51ba0c0@terra-seed-testnet.blockngine.io:36676,4577101e210aa6389f075cdcd6c377f98ef57a84@bombay.inotel.ro:26656,bdc57c5a7f11040bed560fceb7d9b17c117e3423@seed-bombay.terra.01node.com:26656,41a6a0e9918a0f3976c81dda8991bd37b8d7ae31@tnet-seed.terra.nitawa.systems:27656,e455f2a0920414959e4620098d2a6068c720fcac@3.238.127.6:26656,f52c69954570f6f0cef7732009ad028d483b253a@bombay-seed01.stakers.finance:29656,b172ede8d2a6b1804d41819f0b61100a73a4aa0c@162.55.92.217:26656,344199da2be16adc58e7c7cf85607ee6d65f1eb4@seed.terra-testnet.lunarnode.org:26656,1c22d46f2ce87f2d8f7ee633cc67232590ca1b4b@seed01.autismcapital.xyz:3333,5be38e13bdfea97f500cdb5cde7ad40fd119c2fa@3.36.113.204:26656,0d544651127abf15cd8c1e3992757267018223c0@54.180.139.156:26656,4dd8633fb5a88c0e3c45dc2b5e173080d1ae64d3@148.251.14.48:26662,5baf0f86787b066acfc94122057026294d12c59e@bombay-seed.onestar.ee:26656,eb324ed42daf928a28db1c19aa9834968c5db26c@seed-testnet.moonshot.army:26656,c7fdeca4135e56149f5f5d84462c9eb9f059edb8@seed.terra.testnet.btcsecure.io:26656,2e5ee839dd7d42071399a7f09064afe49492b771@bombay2.aurastake.com:27656,778aee349324ef3b5b862f4f094a91f26e1c8ded@seed.terradactyl.io:40003,5f080fdec10663bf578ae6d0bff8aaf3a4ea49c0@63.35.218.188:20000,4bfcc9d65f21fadb84a4177c112a498a0dc86462@seed.leviathan.monster:26600,30faf19067be3660c1a24f8d7e40ede889251628@20.79.223.3:50000,7660dc2b1bc1dd688d703eaeb11456f0f90eb44d@20.79.222.189:26646,9628b2f8903e18dfa208527b3a74b4f76aaf2fb9@seed.terra.testnet.stakewith.us:47756,edfa33ed283ea40b7e6ef3683b2ccbf4b7a77d4f@seed.bombay.synergynodes.com:26656,c4e695a19e81989e96468475cffabfd81d669408@35.228.229.136:26650,5928ecce7e3ee70b4fd171b5b0141914ad947a0b@35.189.155.44:25656,b140f8847169a7bd852a214eb74eb52f0e628393@138.91.27.245:26856,05bf2a0786c34f07452f21a0d4fc00061224b59f@seed.terra.testnet.staker.space:26656,458edd0d8f93dd221cc8a7df7f7eaed9303da0f6@seed.bombay.terra.setten.io:26656,070f643051da07b84586794c13dcaf13d5ce8efd@139.59.181.204:26656,c23709c65da9446ad5c3e9b4e4613c2262cda989@95.216.241.103:26656,eb13d18465e9b8387b6dc3b73fc414032fc23fab@bombay.mcontrol.ml:36656,5e71188b711b65f8ef5a18fd08413bb7cf30c7d4@seed.terra-bombay.sabai.finance:26656,0ac871becd561e931f71825b50dc6d4a069dd80c@35.240.133.1:26680,12a7b4d0adfc6a6ccefe8d010578793cbbddb742@terra-testnet-seed-1.stakin-nodes.com:26656,9b0de4e76f874191ae3b08010b0a7542a73c1098@terrabombay.stakely.io:26656,8ffc890f24985035857bc63e5ff13eaac1f77683@bombay-seed.terra.kkvalidator.com:26656,2308feb62147331889f13aef01417a91362c79f8@34.152.3.90:26670,c68bf400ab04b87563f8176b0246b5b68b809cd6@testnet.seed.terraindia.info:36656,22a020147ab5caaaf69654fa78bbcd3207cf8620@65.21.229.28:26656,af9758b222023e8e4013154de1c23cf755564be5@167.172.166.36:26656,0cc9fff2c57e5b3d2fcf2c91bba1e8b8cf1590ca@seed.terra-testnet.cosmicvalidator.com:26656,eb6fb5b290adc146e23453dbe9eb5c9b924775c1@20.199.97.106:36656,745a631ab71716d5eaf74c63b9c0c11f4be1d668@167.99.91.224:26656,0f9135a7e5ad341b1cee42bc5a79d4f5122ff638@34.79.212.227:27656,e260ab51f62a1cbf6d04b23192e665edd4f1176d@seed-testnet.terra.lunastations.online:36656,848466e05b6b64a87bfc23df6cb06771e07b1b4c@seed-testnet.terra.genesislab.net:26656,87c943b197d0ee9162eafc31a8664aa27cd6ad19@terra-testnet.bi23.com:21656,6958c0a62d72dd062a4e034b47b1586458ff8169@52.196.61.226:26666,8ac91044bb88781a6b90290ea0e47e43dfb9b43a@terra-testnet-seed.orbitalcommandvalidator.com:26312,02a99227cc192d423500ea753e3c05dc991da569@ec2-18-144-37-246.us-west-1.compute.amazonaws.com:26656,cc87ff83f9e35094df3f71de51a792e8ecf2efa0@terra-bombay-seed.blockstake.xyz:26656,37ffe148ecf6645d2e21e1703145c7828c22a268@13.234.69.239:26656,7c0d84fde67ebf7084ddf7a467e879d5d6442b57@194.163.162.199:26656,3abc165052e80746e543f4863d7d2bf6d00b528b@bombay-seed.blockscape.network:26656,9762192a79f88f37419d32f164a88e05ce024aec@168.119.150.243:26656,3aa011fc424956aa78015ec7372bfed213233e8c@95.168.165.205:26656,67f83663158a908b1a0784e642eafde880dd2929@terra.test.seed.forbole.com:26656,9e4110344ab9ae7864b0c102b77b68d003b85289@85.118.207.62:26656"/g' ~/.terra/config/config.toml
	fi
fi

if [ "$CHAINID" = "columbus-5" ] && [[ ! -z "$SNAPSHOT_NAME" ]] ; then 
  # Download the snapshot if data directory is empty.
  path=$(ls -A $DATADIR)
  if [[ ! -z "$path" ]]; then
      echo "data directory is NOT empty, skipping quicksync"
  else
      echo "starting snapshot download"
      mkdir -p $DATADIR
      cd $DATADIR
      FILENAME="$SNAPSHOT_NAME"

      # Download
      aria2c -x5 $SNAPSHOT_BASE_URL/$FILENAME
      # Extract
      lz4 -d $FILENAME | tar xf -

      # # cleanup
      rm $FILENAME
  fi
fi

if [ "$IS_OFFLINE" = true ]; then
	exec terrad rosetta --offline --blockchain terra --network $CHAINID \
		--enable-fee-suggestion --gas-to-suggest $SUGGEST_GAS --denom-to-suggest $SUGGEST_DENOM \
		--prices-to-suggest $MINIMUM_GAS_PRICES
else
	exec "$@" --db_dir $DATADIR
fi
