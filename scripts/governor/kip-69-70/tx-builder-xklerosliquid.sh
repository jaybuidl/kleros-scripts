#!/usr/bin/env bash

transactionBatch='
{
  "version": "1.0",
  "chainId": "100",
  "createdAt": 1714653878777,
  "meta": {
    "name": "Transactions Batch",
    "description": "",
    "txBuilderVersion": "1.16.5",
    "createdFromSafeAddress": "0x5112D584a1C72Fc250176B57aEba5fFbbB287D8F",
    "createdFromOwnerAddress": ""
  },
  "transactions": [ __BATCH__ ]
}'

transactionTemplate='
    {
      "to": "0x9C1dA9A04925bDfDedf0f6421bC7EEa8305F9002",
      "value": "0",
      "data": "__CALLDATA__",
      "contractMethod": {
        "inputs": [],
        "name": "fallback",
        "payable": true
      },
      "contractInputsValues": null
    }
'

transactions=''

function addTransaction {
  local callData=$1
  if [ -n "$transactions" ]; then
      transactions="$transactions,"
  fi
  transactions="$transactions$(echo $transactionTemplate | sed "s|__CALLDATA__|$callData|")"
}

# xDai Curation
courtId=1
addTransaction $(cast calldata "changeSubcourtJurorFee(uint96,uint256)" $courtId $(cast --to-wei 6.6))
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 2100.0))
addTransaction $(cast calldata "changeSubcourtAlpha(uint96,uint256)" $courtId 2500)

# English Language
courtId=2
addTransaction $(cast calldata "changeSubcourtJurorFee(uint96,uint256)" $courtId $(cast --to-wei 20.0))
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 3700.0))

# Spanish-English Translation
courtId=3
addTransaction $(cast calldata "changeSubcourtJurorFee(uint96,uint256)" $courtId $(cast --to-wei 8.6))
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 3700.0))

# French-English Translation
courtId=4
addTransaction $(cast calldata "changeSubcourtJurorFee(uint96,uint256)" $courtId $(cast --to-wei 8.6))
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 3700.0))

# Portuguese-English Translation
courtId=5
addTransaction $(cast calldata "changeSubcourtJurorFee(uint96,uint256)" $courtId $(cast --to-wei 8.6))
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 3700.0))

# German-English Translation
courtId=6
addTransaction $(cast calldata "changeSubcourtJurorFee(uint96,uint256)" $courtId $(cast --to-wei 11.0))
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 3700.0))

# Russian-English Translation
courtId=7
addTransaction $(cast calldata "changeSubcourtJurorFee(uint96,uint256)" $courtId $(cast --to-wei 11.0))
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 3700.0))

# Korean-English Translation
courtId=8
addTransaction $(cast calldata "changeSubcourtJurorFee(uint96,uint256)" $courtId $(cast --to-wei 14.0))
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 3700.0))

# Japanese-English Translation
courtId=9
addTransaction $(cast calldata "changeSubcourtJurorFee(uint96,uint256)" $courtId $(cast --to-wei 14.0))
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 3700.0))

# Turkish-English Translation
courtId=10
addTransaction $(cast calldata "changeSubcourtJurorFee(uint96,uint256)" $courtId $(cast --to-wei 14.0))
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 3700.0))

# Chinese-English Translation
courtId=11
addTransaction $(cast calldata "changeSubcourtJurorFee(uint96,uint256)" $courtId $(cast --to-wei 14.0))
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 3700.0))

# Corte de Curación en Español
courtId=16
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 4100.0))
addTransaction $(cast calldata "changeSubcourtAlpha(uint96,uint256)" $courtId 1300)

# Blockchain No Técnica
courtId=17
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 4100.0))
addTransaction $(cast calldata "changeSubcourtAlpha(uint96,uint256)" $courtId 4100)

# Corte General en Español
courtId=15
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 4100.0))
addTransaction $(cast calldata "changeSubcourtAlpha(uint96,uint256)" $courtId 5000)

#) General Court
courtId=0
addTransaction $(cast calldata "changeSubcourtJurorFee(uint96,uint256)" $courtId $(cast --to-wei 14.0))
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 2100.0))
addTransaction $(cast calldata "changeSubcourtAlpha(uint96,uint256)" $courtId 10000)

echo $transactionBatch | sed "s|__BATCH__|$transactions|"
