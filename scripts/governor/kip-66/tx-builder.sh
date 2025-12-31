#!/usr/bin/env bash

transactionTemplate='
{
    "title": "__TITLE__",
    "address": "__ADDRESS__",
    "value": "0",
    "data": "__CALLDATA__"
}'

transactions=''

function addTransaction {
    local address=$1
    local callData=$2
    local title=$3
    if [ -n "$transactions" ]; then
        transactions="$transactions,"
    fi
    transactions="$transactions$(echo $transactionTemplate | sed "s|__CALLDATA__|$callData|;s|__TITLE__|$title|;s|__ADDRESS__|$address|")"
}

COOP_MULTISIG_ADDRESS=0xE979438B331b28D3246f8444b74caB0f874b40e8
PNK_ADDRESS=0x93ED3FBe21207Ec2E8f2d3c3de6e058Cb73Bc04d
KLEROS_LIQUID_ADDRESS=0x988b3A538b618C7A603e1c11Ab82Cd16dbE28069
PNK_AMOUNT=78402000

mintCall=$(cast calldata "generateTokens(address,uint256)" $COOP_MULTISIG_ADDRESS "$(cast --to-wei $PNK_AMOUNT)")
klerosLiquidCall=$(cast calldata "executeGovernorProposal(address,uint256,bytes)" $PNK_ADDRESS 0 "$mintCall")

addTransaction $KLEROS_LIQUID_ADDRESS "$klerosLiquidCall" "KlerosLiquid.executeGovernorProposal() -> PNK.generateTokens($COOP_MULTISIG_ADDRESS, $PNK_AMOUNT)"
echo "[$transactions]"