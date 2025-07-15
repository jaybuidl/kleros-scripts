#!/usr/bin/env bash

transactionTemplate='
{
    "title": "__TITLE__",
    "address": "0x988b3A538b618C7A603e1c11Ab82Cd16dbE28069",
    "value": "0",
    "data": "__CALLDATA__"
}'

transactions=''

function addTransaction {
    local callData=$1
    local title=$2
    if [ -n "$transactions" ]; then
        transactions="$transactions,"
    fi
    transactions="$transactions$(echo $transactionTemplate | sed "s|__CALLDATA__|$callData|;s|__TITLE__|$title|")"
}

court="Oracle"
courtId=24
addTransaction $(cast calldata "changeSubcourtJurorFee(uint96,uint256)" $courtId $(cast --to-wei 0.008)) "$court changeSubcourtJurorFee 0.008 ETH"
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 6900.0)) "$court changeSubcourtMinStake 6900.0 PNK"

court="Technical"
courtId=4
addTransaction $(cast calldata "changeSubcourtJurorFee(uint96,uint256)" $courtId $(cast --to-wei 0.043)) "$court changeSubcourtJurorFee 0.043 ETH"
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 36000.0)) "$court changeSubcourtMinStake 36000.0 PNK"

court="Blockchain"
courtId=1
addTransaction $(cast calldata "changeSubcourtJurorFee(uint96,uint256)" $courtId $(cast --to-wei 0.01)) "$court changeSubcourtJurorFee 0.01 ETH"
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 8000.0)) "$court changeSubcourtMinStake 8000.0 PNK"

court="Corte General Español"
courtId=22
addTransaction $(cast calldata "changeSubcourtJurorFee(uint96,uint256)" $courtId $(cast --to-wei 0.0078)) "$court changeSubcourtJurorFee 0.0078 ETH"
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 3370.0)) "$court changeSubcourtMinStake 3370.0 PNK"
addTransaction $(cast calldata "changeSubcourtAlpha(uint96,uint256)" $courtId 10000) "$court changeSubcourtAlpha 10000"

court="Humanity"
courtId=23
addTransaction $(cast calldata "changeSubcourtJurorFee(uint96,uint256)" $courtId $(cast --to-wei 0.0052)) "$court changeSubcourtJurorFee 0.0052 ETH"
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 10000.0)) "$court changeSubcourtMinStake 10000.0 PNK"

court="General Court"
courtId=0
addTransaction $(cast calldata "changeSubcourtJurorFee(uint96,uint256)" $courtId $(cast --to-wei 0.0079)) "$court changeSubcourtJurorFee 0.0079 ETH"
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 2850.0)) "$court changeSubcourtMinStake 2850 PNK"
addTransaction $(cast calldata "changeSubcourtAlpha(uint96,uint256)" $courtId 10000) "$court changeSubcourtAlpha 10000"

echo "[$transactions]"
