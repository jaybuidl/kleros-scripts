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

function getCurrentMinStake {
  local courtId=$1
  cast --from-wei "$(cast call -r "$(mesc url gnosis_alchemy)" 0x9C1dA9A04925bDfDedf0f6421bC7EEa8305F9002 "courts(uint)(uint96,bool,uint,uint,uint,uint)" $courtId --json | jq -r '.[2]')"
}

function minStakeDiff {
  local courtId=$1
  local proposedMinStake=$2
  local currentMinStake=$(getCurrentMinStake $courtId) 
  diff=$(python3 -c "print(int($proposedMinStake) - int($currentMinStake))")
  echo "Changing from $currentMinStake to $proposedMinStake (diff: $diff)"
}

echo "General Court"
# Proposed juror fee : 12.0 xDai
# Proposed minstake : 1200.0 PNK
courtId=0
minStakeDiff $courtId 1200.0
addTransaction $(cast calldata "changeSubcourtJurorFee(uint96,uint256)" $courtId $(cast --to-wei 12.0))
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 1200.0))
echo
echo "xDai Curation"
# Proposed juror fee : 7.2 xDai
# Proposed minstake : 1400.0 PNK
# Proposed alpha : 0.48
courtId=1
minStakeDiff $courtId 1400.0
addTransaction $(cast calldata "changeSubcourtJurorFee(uint96,uint256)" $courtId $(cast --to-wei 7.2))
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 1400.0))
addTransaction $(cast calldata "changeSubcourtAlpha(uint96,uint256)" $courtId 4800)
echo
echo "xDai Development"
# Proposed juror fee : 33.0 xDai
# Proposed minstake : 6300.0 PNK
courtId=12
minStakeDiff $courtId 6300.0
addTransaction $(cast calldata "changeSubcourtJurorFee(uint96,uint256)" $courtId $(cast --to-wei 33))
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 6300.0))
echo
echo "xDai Solidity"
# Proposed juror fee : 33.0 xDai
# Proposed minstake : 6300.0 PNK
courtId=13
minStakeDiff $courtId 6300.0
addTransaction $(cast calldata "changeSubcourtJurorFee(uint96,uint256)" $courtId $(cast --to-wei 33))
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 6300.0))
echo
echo "xDai Javascript"
# Proposed juror fee : 33.0 xDai
# Proposed minstake : 6300.0 PNK
courtId=14
minStakeDiff $courtId 6300.0
addTransaction $(cast calldata "changeSubcourtJurorFee(uint96,uint256)" $courtId $(cast --to-wei 33))
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 6300.0))
echo
echo "xDai Humanity"
# Proposed juror fee : 6.0 xDai
# Proposed minstake : 1200.0 PNK
# Proposed alpha : 1
courtId=18
minStakeDiff $courtId 1200.0
addTransaction $(cast calldata "changeSubcourtJurorFee(uint96,uint256)" $courtId $(cast --to-wei 6))
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 1200.0))
addTransaction $(cast calldata "changeSubcourtAlpha(uint96,uint256)" $courtId 10000)
echo
echo "Corte General en Español"
# Proposed juror fee : 15.0 xDai
# Proposed minstake : 2800.0 PNK
courtId=15
minStakeDiff $courtId 2800.0
addTransaction $(cast calldata "changeSubcourtJurorFee(uint96,uint256)" $courtId $(cast --to-wei 15.0))
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 2800.0))
echo
echo "Corte de Curación en Español"
# Proposed juror fee : 7.2 xDai
# Proposed minstake : 2800.0 PNK
# Proposed alpha : 0.24
courtId=16
minStakeDiff $courtId 2800.0
addTransaction $(cast calldata "changeSubcourtJurorFee(uint96,uint256)" $courtId $(cast --to-wei 7.2))
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 2800.0))
addTransaction $(cast calldata "changeSubcourtAlpha(uint96,uint256)" $courtId 2400)
echo
echo "Blockchain No Técnica"
# Proposed juror fee : 16.0 xDai
# Proposed minstake : 4400.0 PNK
# Proposed alpha : 0.5
courtId=17
minStakeDiff $courtId 4400.0
addTransaction $(cast calldata "changeSubcourtJurorFee(uint96,uint256)" $courtId $(cast --to-wei 16))
addTransaction $(cast calldata "changeSubcourtMinStake(uint96,uint256)" $courtId $(cast --to-wei 4400.0))
addTransaction $(cast calldata "changeSubcourtAlpha(uint96,uint256)" $courtId 5000)
echo

echo $transactionBatch | sed "s|__BATCH__|$transactions|"
