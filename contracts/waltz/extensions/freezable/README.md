# WaltzFreezable

## Overview

`WaltzFreezable` is an abstract contract that implements freezable functionality for Waltz tokens. It inherits from the `IWaltzFreezable` interface, the `Waltz` contract, and OpenZeppelin's `ERC165` for interface detection. This contract allows authorized addresses to freeze and thaw both entire addresses and specific token amounts, providing granular control over token transfers and balances.

## Key Features

1. **Address Freezing**: Ability to freeze and thaw entire addresses.
2. **Token Freezing**: Partial freezing of token amounts for specific addresses.
3. **Batch Operations**: Support for freezing and thawing multiple addresses or token amounts in a single transaction.
4. **Role-Based Access Control**: Uses `FREEZER_ROLE` to restrict access to freezing and thawing operations.

## Main Functions

### Address Freezing

- `freezeAddress(address _userAddress)`: Freezes a specific address.
- `thawAddress(address _userAddress)`: Thaws a previously frozen address.
- `isFrozen(address _userAddress)`: Checks if an address is frozen.

### Token Freezing

- `freezeTokens(address _userAddress, uint256 _amount)`: Freezes a specific amount of tokens for an address.
- `thawTokens(address _userAddress, uint256 _amount)`: Thaws a specific amount of frozen tokens for an address.
- `frozenTokens(address _userAddress)`: Returns the amount of frozen tokens for an address.

### Batch Operations

- `batchFreezeAddress(address[] calldata _userAddresses)`: Freezes multiple addresses in one transaction.
- `batchThawAddress(address[] calldata _userAddresses)`: Thaws multiple addresses in one transaction.
- `batchFreezeTokens(address[] calldata _userAddresses, uint256[] calldata _amounts)`: Freezes tokens for multiple addresses.
- `batchThawTokens(address[] calldata _userAddresses, uint256[] calldata _amounts)`: Thaws tokens for multiple addresses.

## Modifiers

- `whenThawed(address _userAddress)`: Ensures the address is not frozen.
- `whenFrozen(address _userAddress)`: Ensures the address is frozen.
- `notExceedingThawedBalance(address _userAddress, uint256 _amount)`: Ensures the amount does not exceed the thawed balance.

## Events

- `AddressFrozen(address indexed _userAddress, address indexed _by)`: Emitted when an address is frozen.
- `AddressThawed(address indexed _userAddress, address indexed _by)`: Emitted when an address is thawed.
- `TokensFrozen(address indexed _userAddress, uint256 _amount, address indexed _by)`: Emitted when tokens are frozen.
- `TokensThawed(address indexed _userAddress, uint256 _amount, address indexed _by)`: Emitted when tokens are thawed.

## Usage

To use `WaltzFreezable`, inherit from it in your token contract and implement the necessary role-based access control for the `FREEZER_ROLE`. This will allow designated addresses to manage the freezing and thawing of addresses and token amounts.

## Security Considerations

- Ensure proper access control is implemented for all freezing and thawing functions.
- Be cautious when using batch operations, as they can affect multiple addresses at once.
- Consider the implications of freezing addresses or tokens on your token's ecosystem and user experience.

## Interface Support

The contract implements `supportsInterface` to indicate support for the `IWaltzFreezable` interface, allowing for standard interface detection.
