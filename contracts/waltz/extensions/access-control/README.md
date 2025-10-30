# WaltzAccessControl

## Overview

`WaltzAccessControl` is an abstract contract that implements access control functionality for Waltz tokens. It inherits from OpenZeppelin's `AccessControlDefaultAdminRules` contract, providing a robust and flexible role-based access control system with additional features for managing the default admin role.

## Key Features

1. Role-based access control
2. Default admin role with customizable delay for security
3. Supports interface detection for `IAccessControlDefaultAdminRules`


## Contract Structure

The `WaltzAccessControl` contract is structured as follows:

1. **Inheritance**:
   - Inherits from OpenZeppelin's `AccessControlDefaultAdminRules`
   - Implements `IAccessControlDefaultAdminRules` interface

2. **Constants**:
   - `MINTER_ROLE`: Defines the role for minting tokens
   - `BURNER_ROLE`: Defines the role for burning tokens
   - `PAUSER_ROLE`: Defines the role for pausing/unpausing token operations

3. **Constructor**:
   - Initializes the contract with a specified initial admin and delay for admin role transfers

4. **Functions**:
   - `supportsInterface`: Overrides the function to support interface detection

## Usage

1. **Initialization**:
   When deploying a contract that inherits from `WaltzAccessControl`, specify the initial admin address and the delay for admin role transfers.

2. **Role Management**:
   - Use OpenZeppelin's `AccessControl` functions to grant and revoke roles
   - The predefined roles (MINTER_ROLE, BURNER_ROLE, PAUSER_ROLE) can be assigned to addresses as needed

3. **Admin Role Management**:
   - The default admin role is managed with additional security measures, including a delay for transfers
   - Use the functions provided by `AccessControlDefaultAdminRules` for admin role operations

4. **Interface Support**:
   - The contract supports the `IAccessControlDefaultAdminRules` interface, allowing for standardized interaction with other contracts

## Security Considerations

1. Carefully manage role assignments to maintain proper access control
2. The delay in admin role transfers provides an additional security layer, allowing time for intervention if unauthorized changes are detected
3. Regularly review and audit the access control setup to ensure it aligns with the project's security requirements

## Integration

When integrating `WaltzAccessControl` into your Waltz token contracts:

1. Inherit from `WaltzAccessControl` in your main token contract
2. Use the predefined roles (MINTER_ROLE, BURNER_ROLE, PAUSER_ROLE) to restrict access to sensitive functions
3. Implement proper checks using `onlyRole` modifiers in functions that require specific permissions

By leveraging `WaltzAccessControl`, you can ensure that your Waltz token contracts have a robust and flexible access control system, enhancing the security and manageability of your token ecosystem.

