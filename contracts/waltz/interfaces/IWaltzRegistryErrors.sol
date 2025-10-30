// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title IWaltzCappableEvents
 * @notice Interface for defining events related to Waltz cappable functionality
 * @dev This interface should be implemented by contracts that handle Waltz cappable events
 * @custom:security-contact security@settlemint.com
 */
interface IWaltzRegistryErrors {
    /**
     * @dev Error thrown when a token is not found in the registry
     * @param tokenAddress The address of the token that was not found
     */
    error TokenNotFound(address tokenAddress);

    /**
     * @dev Error thrown when an index does not exist in the registry
     * @param index The index that does not exist
     */
    error TokenIndexOutOfBounds(uint256 index);

    /**
     * @dev Error thrown when a token is already found in the registry
     * @param tokenAddress The address of the token that was found
     */
    error TokenAddressAlreadyExists(address tokenAddress);

    /**
     * @dev Error thrown when a symbol is already found in the registry
     * @param symbol The symbol of the token that was found
     */
    error TokenSymbolAlreadyExists(string symbol);
}
