# KIP-66: PNK Minting to the Cooperative Multisig

## 2026 Mint

Mint 78,402,000 PNK to multisig `eth:0xE979438B331b28D3246f8444b74caB0f874b40e8`

### Call structure
```typescript
// With access restricted to KlerosLiquid (= PNK controller)
mintCall = PNK.generateTokens(_owner = coopMultisig, _amount = 78402000000000000000000000)

// With access restricted to Governor
KlerosLiquid.executeGovernorProposal(_destination = PNK, _amount = 0, _data = $mintCall)
```

### Tx building

```bash
./tx-builder.sh  | jq .
[
  {
    "title": "KlerosLiquid.executeGovernorProposal() -> PNK.generateTokens(0xE979438B331b28D3246f8444b74caB0f874b40e8, 78402000)",
    "address": "0x988b3a538b618c7a603e1c11ab82cd16dbe28069",
    "value": "0",
    "data": "0x751accd000000000000000000000000093ed3fbe21207ec2e8f2d3c3de6e058cb73bc04d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000044827f32c0000000000000000000000000e979438b331b28d3246f8444b74cab0f874b40e800000000000000000000000000000000000000000040da44efb5511ea540000000000000000000000000000000000000000000000000000000000000"
  }
]
```

### Tenderly Simulation
https://www.tdly.co/shared/simulation/345ff293-05ff-44a2-b816-97108c810de1

<img width="1717" height="831" alt="image" src="https://github.com/user-attachments/assets/b6284ae8-4490-46f6-af5f-3f83f205e43e" />
