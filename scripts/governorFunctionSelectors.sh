#!/bin/bash

# from ethers.utils.Interface.getSighash()
functions='changePinakion , 0x00f5822c
RNBlock , 0x023d44df
disputesWithoutJurors , 0x03432744
passPhase , 0x0b274f2e
governor , 0x0c340a24
lastDelayedSetStake , 0x0d44cf79
disputeStatus , 0x10f169e8
passPeriod , 0x115d5376
maxDrawingTime , 0x1b92bbbe
currentRuling , 0x1c3db16d
courts , 0x1f5a0dd2
execute , 0x2d29a47b
ALPHA_DIVISOR , 0x2ea7b4d0
castVote , 0x3850f804
changeSubcourtMinStake , 0x3e1d09be
getSubcourt , 0x40026c87
appeal , 0x49912f88
onTransfer , 0x4a393149
disputes , 0x564a565d
changeSubcourtTimesPerPeriod , 0x57260364
changeSubcourtJurorFee , 0x59354c77
changeSubcourtAlpha , 0x5bc24dd3
castCommit , 0x5c92e2f6
RN , 0x5e4a627d
RNGenerator , 0x6a4f8f39
executeGovernorProposal , 0x751accd0
changeMinStakingTime , 0x823cfd70
NON_PAYABLE_AMOUNT , 0x840bc19c
setStake , 0x85c855f3
executeRuling , 0x8bb04875
getVote , 0x8ce7ff4a
changeRNGenerator , 0x96d92a72
executeDelayedSetStakes , 0x9929057b
stakeOf , 0xa2473cc1
changeSubcourtJurorsForJump , 0xa57366e7
appealPeriod , 0xafe15cfb
phase , 0xb1c9fe6e
MAX_STAKE_PATHS , 0xb4a61608
delayedSetStakes , 0xb78a80ff
lastPhaseChange , 0xb888adfa
minStakingTime , 0xc057eca7
nextDelayedSetStake , 0xc108f3b4
createDispute , 0xc13517e1
drawJurors , 0xcbd88663
createSubcourt , 0xce9e7730
getJuror , 0xd4155d1f
onApprove , 0xda682aeb
jurors , 0xdca5f6b0
changeMaxDrawingTime , 0xdd5e5cb5
getDispute , 0xe3a96cbd
getVoteCounter , 0xe3b0073e
changeGovernor , 0xe4c0aaf4
MIN_JURORS , 0xeaff425a
appealCost , 0xf23f16e6
proxyPayment , 0xf48c3054
lockInsolventTransfers , 0xf66d685a
arbitrationCost , 0xf7434ea9
pinakion , 0xfbf405b0'

governorFile="govenor_update_list_-_sheet1.csv"
contractAddr=0x988b3a538b618c7a603e1

for line in $(cat $governorFile | sed 's/ /_/g' | grep $contractAddr)
do 
    sel="$(echo -n "$line" | cut -f4 -d"," | cut -c 1-10)"
    f="$(echo "$functions" | grep $sel | cut -f1 -d,)"
    echo "$f,$sel,$line"
done