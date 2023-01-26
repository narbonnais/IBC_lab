#!/bin/sh

sleep 15

echo "Setting up relayer"

rm -rf ~/.relayer/*

rly config init

rly chains add-dir chains

sleep 5

rly chains list

rly keys restore localosmosis lo-test1 "notice oak worry limit wrap speak medal online prefer cluster roof addict wrist behave treat actual wasp year salad speed social layer crew genius"
rly keys restore localgaia lg-test1 "notice oak worry limit wrap speak medal online prefer cluster roof addict wrist behave treat actual wasp year salad speed social layer crew genius"


rly q balance localosmosis
rly q balance localgaia

rly chains list

rly paths new localgaia localosmosis localgaia-localosmosis --src-port transfer --dst-port transfer --order unordered

sleep 5

rly paths show localgaia-localosmosis

rly transact link localgaia-localosmosis --src-port transfer --dst-port transfer

sleep 5

rly paths show localgaia-localosmosis

rly start