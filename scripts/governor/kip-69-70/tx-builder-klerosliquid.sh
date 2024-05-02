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

court="Non-Technical"
courtId=2
addTransaction $(cast calldata "changeSubcourtJurorFee(uint96,uint256)" $courtId $(cast --to-wei 0.02)) "$court changeSubcourtJurorFee 0.02 ETH"
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 13000.0)) "$court changeSubcourtMinStake 13000.0 PNK"

court="Token Listing"
courtId=3
addTransaction $(cast calldata "changeSubcourtJurorFee(uint96,uint256)" $courtId $(cast --to-wei 0.062)) "$court changeSubcourtJurorFee 0.062 ETH"
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 36000.0)) "$court changeSubcourtMinStake 36000.0 PNK"

court="Technical"
courtId=4
addTransaction $(cast calldata "changeSubcourtJurorFee(uint96,uint256)" $courtId $(cast --to-wei 0.037)) "$court changeSubcourtJurorFee 0.037 ETH"
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 22000.0)) "$court changeSubcourtMinStake 22000.0 PNK"

court="Blockchain"
courtId=1
addTransaction $(cast calldata "changeSubcourtJurorFee(uint96,uint256)" $courtId $(cast --to-wei 0.02)) "$court changeSubcourtJurorFee 0.02 ETH"
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 8100.0)) "$court changeSubcourtMinStake 8100.0 PNK"

court="Onboarding"
courtId=8
addTransaction $(cast calldata "changeSubcourtJurorFee(uint96,uint256)" $courtId $(cast --to-wei 0.01)) "$court changeSubcourtJurorFee 0.01 ETH"
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 3700.0)) "$court changeSubcourtMinStake 3700.0 PNK"
addTransaction $(cast calldata "changeSubcourtAlpha(uint96,uint256)" $courtId 8100) "$court changeSubcourtAlpha 0.81"

court="Corte General Español"
courtId=22
addTransaction $(cast calldata "changeSubcourtJurorFee(uint96,uint256)" $courtId $(cast --to-wei 0.02)) "$court changeSubcourtJurorFee 0.02 ETH"
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 5900.0)) "$court changeSubcourtMinStake 5900.0 PNK"

court="Humanity"
courtId=23
addTransaction $(cast calldata "changeSubcourtJurorFee(uint96,uint256)" $courtId $(cast --to-wei 0.02)) "$court changeSubcourtJurorFee 0.02 ETH"
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 10000.0)) "$court changeSubcourtMinStake 10000.0 PNK"

court="General Court"
courtId=0
addTransaction $(cast calldata "changeSubcourtJurorFee(uint96,uint256)" $courtId $(cast --to-wei 0.02)) "$court changeSubcourtJurorFee 0.02 ETH"
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 3700.0)) "$court changeSubcourtMinStake 3700.0 PNK"

echo "[$transactions]"
