# Sony Bank Stable Coin
##
## Configuration
### Addresses

Development:
```
RegistryModule#Registry - 0x8f80ea28795aD1883b6604E8bBB1e14Cb096cCd3
FactoryModule#Factory - 0x968EaD0c0A561ee863028e42A0cfec745A2cB7f2
```

Production:
```
RegistryModule#Registry - 0x5B03FD17158F9d3d07Bb22BDE0887c6A5221260F
FactoryModule#Factory - 0xba7B63B2c00aFEcD3866b9dD590B0517D4F54ad2
```

### Environment Variables

```
npx hardhat vars set WALLET_VAULT 0xA818C7A87604D9cfBFDd2232114FD894A5E446A3
npx hardhat vars set WALLET_CREATOR 0xf4e69fDf11e743A12561F1CB8bEc092E8FAa00c7
```

### Latest deployed contracts on Amoy
PrivadoUVModule#PrivadoIdUniversalVerifier - 0x14165388946a734cfd15fFAc9823e3457a009f6D
RegistryModule#Registry - 0x14962A881EAc403b600B484e777d8dE7232b3223
FactoryModule#Factory - 0xf495f4a4163EC9aB3CC1171F62c0fd6cfBf7595a

### Before running
npm run graph:compile
run `forge build` to get the out folder with contract abis