# KIP-66: PNK Minting to the Cooperative Multisig

## 2026 Mint

Mint 110,234,000 PNK to multisig `eth:0xE979438B331b28D3246f8444b74caB0f874b40e8`

### Call structure
```typescript
// With access restricted to KlerosLiquid (= PNK controller)
mintCall = PNK.generateTokens(_owner = coopMultisig, _amount = $amount)

// With access restricted to Governor
KlerosLiquid.executeGovernorProposal(_destination = PNK, _amount = 0, _data = $mintCall)
```

### Tx building

```bash
./tx-builder.sh  | jq .
[
  {
    "title": "KlerosLiquid.executeGovernorProposal() -> PNK.generateTokens(0xE979438B331b28D3246f8444b74caB0f874b40e8, 110234000)",
    "address": "0x988b3a538b618c7a603e1c11ab82cd16dbe28069",
    "value": "0",
    "data": "0x751accd000000000000000000000000093ed3fbe21207ec2e8f2d3c3de6e058cb73bc04d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000044827f32c0000000000000000000000000e979438b331b28d3246f8444b74cab0f874b40e80000000000000000000000000000000000000000005b2ef51d34e4f8ac40000000000000000000000000000000000000000000000000000000000000"
  }
]
```

### Tenderly Simulation
https://www.tdly.co/shared/simulation/19b1baa1-5c61-4658-b080-09021c6ba1c0
<img width="1472" height="718" alt="image" src="https://github.com/user-attachments/assets/e6d0ab62-4c67-4527-a1ee-16ce327cd8d7" />

