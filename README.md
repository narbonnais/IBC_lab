# IBC Lab

## Download and compile the sources

Create a working directoy for the project:
```sh
mkdir ibc-lab
cd ibc-lab
```

Install gaia:
```sh
git clone git@github.com:cosmos/gaia.git
cd gaiad
git checkout v7.1.0
make build
cd ..
```

Install osmosis:
```sh
git clone https://github.com/osmosis-labs/osmosis
cd osmosis
git checkout v14.0.0
make build
cd ..
```

Install relayer:
```sh
git clone git@github.com:cosmos/relayer.git
cd relayer
git checkout v2.1.2
make build
cd ..
```

## Run localosmosis

Osmosis have a testnet ready to run in `osmosis/tests/localosmosis`. On the project root, run:
```sh
make localnet-init # Builds docker image and clear ~/.osmosisd
make localnet-start # Start the chain
make localnet-keys # Add a few keys to keystore test
make localnet-stop # Stops the chain
make localnet-clean # Cleans the environment
```

If you ran `make localnet-keys` then you should have a few accounts in your keyring:
```sh
$ osmosisd keys list --keyring-backend test
- name: alice
  type: local
  address: osmo1t8eh66t2w5k67kwurmn5gqhtq6d2ja0vp7jmmq
  pubkey: '{"@type":"/cosmos.crypto.secp256k1.PubKey","key":"AssH5gCNSaYq3eUOs9F1yve/C2R/YvtKwW4HFuyZ7zaq"}'
  mnemonic: ""
- name: bob
  type: local
  address: osmo1ez43ye5qn3q2zwh8uvswppvducwnkq6wjqc87d
  pubkey: '{"@type":"/cosmos.crypto.secp256k1.PubKey","key":"AtN4JEgQaCL8rjlar+UfVGOCsvC9ziL0O9Xxj0CexYCt"}'
  mnemonic: ""
- name: lo-test1
  type: local
  address: osmo1cyyzpxplxdzkeea7kwsydadg87357qnahakaks
  pubkey: '{"@type":"/cosmos.crypto.secp256k1.PubKey","key":"AuwYyCUBxQiBGSUWebU46c+OrlApVsyGLHd4qhSDZeiG"}'`
[...]
```

If we query `alice`'s balance, she has 0 coins. If we query `lo-test1`'s balance, the account has `100000000000uosmo`. This is setup in the [add genesis accounts](https://github.com/osmosis-labs/osmosis/blob/f9113917049a41ee57d2b8e04a262494f7e928a0/tests/localosmosis/scripts/setup.sh#L68-L88) part of the setup.
```sh
$ osmosisd q bank balances osmo1t8eh66t2w5k67kwurmn5gqhtq6d2ja0vp7jmmq
balances:
- amount: "0"
  denom: uosmo
pagination:
  next_key: null
  total: "0"

$ osmosisd q bank balances osmo1cyyzpxplxdzkeea7kwsydadg87357qnahakaks
balances:
- amount: "100000000000"
  denom: stake
- amount: "100000000000"
  denom: uion
- amount: "100000000000"
  denom: uosmo
pagination:
  next_key: null
  total: "0"
```

Transfer one token from lo-test1 to alice to confirm that everything is working well. `alice` now has `1uosmo` while `lo-test1` has `99999999999uosmo`.
```sh
$ tx bank send lo-test1 osmo1t8eh66t2w5k67kwurmn5gqhtq6d2ja0vp7jmmq 1uosmo --keyring-backend test --chain-id localosmosis

$ osmosisd q bank balances osmo1t8eh66t2w5k67kwurmn5gqhtq6d2ja0vp7jmmq
balances:
- amount: "1"
  denom: uosmo
pagination:
  next_key: null
  total: "0"

$ osmosisd q bank balances osmo1cyyzpxplxdzkeea7kwsydadg87357qnahakaks
balances:
- amount: "100000000000"
  denom: stake
- amount: "100000000000"
  denom: uion
- amount: "99999999999"
  denom: uosmo
pagination:
  next_key: null
  total: "0"
```

## Run gaiad

The localnet commands are straighforward:
```sh
make localnet-start
make localnet-stop
```

The testnet seed is located in `gaia/build/node0/gaiad/key_seed.json`, we use it to import the account:
```sh
$ gaiad keys add lg-test1 --recover
> Enter your bip39 mnemonic
brand siren hover loyal leader patient problem artwork brass consider priority share meat lesson message sign pyramid step solar monitor elegant vocal group loan

- name: lg-test1
  type: local
  address: cosmos1znsa38frp0mtmnphfrmym3ea500frwurncjkaw
  pubkey: '{"@type":"/cosmos.crypto.secp256k1.PubKey","key":"AvVEaPJungkwIz1u73tthhupfixD+z4RK3S12VnKJCI3"}'
  mnemonic: ""
```

## Setup relayer

### Loading chains metadata

We setup a `chains` dir containing `localosmosis.json` and `localgaia.json`. These metadata help relayer to talk with the chain. The `key` parameter is the name of the key that the relayer will use to sign transactions, so you need to recover the key with that specific name in the following sections.
```json
{
    "type": "cosmos",
    "value": {
      "key": "lg-test1",
      "chain-id": "localgaia",
      "rpc-addr": "http://172.20.0.3:26657",
      "account-prefix": "cosmos",
      "keyring-backend": "test",
      "gas-adjustment": 1.2,
      "gas-prices": "0.01uatom",
      "debug": true,
      "timeout": "20s",
      "output-format": "json",
      "sign-mode": "direct"
    }
  }
```

Add the chains to the configuration:
```
/relayer # rly chains add-dir chains
added chain localgaia...
added chain localosmosis...
```

If we display the configured chains, we can see that the relayer is not connected:
```sh
/relayer # rly chains list
 1: localgaia            -> type(cosmos) key(✘) bal(✘) path(✘)
 2: localosmosis         -> type(cosmos) key(✘) bal(✘) path(✘)
```

### Registering relayer keys on both chains

Let's use the `lo-test-1` (from osmosis) and `lg-test-1` (from gaia) accounts. They share the same mnemonic so it's easy to setup. Remember to use the `key` name from your `localosmosis.json` and `localgaia.json` files.
```sh
/relayer # rly keys restore localosmosis lo-test1 "notice oak worry limit wrap speak medal online prefer cluster roof addict wrist behave treat actual wasp year salad speed social layer crew genius"
osmo1cyyzpxplxdzkeea7kwsydadg87357qnahakaks

/relayer # rly keys restore localgaia lg-test1 "notice oak worry limit wrap speak medal online prefer cluster roof addict wrist behave treat actual wasp year salad speed social layer crew genius"
cosmos1cyyzpxplxdzkeea7kwsydadg87357qnalx9dqz
```

We can make sure that we recovered our keys by querying our balances:
```sh
/relayer # rly q balance localosmosis
address {osmo1cyyzpxplxdzkeea7kwsydadg87357qnahakaks} balance {100000000000stake,100000000000uion,100000000000uosmo} 

/relayer # rly q balance localgaia
address {cosmos1cyyzpxplxdzkeea7kwsydadg87357qnalx9dqz} balance {100000000000stake,100000000000uatom} 
```

If we take a quick look at the chains config, we can see that everything is ok except the paths:
```sh
/relayer # rly chains list
 1: localgaia            -> type(cosmos) key(✔) bal(✔) path(✘)
 2: localosmosis         -> type(cosmos) key(✔) bal(✔) path(✘)
```

### Adding the paths

A path represents the "full path" or "link" for communication between two chains. This includes the client, connection, and channel ids from both the source and destination chains as well as the strategy to use when relaying.

A path configuration file looks like [cosmoshub-osmosis.json](https://github.com/cosmos/chain-registry/blob/master/_IBC/cosmoshub-osmosis.json).

Create a new path with the following command. We specify the transfer port that is a standard port to exchange tokens (like port 80 is usually borrowed by the HTTP protocol).
```
/relayer # rly paths new localgaia localosmosis localgaia-localosmosis --src-port transfer --dst-port transfer --order unordered
```

If we take a look a the path state, we can see that we need clients and connections.
```sh
/relayer # rly paths show localgaia-localosmosis
Path "localgaia-localosmosis":
  SRC(localgaia)
    ClientID:     
    ConnectionID: 
  DST(localosmosis)
    ClientID:     
    ConnectionID: 
  STATUS:
    Chains:       ✔
    Clients:      ✘
    Connection:   ✘
```

### Linking the chains

We need to create a link: it will create clients, connection, and channel between two configured chains with a configured path.
```sh
rly transact link localgaia-localosmosis --src-port transfer --dst-port transfer
```

Taking a closer look at the path, we can see that the chains, clients and the connection are valid:
```sh
/relayer # rly paths show localgaia-localosmosis
Path "localgaia-localosmosis":
  SRC(localgaia)
    ClientID:     07-tendermint-0
    ConnectionID: connection-0
  DST(localosmosis)
    ClientID:     07-tendermint-0
    ConnectionID: connection-0
  STATUS:
    Chains:       ✔
    Clients:      ✔
    Connection:   ✔
```

**Troubleshooting**

It looks like there is a problem with unbonding time leading to `trusting_period` being truncated to zero and returning an error. To counter that, replace `TrustingPeriod` in `relayer/chains/cosmos/provider.go`:
```diff
func (cc *CosmosProvider) TrustingPeriod(ctx context.Context) (time.Duration, error) {
	res, err := cc.QueryStakingParams(ctx)
	if err != nil {
		return 0, err
	}

	// We want the trusting period to be 85% of the unbonding time.
	// Go mentions that the time.Duration type can track approximately 290 years.
	// We don't want to lose precision if the duration is a very long duration
	// by converting int64 to float64.
	// Use integer math the whole time, first reducing by a factor of 100
	// and then re-growing by 85x.

	tp := res.UnbondingTime / 100 * 85

+	if tp > time.Hour {
+		tp = tp.Truncate(time.Hour)
+	}

	return tp, nil
}
```

#### Create clients

The relayer performed a transaction on `localgaia` to create a client using `MsgCreateClient`. The same happens with `localosmosis`.
```json
Successful transaction
{
    "provider_type": "cosmos",
    "chain_id": "localgaia",
    "gas_used": 95818,
    "fees": "1020uatom",
    "fee_payer": "cosmos1cyyzpxplxdzkeea7kwsydadg87357qnalx9dqz",
    "height": 10,
    "msg_types": [
        "/ibc.core.client.v1.MsgCreateClient"
    ],
    "tx_hash": "92D00CCBC03BFD4B6E18EE7017603DFD4BD2DCDF930CB68FDD2BCB8153F43035"
}
```

After that, the relayer's light clients attempt to synchronise with the network:
```json
Starting event processor for connection handshake
    {"src_chain_id": "localgaia", "src_client_id": "07-tendermint-0", "dst_chain_id": "localosmosis", "dst_client_id": "07-tendermint-0"}
Chain is not yet in sync
     {"chain_name": "localosmosis", "chain_id": "localosmosis", "latest_queried_block": 0, "latest_height": 10}
Chain is not yet in sync
     {"chain_name": "localgaia", "chain_id": "localgaia", "latest_queried_block": 0, "latest_height": 10}
Chain is in sync
     {"chain_name": "localgaia", "chain_id": "localgaia"}
Chain is in sync
     {"chain_name": "localosmosis", "chain_id": "localosmosis"}
```

#### Open connection

The `localgaia` chain was the first to initiate the connection. After that, the relayer opens a connection in the other way.

The relayer first initialize a connection on `localgaia` to get a new connection ID.
- The `localgaia` connection state is `INIT`.
```json
Successful transaction
{
    "provider_type": "cosmos",
    "chain_id": "localgaia",
    "gas_used": 117682,
    "fees": "1283uatom",
    "fee_payer": "cosmos1cyyzpxplxdzkeea7kwsydadg87357qnalx9dqz",
    "height": 12,
    "msg_types": [
        "/ibc.core.client.v1.MsgUpdateClient",
        "/ibc.core.connection.v1.MsgConnectionOpenInit"
    ],
    "tx_hash": "334E75E22C7F2CE1485304DDC14A8C05D2952AEE5D4D09807FA98486ADE9D686"
}
```

The relayer opens a connection on `localosmosis`, also returns a connection ID.
- Set counterparty to be `localgaia`'s connection ID. 
- The `localosmosis` connection state is `TRYOPEN`.
```json
Successful transaction
{
    "provider_type": "cosmos",
    "chain_id": "localosmosis",
    "gas_used": 164538,
    "fees": "1780uosmo",
    "fee_payer": "osmo1cyyzpxplxdzkeea7kwsydadg87357qnahakaks",
    "height": 14,
    "msg_types": [
        "/ibc.core.client.v1.MsgUpdateClient",
        "/ibc.core.connection.v1.MsgConnectionOpenTry"
    ],
    "tx_hash": "4DBF3AFA1F2188881CB4D9676496A6848C420F32EB4FC30CCEC3ACA493789D34"
}
```

Validates to `localgaia` that `localosmosis` is ok.
- Set counterparty to be `localosmosis`'s connection ID. 
- The `localgaia` connection state is `OPEN`
```json
Successful transaction
{
    "provider_type": "cosmos",
    "chain_id": "localgaia",
    "gas_used": 148162,
    "fees": "1649uatom",
    "fee_payer": "cosmos1cyyzpxplxdzkeea7kwsydadg87357qnalx9dqz",
    "height": 16,
    "msg_types": [
        "/ibc.core.client.v1.MsgUpdateClient",
        "/ibc.core.connection.v1.MsgConnectionOpenAck"
    ],
    "tx_hash": "BF9A824687E9D63FB7381AE03BF86185E7BEEA2708B8AA7FDE8E0D640E597DFC"
}
```

Confirms the opening of `localgaia` connection:
- The `localosmosis` connection state is `OPEN`.
```json
Successful transaction
{
    "provider_type": "cosmos",
    "chain_id": "localosmosis",
    "gas_used": 127140,
    "fees": "1331uosmo",
    "fee_payer": "osmo1cyyzpxplxdzkeea7kwsydadg87357qnahakaks",
    "height": 17,
    "msg_types": [
        "/ibc.core.client.v1.MsgUpdateClient",
        "/ibc.core.connection.v1.MsgConnectionOpenConfirm"
    ],
    "tx_hash": "4FF4B4338411C51BBAFB5E4017E26ACB9B1D08A78AC5CBA1CDA3B19D6B19549F"
}
```

- Create light clients
- Open connection
		- [MsgConnectionOpenInit](https://github.com/cosmos/ibc-go/blob/684d9bf3c45acc1d0dc2f3603150548a9015c001/modules/core/keeper/msg_server.go#L98-L107)  initialises a connection attempt on chain A. The generated connection identifier is returned.
		- [MsgConnectionOpenTry](https://github.com/cosmos/ibc-go/blob/684d9bf3c45acc1d0dc2f3603150548a9015c001/modules/core/keeper/msg_server.go#L109-L127) relays notice of a connection attempt on chain A to chain B (this code is executed on chain B).
		- [MsgConnectionOpenAck](https://github.com/cosmos/ibc-go/blob/684d9bf3c45acc1d0dc2f3603150548a9015c001/modules/core/keeper/msg_server.go#L129-L146) relays acceptance of a connection open attempt from chain B back to chain A (this code is executed on chain A).
		- [MsgConnectionOpenConfirm](https://github.com/cosmos/ibc-go/blob/684d9bf3c45acc1d0dc2f3603150548a9015c001/modules/core/keeper/msg_server.go#L148-L159) confirms opening of a connection on chain A to chain B, after which the connection is open on both chains (this code is executed on chain B).

## Run relayer

Simply run `rly` in debug mode. It will sync with the two chains and start scanning the latests blocks:
```sh
/relayer # rly start -d
```

## Sending funds

We will send funds from `lo-test2` (`osmo18s5lynnmx37hq4wlrw9gdn68sg2uxp5rgk26vv`) to `lg-test2` (`cosmos18s5lynnmx37hq4wlrw9gdn68sg2uxp5rqde267`).

Query the balance of `lg-test2`:
```yml
/gaia # gaiad q bank balances cosmos18s5lynnmx37hq4wlrw9gdn68sg2uxp5rqde267 --home ./.gaiad
balances:
- amount: "100000000000"
  denom: stake
- amount: "100000000000"
  denom: uatom
```

Query the balance of `lo-test2`:
```yml
/osmosis # osmosisd q bank balances osmo18s5lynnmx37hq4wlrw9gdn68sg2uxp5rgk26vv
balances:
- amount: "100000000000"
  denom: stake
- amount: "100000000000"
  denom: uion
- amount: "100000000000"
  denom: uosmo
```

HERE IT IS, the final command that we will use to transfer funds from the localosmosis `blockchain` to `localgaia`:

```sh
/osmosis # osmosisd tx ibc-transfer transfer transfer channel-0 cosmos18s5lynnmx37hq4wlrw9gdn68sg2uxp5rqde267 1000uosmo --from lo-test2 --keyring-backend test --chain-id localosmosis

txhash: C821DF5DB151EF5253873FA4B768D93BAA62FA4FDD918325A6FEA484DB079B5D
```

That puts the following transaction in a block that will be detected by the relayer:
```json
// osmosisd q tx C821DF5DB151EF5253873FA4B768D93BAA62FA4FDD918325A6FEA484DB079B5D --output json | jq
{
	"@type": "/ibc.applications.transfer.v1.MsgTransfer",
	"source_port": "transfer",
	"source_channel": "channel-0",
	"token": {
		"denom": "uosmo",
		"amount": "1000"
	},
	"sender": "osmo18s5lynnmx37hq4wlrw9gdn68sg2uxp5rgk26vv",
	"receiver": "cosmos18s5lynnmx37hq4wlrw9gdn68sg2uxp5rqde267",
	"timeout_height": {
		"revision_number": "0",
		"revision_height": "1034"
	},
	"timeout_timestamp": "1674758687296129295",
	"memo": ""
}
```

The relayer finds the transaction, and relays the data to the `localgaia` blockchain:
```json
Successful transaction
{
    "provider_type": "cosmos",
    "chain_id": "localgaia",
    "packet_src_channel": "channel-0",
    "packet_dst_channel": "channel-0",
    "gas_used": 172972,
    "fees": "1947uatom",
    "fee_payer": "cosmos1cyyzpxplxdzkeea7kwsydadg87357qnalx9dqz",
    "height": 49,
    "msg_types": [
        "/ibc.core.client.v1.MsgUpdateClient",
        "/ibc.core.channel.v1.MsgRecvPacket"
    ],
    "tx_hash": "3DD61D5DFBDE06A0F0622BF62ED6A7610C801FFF9EA65B666EED482CBC3A8F6C"
}
```

We find the relayer's transaction on `localgaia`:

```json
// gaiad tx q 3DD61D5DFBDE06A0F0622BF62ED6A7610C801FFF9EA65B666EED482CBC3A8F6C --output json | jq
{
	"@type": "/ibc.core.channel.v1.MsgRecvPacket",
	"packet": {
		"sequence": "1",
		"source_port": "transfer",
		"source_channel": "channel-0",
		"destination_port": "transfer",
		"destination_channel": "channel-0",
		"data": "eyJhbW91bnQiOiIxMDAwIiwiZGVub20iOiJ1b3NtbyIsInJlY2VpdmVyIjoiY29zbW9zMThzNWx5bm5teDM3aHE0d2xydzlnZG42OHNnMnV4cDVycWRlMjY3Iiwic2VuZGVyIjoib3NtbzE4czVseW5ubXgzN2hxNHdscnc5Z2RuNjhzZzJ1eHA1cmdrMjZ2diJ9",
		"timeout_height": {
			"revision_number": "0",
			"revision_height": "1034"
		},
		"timeout_timestamp": "1674758687296129295"
	},
	"proof_commitment": "CvMCCvACCjljb21taXRtZW50cy9wb3J0cy90cmFuc2Zlci9jaGFubmVscy9jaGFubmVsLTAvc2VxdWVuY2VzLzESIBQupW0iWtFOqX9b41J3efUGdklxojz+aR/MqcbCvl/bGgsIARgBIAEqAwACXiIpCAESJQIEXiCEPOFAaJ9wYwLV4akhwBZlPvNRUkDflNRTf1IReEphpiAiKwgBEgQEBl4gGiEgzCYyYiS0ut3qTo5npLOlBplSBQOjPz2nAhCyD4QmZH0iKQgBEiUGDl4gIVHgmH9hVcEGU2TCq52k6sU08XB+L89c/Ok8wCXUcxggIisIARIECBpeIBohIGA/jEvTtoqjQS1wLo0zgkDHpWhcni6lTOUWTPkeWoOpIikIARIlCipeIEmQu9oByKtLHg3ft165TvnKhlDYYPDZbtprmKSPbBztICIpCAESJQw+XiCTrdAjHuBzWayOac4VdaQgN9hdlqcbEAU89UJlo+2tjyAK/AEK+QEKA2liYxIgEhCqaM6SwyOzuQ28akHf26zleU9it1CM7LZ0fv37F44aCQgBGAEgASoBACIlCAESIQFOHVxWOw2w/9y6b8l9wMexO1tcnDQTV/CIJ1ZQR9bGuSIlCAESIQGqi7WDeBFaYUvR+Ew97BDyCsyFgeO7925V/X1IBe01cyInCAESAQEaIFLg5sa54XvAY2XB9AupDdY3wRPuuXTa4tJhf005gFvlIiUIARIhAd7s6neSicP+7zAQVI+JIN4zqRD7hgkb6MCugaRyiaViIicIARIBARogoKgvetd58jrEIzC7dHEW4vZjJFahyCnhyKAY+RbRYhA=",
	"proof_height": {
		"revision_number": "0",
		"revision_height": "48"
	},
	"signer": "cosmos1cyyzpxplxdzkeea7kwsydadg87357qnalx9dqz"
}
```

The b64 decoded data is:
```json
{
    "amount": "1000",
    "denom": "uosmo",
    "receiver": "cosmos18s5lynnmx37hq4wlrw9gdn68sg2uxp5rqde267",
    "sender": "osmo18s5lynnmx37hq4wlrw9gdn68sg2uxp5rgk26vv"
}
```

Let's query the target `lg-test2` account balance. We find the `1000uatoms` ! It is relevant to note that `uatom` doesn't show up. Instead, a unique IBC identifier is used: `ibc/ED07A3391A112B175915CD8FAF43A2DA8E4790EDE12566649D0C2F97716B8518` . If you send `uatom` from a differnent channel, the received denom will be different; that is why canonical channels must be used in case of several possibilities.
```yml
/gaia # gaiad q bank balances cosmos18s5lynnmx37hq4wlrw9gdn68sg2uxp5rqde267 --home ./.gaiad
balances:
- amount: "1000"
  denom: ibc/ED07A3391A112B175915CD8FAF43A2DA8E4790EDE12566649D0C2F97716B8518
- amount: "100000000000"
  denom: stake
- amount: "100000000000"
  denom: uatom
```

## Setup the docker lab

Let's automatize the whole process to rapidly spind up two chains and a relayer.

The `docker-compose.yml` file spins up a lab with three containers:
- osmosis
- gaia
- relayer

Each container runs a docker container built from the dockerfiles in `./dockerfiles`, and each one has a different IP to avoid problems with port attributions.

The osmosis and gaia nodes are started with configurations that can be found in `config/`. The `setup.sh` scripts configures the genesis files and test accounts.

The relayer starts a few seconds later and links the two chains together.

To run the lab:
```sh
docker-compose up --build
```

You can find the consoles in docker desktop, or list the containers with `docker-ps` and connect to a container with:
```sh
docker exec -it 181515b5af447713d6f48cebedf08d50c9b58dbfe390c82b49e08eda2e9a0697 /bin/sh
```

## Troubleshooting

- When there is a problem, try deleting the nodes' and relayer's home.
- Relayer error: sigsev -> you need to run `rly config init`
- Error with the `trusting_period`: modify the source code of `provider.go`