// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title IWaltzRegistryEvents
 * @notice Interface for defining events related to Waltz registry functionality
 * @dev This interface should be implemented by contracts that handle Waltz registry events
 * @custom:security-contact security@settlemint.com
 */
interface IWaltzRegistryEvents {
    /**
     * @notice Event emitted when a token is added to the registry
     * @dev This event is triggered when a new token is successfully registered
     * @param tokenAddress The address of the token contract being added
     * @param symbol The symbol of the token being added
     * @param tokenFactory The address of the factory contract that created the token
     * @param extraData Any extra data associated with the token
     */
    event TokenAdded(address tokenAddress, string symbol, address tokenFactory, string extraData);
}
