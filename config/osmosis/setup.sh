#!/bin/sh

CHAIN_ID=localosmosis
OSMOSIS_HOME=$HOME/.osmosisd
CONFIG_FOLDER=$OSMOSIS_HOME/config
MONIKER=val
STATE='false'

MNEMONIC="bottom loan skill merry east cradle onion journey palm apology verb edit desert impose absurd oil bubble sweet glove shallow size build burst effort"
POOLSMNEMONIC="traffic cool olive pottery elegant innocent aisle dial genuine install shy uncle ride federal soon shift flight program cave famous provide cute pole struggle"

while getopts s flag
do
    case "${flag}" in
        s) STATE='true';;
    esac
done

install_prerequisites () {
    apk add dasel
    apk add jq
}

edit_genesis () {

    GENESIS=$CONFIG_FOLDER/genesis.json

    # Update staking module
    dasel put string -f $GENESIS '.app_state.staking.params.bond_denom' 'uosmo'
    dasel put string -f $GENESIS '.app_state.staking.params.unbonding_time' '240s'

    # Update crisis module
    dasel put string -f $GENESIS '.app_state.crisis.constant_fee.denom' 'uosmo'

    # Udpate gov module
    dasel put string -f $GENESIS '.app_state.gov.voting_params.voting_period' '60s'
    dasel put string -f $GENESIS '.app_state.gov.deposit_params.min_deposit.[0].denom' 'uosmo'

    # Update epochs module
    dasel put string -f $GENESIS '.app_state.epochs.epochs.[1].duration' "60s"

    # Update poolincentives module
    dasel put string -f $GENESIS '.app_state.poolincentives.lockable_durations.[0]' "120s"
    dasel put string -f $GENESIS '.app_state.poolincentives.lockable_durations.[1]' "180s"
    dasel put string -f $GENESIS '.app_state.poolincentives.lockable_durations.[2]' "240s"
    dasel put string -f $GENESIS '.app_state.poolincentives.params.minted_denom' "uosmo"

    # Update incentives module
    dasel put string -f $GENESIS '.app_state.incentives.lockable_durations.[0]' "1s"
    dasel put string -f $GENESIS '.app_state.incentives.lockable_durations.[1]' "120s"
    dasel put string -f $GENESIS '.app_state.incentives.lockable_durations.[2]' "180s"
    dasel put string -f $GENESIS '.app_state.incentives.lockable_durations.[3]' "240s"
    dasel put string -f $GENESIS '.app_state.incentives.params.distr_epoch_identifier' "day"

    # Update mint module
    dasel put string -f $GENESIS '.app_state.mint.params.mint_denom' "uosmo"
    dasel put string -f $GENESIS '.app_state.mint.params.epoch_identifier' "day"

    # Update gamm module
    dasel put string -f $GENESIS '.app_state.gamm.params.pool_creation_fee.[0].denom' "uosmo"

    # Update txfee basedenom
    dasel put string -f $GENESIS '.app_state.txfees.basedenom' "uosmo"

    # Update wasm permission (Nobody or Everybody)
    dasel put string -f $GENESIS '.app_state.wasm.params.code_upload_access.permission' "Everybody"
}

add_genesis_accounts () {

    echo "notice oak worry limit wrap speak medal online prefer cluster roof addict wrist behave treat actual wasp year salad speed social layer crew genius" | osmosisd keys add lo-test1 --recover --keyring-backend test --home $OSMOSIS_HOME
    echo "quality vacuum heart guard buzz spike sight swarm shove special gym robust assume sudden deposit grid alcohol choice devote leader tilt noodle tide penalty" | osmosisd keys add lo-test2 --recover --keyring-backend test --home $OSMOSIS_HOME
    echo "symbol force gallery make bulk round subway violin worry mixture penalty kingdom boring survey tool fringe patrol sausage hard admit remember broken alien absorb" | osmosisd keys add lo-test3 --recover --keyring-backend test --home $OSMOSIS_HOME
    echo "bounce success option birth apple portion aunt rural episode solution hockey pencil lend session cause hedgehog slender journey system canvas decorate razor catch empty" | osmosisd keys add lo-test4 --recover --keyring-backend test --home $OSMOSIS_HOME
    echo "second render cat sing soup reward cluster island bench diet lumber grocery repeat balcony perfect diesel stumble piano distance caught occur example ozone loyal" | osmosisd keys add lo-test5 --recover --keyring-backend test --home $OSMOSIS_HOME
    echo "spatial forest elevator battle also spoon fun skirt flight initial nasty transfer glory palm drama gossip remove fan joke shove label dune debate quick" | osmosisd keys add lo-test6 --recover --keyring-backend test --home $OSMOSIS_HOME
    echo "noble width taxi input there patrol clown public spell aunt wish punch moment will misery eight excess arena pen turtle minimum grain vague inmate" | osmosisd keys add lo-test7 --recover --keyring-backend test --home $OSMOSIS_HOME
    echo "cream sport mango believe inhale text fish rely elegant below earth april wall rug ritual blossom cherry detail length blind digital proof identify ride" | osmosisd keys add lo-test8 --recover --keyring-backend test --home $OSMOSIS_HOME
    echo "index light average senior silent limit usual local involve delay update rack cause inmate wall render magnet common feature laundry exact casual resource hundred" | osmosisd keys add lo-test9 --recover --keyring-backend test --home $OSMOSIS_HOME
    echo "prefer forget visit mistake mixture feel eyebrow autumn shop pair address airport diesel street pass vague innocent poem method awful require hurry unhappy shoulder" | osmosisd keys add lo-test10 --recover --keyring-backend test --home $OSMOSIS_HOME
    echo $MNEMONIC | osmosisd keys add $MONIKER --recover --keyring-backend=test --home $OSMOSIS_HOME
    echo $POOLSMNEMONIC | osmosisd keys add pools --recover --keyring-backend=test --home $OSMOSIS_HOME

    osmosisd add-genesis-account $(osmosisd keys show lo-test1 --home $OSMOSIS_HOME --output json --keyring-backend test | jq '.address' | tr -d '"') 100000000000uosmo,100000000000uion,100000000000stake --home $OSMOSIS_HOME
    osmosisd add-genesis-account $(osmosisd keys show lo-test2 --home $OSMOSIS_HOME --output json --keyring-backend test | jq '.address' | tr -d '"') 100000000000uosmo,100000000000uion,100000000000stake --home $OSMOSIS_HOME
    osmosisd add-genesis-account $(osmosisd keys show lo-test3 --home $OSMOSIS_HOME --output json --keyring-backend test | jq '.address' | tr -d '"') 100000000000uosmo,100000000000uion,100000000000stake --home $OSMOSIS_HOME
    osmosisd add-genesis-account $(osmosisd keys show lo-test4 --home $OSMOSIS_HOME --output json --keyring-backend test | jq '.address' | tr -d '"') 100000000000uosmo,100000000000uion,100000000000stake --home $OSMOSIS_HOME
    osmosisd add-genesis-account $(osmosisd keys show lo-test5 --home $OSMOSIS_HOME --output json --keyring-backend test | jq '.address' | tr -d '"') 100000000000uosmo,100000000000uion,100000000000stake --home $OSMOSIS_HOME
    osmosisd add-genesis-account $(osmosisd keys show lo-test6 --home $OSMOSIS_HOME --output json --keyring-backend test | jq '.address' | tr -d '"') 100000000000uosmo,100000000000uion,100000000000stake --home $OSMOSIS_HOME
    osmosisd add-genesis-account $(osmosisd keys show lo-test7 --home $OSMOSIS_HOME --output json --keyring-backend test | jq '.address' | tr -d '"') 100000000000uosmo,100000000000uion,100000000000stake --home $OSMOSIS_HOME
    osmosisd add-genesis-account $(osmosisd keys show lo-test8 --home $OSMOSIS_HOME --output json --keyring-backend test | jq '.address' | tr -d '"') 100000000000uosmo,100000000000uion,100000000000stake --home $OSMOSIS_HOME
    osmosisd add-genesis-account $(osmosisd keys show lo-test9 --home $OSMOSIS_HOME --output json --keyring-backend test | jq '.address' | tr -d '"') 100000000000uosmo,100000000000uion,100000000000stake --home $OSMOSIS_HOME
    osmosisd add-genesis-account $(osmosisd keys show lo-test10 --home $OSMOSIS_HOME --output json --keyring-backend test | jq '.address' | tr -d '"') 100000000000uosmo,100000000000uion,100000000000stake --home $OSMOSIS_HOME
    osmosisd add-genesis-account $(osmosisd keys show $MONIKER --home $OSMOSIS_HOME --output json --keyring-backend test | jq '.address' | tr -d '"') 100000000000uosmo,100000000000uion,100000000000stake --home $OSMOSIS_HOME
    osmosisd add-genesis-account $(osmosisd keys show pools --home $OSMOSIS_HOME --output json --keyring-backend test | jq '.address' | tr -d '"') 1000000000000uatom,1000000000000uion,1000000000000stake --home $OSMOSIS_HOME

    osmosisd gentx $MONIKER 500000000uosmo --keyring-backend=test --chain-id=$CHAIN_ID --home $OSMOSIS_HOME

    osmosisd collect-gentxs --home $OSMOSIS_HOME
}

edit_config () {
    # Remove seeds
    dasel put string -f $CONFIG_FOLDER/config.toml '.p2p.seeds' ''

    # Expose the rpc
    dasel put string -f $CONFIG_FOLDER/config.toml '.rpc.laddr' "tcp://0.0.0.0:26657"
}

create_two_asset_pool () {
    # Create default pool
    substring='code: 0'
    COUNTER=0
    while [ $COUNTER -lt 15 ]; do
        string=$(osmosisd tx gamm create-pool --pool-file=$1 --from pools --chain-id=$CHAIN_ID --home $OSMOSIS_HOME --keyring-backend=test -b block --yes  2>&1)
        if [ "$string" != "${string%"$substring"*}" ]; then
            echo "create two asset pool: successful"
            break
        else
            let COUNTER=COUNTER+1
            sleep 0.5
        fi
    done
}

create_three_asset_pool () {
    # Create three asset pool
    substring='code: 0'
    COUNTER=0
    while [ $COUNTER -lt 15 ]; do
        string=$(osmosisd tx gamm create-pool --pool-file=nativeDenomThreeAssetPool.json --from pools --chain-id=$CHAIN_ID --home $OSMOSIS_HOME --keyring-backend=test -b block --yes 2>&1)
        if [ "$string" != "${string%"$substring"*}" ]; then
            echo "create three asset pool: successful"
            break
        else
            let COUNTER=COUNTER+1
            sleep 0.5
        fi
    done
}

rm -rf $OSMOSIS_HOME

if [[ ! -d $CONFIG_FOLDER ]]
then
    echo $MNEMONIC | osmosisd init -o --chain-id=$CHAIN_ID --home $OSMOSIS_HOME --recover $MONIKER
    install_prerequisites
    edit_genesis
    add_genesis_accounts
    edit_config
fi

osmosisd start --home $OSMOSIS_HOME &

if [[ $STATE == 'true' ]]
then
    create_two_asset_pool "nativeDenomPoolA.json"
    create_two_asset_pool "nativeDenomPoolB.json"
    create_three_asset_pool
fi
wait
