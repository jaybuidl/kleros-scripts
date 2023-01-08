# Simulation of Governor Transactions

:warning: This is an experiment, not for production use.

## TODO
- Simulate all the calls in a submitted list within the same Tenderly fork.

## Prerequisites
- `jq`
- Foundry's `cast`
- Tenderly username and API key added to `.env`

## Usage

For the purpose of this experiment, we use realistic lists submitted to the governor previously. For example [transaction ID 0xc07ed485c7e4e8dce7e1ee373f6179287cc5d66adc1405a028e990ee9f762924](https://etherscan.io/tx/0xc07ed485c7e4e8dce7e1ee373f6179287cc5d66adc1405a028e990ee9f762924)

### Payload of the calls in a list
```bash
$ ./decodeListTx.sh 0xc07ed485c7e4e8dce7e1ee373f6179287cc5d66adc1405a028e990ee9f762924
[
  {
    "to": "0x988b3A538b618C7A603e1c11Ab82Cd16dbE28069",
    "value": "0",
    "description": "Corte General Espanol minstake 2300",
    "input": "0x3e1d09be000000000000000000000000000000000000000000000000000000000000001600000000000000000000000000000000000000000000007caee97613e6700000"
  },
  ...
]
```

### Simulation of the calls in a list

```bash
$ ./simulateListTxCalls.sh 0xc07ed485c7e4e8dce7e1ee373f6179287cc5d66adc1405a028e990ee9f762924 | jq . | tee simulations.json 
{
  "simulation": {
    "id": "3c82b770-cf62-4366-83e8-dd015b26ae9c",
    "status": true,
    "created_at": "2023-01-08T01:17:02.130828333Z"
  },
  "call_trace": {
    "hash": "0x07a8b61ea20dc6273ffa8231026206b942cbf81d14b76a150f6b7eb0865aa6f7",
    "contract_name": "KlerosLiquid",
    "function_name": "changeSubcourtMinStake",
    "function_line_number": 1376,
    "from": "0xe5bcea6f87aaee4a81f64dfdb4d30d400e0e5cf4",
    "from_balance": "1690000000000000000",
    "to": "0x988b3a538b618c7a603e1c11ab82cd16dbe28069",
    "to_balance": "725000000000001255",
    "value": "0",
    "caller": {
      "address": "0xe5bcea6f87aaee4a81f64dfdb4d30d400e0e5cf4",
      "balance": "1644067433734564087"
    },
    "block_timestamp": "0001-01-01T00:00:00Z",
    "gas": 3941417,
    "gas_used": 17395,
    "input": "0x3e1d09be000000000000000000000000000000000000000000000000000000000000001600000000000000000000000000000000000000000000007caee97613e6700000",
    "decoded_input": [
      {
        "soltype": {
          "name": "_subcourtID",
          "type": "uint96",
        },
        "value": "22"
      },
      {
        "soltype": {
          "name": "_minStake",
          "type": "uint256",
        },
        "value": "2300000000000000000000"
      }
    ],
    "balance_diff": [
      {
        "address": "0x535B918F3724001FD6Fb52fCC6cBC220592990A3",
        "original": "28042789060603841416",
        "dirty": "28042808853097559434",
        "is_miner": true
      },
      {
        "address": "0xe5bcEa6F87aAEe4a81f64dfDB4d30d400e0e5cf4",
        "original": "1690000000000000000",
        "dirty": "1689550147879224829",
        "is_miner": false
      }
    ],
    "nonce_diff": [
      {
        "address": "0xe5bcEa6F87aAEe4a81f64dfDB4d30d400e0e5cf4",
        "original": "1",
        "dirty": "2"
      }
    ],
    "state_diff": [
      {
        "address": "0x988b3a538b618c7a603e1c11ab82cd16dbe28069",
        "raw": [
          {
            "address": "0x988b3a538b618c7a603e1c11ab82cd16dbe28069",
            "key": "0xc65a7bb8d6351c1cf70c95a316cc6a92839c986682d98bc35f958f4883f9d39d",
            "original": "0x000000000000000000000000000000000000000000000066ffcbfd5e5a300000",
            "dirty": "0x00000000000000000000000000000000000000000000007caee97613e6700000"
          }
        ]
      }
    ],
    "network_id": "1",
  }
}

```

### Analysis of the results

```bash
$ cat simulations.json | ./grepSimulationStatus.sh 
    "id": "3c82b770-cf62-4366-83e8-dd015b26ae9c",
    "status": true,
    ...
    "id": "8b4bce69-9982-480e-9efc-515c6ef7125f",
    "status": false,
    "error": "execution reverted",
    "error_op": "REVERT",
    "error_file_index": 0,
    "error_line_number": 1379,
    "error_code_start": 59637,
    "error_code_length": 193,
    "error_reason": "A subcourt cannot be the parent of a subcourt with a lower minimum stake.",
        "error": "execution reverted",
        "error_op": "REVERT",
        "error_file_index": 0,
        "error_line_number": 1379,
        "error_code_start": 59637,
        "error_code_length": 193,

```
