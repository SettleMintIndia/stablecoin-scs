// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title IWaltzFactoryEvents
 * @dev Interface for Waltz Factory events
 * @notice This interface defines the events emitted by the Waltz Factory contract
 * @custom:security-contact security@settlemint.com
 */
interface IWaltzFactoryEvents {
    /**
     * @dev Emitted when a new token is created
     * @param tokenAddress The address of the newly created token contract
     * @param symbol The symbol of the newly created token
     */
    event TokenCreated(address tokenAddress, string symbol);
}
