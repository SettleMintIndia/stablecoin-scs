# WaltzCappable

## Overview

`WaltzCappable` is an abstract contract that implements cappable functionality for Waltz tokens. It extends the base `Waltz` contract, providing features to set and enforce a cap on the total token supply.

## Key Features

1. Ability to set and modify a cap on the total token supply
2. Enforcement of the cap during token minting operations
3. Modifiers to check cap conditions
4. Custom error handling for cap-related operations

## Contract Structure

The `WaltzCappable` contract is structured as follows:

1. **Inheritance**:
   - Inherits from `Waltz`
   - Implements `IWaltzCappable` interface
   - Inherits from `ERC165` for interface detection

2. **State Variables**:
   - `_cap`: Private variable to store the current cap value

3. **Constructor**:
   - Initializes the contract with a specified initial cap value

4. **Functions**:
   - `setCap`: Sets a new cap on the token's total supply
   - `cap`: Returns the current cap value
   - `_checkCap`: Internal function to check if a mint operation would exceed the cap

5. **Modifiers**:
   - `whenCapExceeded`: Ensures the cap is not exceeded
   - `whenCapNotExeeded`: Ensures the cap is not exceeded (note the typo in the original contract)

6. **Interface Support**:
   - `supportsInterface`: Overrides the function to support interface detection

## Usage

1. **Initialization**:
   When deploying a contract that inherits from `WaltzCappable`, specify the initial cap value in the constructor.

2. **Setting the Cap**:
   - Use the `setCap` function to change the cap value
   - Implement proper access control in the inheriting contract to restrict who can call this function

3. **Enforcing the Cap**:
   - Use the `whenCapExceeded` or `whenCapNotExeeded` modifiers on functions that mint tokens
   - Call `_checkCap` before any mint operation to ensure the cap is not exceeded

4. **Querying the Cap**:
   - Use the `cap` function to get the current cap value

## Security Considerations

1. Implement proper access control for the `setCap` function in the inheriting contract
2. Ensure that all minting operations are properly guarded with cap checks
3. Be cautious when setting the initial cap and when changing it to avoid unintended restrictions on token supply

## Custom Errors

The contract includes custom errors:

- `InvalidCap`: Thrown when attempting to set an invalid cap value (0)
- `ExceededCap`: Thrown when a minting operation would exceed the current cap

## Integration

When integrating `WaltzCappable` into your Waltz token contracts:

1. Inherit from `WaltzCappable` in your main token contract
2. Implement the necessary access control for the `setCap` function
3. Use the provided modifiers and `_checkCap` function in your minting operations
4. Override the `_checkCap` function if you need custom cap checking logic

By leveraging `WaltzCappable`, you can add supply cap functionality to your Waltz tokens, providing better control over token issuance and enhancing the overall tokenomics of your project.
