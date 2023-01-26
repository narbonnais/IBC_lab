#!/bin/sh

CHAIN_ID=localgaia
GAIA_HOME=$HOME/.gaiad
CONFIG_FOLDER=$GAIA_HOME/config
MONIKER=val
STATE='false'

MNEMONIC="bottom loan skill merry east cradle onion journey palm apology verb edit desert impose absurd oil bubble sweet glove shallow size build burst effort"

install_prerequisites () {
    apk add dasel
    apk add jq
}

edit_genesis () {

    GENESIS=$CONFIG_FOLDER/genesis.json

    # Update staking module
    dasel put string -f $GENESIS '.app_state.staking.params.bond_denom' 'uatom'
    dasel put string -f $GENESIS '.app_state.staking.params.unbonding_time' '240s'

    # Update crisis module
    dasel put string -f $GENESIS '.app_state.crisis.constant_fee.denom' 'uatom'

    # Udpate gov module
    dasel put string -f $GENESIS '.app_state.gov.voting_params.voting_period' '60s'
    dasel put string -f $GENESIS '.app_state.gov.deposit_params.min_deposit.[0].denom' 'uatom'
}

add_genesis_accounts () {

    echo "notice oak worry limit wrap speak medal online prefer cluster roof addict wrist behave treat actual wasp year salad speed social layer crew genius" | gaiad keys add lg-test1 --recover --keyring-backend test --home $GAIA_HOME
    echo "quality vacuum heart guard buzz spike sight swarm shove special gym robust assume sudden deposit grid alcohol choice devote leader tilt noodle tide penalty" | gaiad keys add lg-test2 --recover --keyring-backend test --home $GAIA_HOME
    echo "symbol force gallery make bulk round subway violin worry mixture penalty kingdom boring survey tool fringe patrol sausage hard admit remember broken alien absorb" | gaiad keys add lg-test3 --recover --keyring-backend test --home $GAIA_HOME
    echo "bounce success option birth apple portion aunt rural episode solution hockey pencil lend session cause hedgehog slender journey system canvas decorate razor catch empty" | gaiad keys add lg-test4 --recover --keyring-backend test --home $GAIA_HOME
    echo "second render cat sing soup reward cluster island bench diet lumber grocery repeat balcony perfect diesel stumble piano distance caught occur example ozone loyal" | gaiad keys add lg-test5 --recover --keyring-backend test --home $GAIA_HOME
    echo "spatial forest elevator battle also spoon fun skirt flight initial nasty transfer glory palm drama gossip remove fan joke shove label dune debate quick" | gaiad keys add lg-test6 --recover --keyring-backend test --home $GAIA_HOME
    echo "noble width taxi input there patrol clown public spell aunt wish punch moment will misery eight excess arena pen turtle minimum grain vague inmate" | gaiad keys add lg-test7 --recover --keyring-backend test --home $GAIA_HOME
    echo "cream sport mango believe inhale text fish rely elegant below earth april wall rug ritual blossom cherry detail length blind digital proof identify ride" | gaiad keys add lg-test8 --recover --keyring-backend test --home $GAIA_HOME
    echo "index light average senior silent limit usual local involve delay update rack cause inmate wall render magnet common feature laundry exact casual resource hundred" | gaiad keys add lg-test9 --recover --keyring-backend test --home $GAIA_HOME
    echo "prefer forget visit mistake mixture feel eyebrow autumn shop pair address airport diesel street pass vague innocent poem method awful require hurry unhappy shoulder" | gaiad keys add lg-test10 --recover --keyring-backend test --home $GAIA_HOME
    echo $MNEMONIC | gaiad keys add $MONIKER --recover --keyring-backend=test --home $GAIA_HOME

    gaiad add-genesis-account $(gaiad keys show lg-test1 --home $GAIA_HOME --output json --keyring-backend test | jq '.address' | tr -d '"') 100000000000uatom,100000000000stake --home $GAIA_HOME
    gaiad add-genesis-account $(gaiad keys show lg-test2 --home $GAIA_HOME --output json --keyring-backend test | jq '.address' | tr -d '"') 100000000000uatom,100000000000stake --home $GAIA_HOME
    gaiad add-genesis-account $(gaiad keys show lg-test3 --home $GAIA_HOME --output json --keyring-backend test | jq '.address' | tr -d '"') 100000000000uatom,100000000000stake --home $GAIA_HOME
    gaiad add-genesis-account $(gaiad keys show lg-test4 --home $GAIA_HOME --output json --keyring-backend test | jq '.address' | tr -d '"') 100000000000uatom,100000000000stake --home $GAIA_HOME
    gaiad add-genesis-account $(gaiad keys show lg-test5 --home $GAIA_HOME --output json --keyring-backend test | jq '.address' | tr -d '"') 100000000000uatom,100000000000stake --home $GAIA_HOME
    gaiad add-genesis-account $(gaiad keys show lg-test6 --home $GAIA_HOME --output json --keyring-backend test | jq '.address' | tr -d '"') 100000000000uatom,100000000000stake --home $GAIA_HOME
    gaiad add-genesis-account $(gaiad keys show lg-test7 --home $GAIA_HOME --output json --keyring-backend test | jq '.address' | tr -d '"') 100000000000uatom,100000000000stake --home $GAIA_HOME
    gaiad add-genesis-account $(gaiad keys show lg-test8 --home $GAIA_HOME --output json --keyring-backend test | jq '.address' | tr -d '"') 100000000000uatom,100000000000stake --home $GAIA_HOME
    gaiad add-genesis-account $(gaiad keys show lg-test9 --home $GAIA_HOME --output json --keyring-backend test | jq '.address' | tr -d '"') 100000000000uatom,100000000000stake --home $GAIA_HOME
    gaiad add-genesis-account $(gaiad keys show lg-test10 --home $GAIA_HOME --output json --keyring-backend test | jq '.address' | tr -d '"') 100000000000uatom,100000000000stake --home $GAIA_HOME
    gaiad add-genesis-account $(gaiad keys show $MONIKER --home $GAIA_HOME --output json --keyring-backend test | jq '.address' | tr -d '"') 1000000000000uatom,1000000000000stake --home $GAIA_HOME

    gaiad gentx $MONIKER 500000000uatom --keyring-backend=test --chain-id=$CHAIN_ID --home $GAIA_HOME

    gaiad collect-gentxs --home $GAIA_HOME
}

edit_config () {
    # Remove seeds
    dasel put string -f $CONFIG_FOLDER/config.toml '.p2p.seeds' ''

    # Expose the rpc
    dasel put string -f $CONFIG_FOLDER/config.toml '.rpc.laddr' "tcp://0.0.0.0:26657"
}

rm -rf $GAIA_HOME

if [[ ! -d $CONFIG_FOLDER ]]
then
    echo $MNEMONIC | gaiad init -o --chain-id=$CHAIN_ID --home $GAIA_HOME --recover $MONIKER
    install_prerequisites
    edit_genesis
    add_genesis_accounts
    edit_config
fi

gaiad start --home $GAIA_HOME &

wait
