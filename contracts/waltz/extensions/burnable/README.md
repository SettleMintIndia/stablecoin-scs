# WaltzBurnable

## Overview

`WaltzBurnable` is an abstract contract that implements burnable functionality for Waltz tokens. It extends the base `Waltz` contract, providing additional features to burn tokens and manage burning permissions.

## Key Features

1. Token burning functionality
2. Role-based access control for burning operations
3. Batch burning capability
4. Custom error handling for burning operations

## Contract Structure

The `WaltzBurnable` contract is structured as follows:

1. **Inheritance**:
   - Inherits from `Waltz`

2. **Constants**:
   - `BURNER_ROLE`: Defines the role for accounts that can burn tokens

3. **Functions**:
   - `burn`: Burns a specific amount of tokens from the caller's account
   - `burnFrom`: Burns a specific amount of tokens from a given account
   - `batchBurnFrom`: Burns tokens from multiple addresses in a single transaction

## Usage

1. **Initialization**:
   When deploying a contract that inherits from `WaltzBurnable`, ensure that the base `Waltz` contract is properly initialized.

2. **Role Management**:
   - Grant the `BURNER_ROLE` to accounts that should be allowed to burn tokens
   - Use the access control functions inherited from `Waltz` to manage this role

3. **Burning Tokens**:
   - Use the `burn` function to burn tokens from the caller's account
   - Use the `burnFrom` function to burn tokens from a specific account (requires allowance)
   - Use the `batchBurnFrom` function to burn tokens from multiple accounts in a single transaction

## Security Considerations

1. Carefully manage role assignments to control who can burn tokens
2. Ensure proper access control checks are implemented in the derived contract for the `burn` and `burnFrom` functions
3. Implement proper allowance checks when using `burnFrom` to prevent unauthorized burning

## Integration

When integrating `WaltzBurnable` into your Waltz token contracts:

1. Inherit from `WaltzBurnable` in your main token contract
2. Implement the `burn` and `burnFrom` functions with appropriate access control
3. Use the `batchBurnFrom` function for efficient batch burning operations
4. Ensure that the `BURNER_ROLE` is properly managed

## Custom Errors

The contract includes custom errors:

- `BatchErrorArrayLengthMismatch`: Thrown when the lengths of address and amount arrays in `batchBurnFrom` don't match
- `BurnAmountExceedsBalance`: Thrown when the burn amount exceeds the account's balance
- `BurnFromZeroAddress`: Thrown when attempting to burn from the zero address
- `BurnAmountExceedsAllowance`: Thrown when the burn amount exceeds the spender's allowance

By leveraging `WaltzBurnable`, you can add token burning functionality to your Waltz tokens while maintaining proper access control and efficiency in burning operations.
