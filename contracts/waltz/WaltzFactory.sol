// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IWaltzRegistry } from "./interfaces/IWaltzRegistry.sol";
import { IWaltzFactory } from "./interfaces/IWaltzFactory.sol";

/**
 * @title WaltzFactory
 * @dev Abstract contract for creating and managing Waltz tokens
 * @notice This contract provides the base functionality for token creation and registration
 * @custom:security-contact security@settlemint.com
 */
abstract contract WaltzFactory is IWaltzFactory {
    /**
     * @dev The role that can create new tokens
     */
    bytes32 public constant TOKEN_CREATION_ROLE = keccak256("TOKEN_CREATION_ROLE");

    /**
     * @dev The token registry where new tokens will be registered
     */
    IWaltzRegistry private immutable _registry;

    /**
     * @dev Constructor for the WaltzFactory contract
     * @param registry_ The address of the token registry contract
     */
    constructor(IWaltzRegistry registry_) {
        _registry = registry_;
    }

    /**
     * @dev Returns the address of the token registry
     * @return IWaltzRegistry The token registry interface
     */
    function registry() external view returns (IWaltzRegistry) {
        return _registry;
    }
}
