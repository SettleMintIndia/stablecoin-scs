// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IWaltzRegistryEvents } from "./IWaltzRegistryEvents.sol";
import { IWaltzRegistryErrors } from "./IWaltzRegistryErrors.sol";

/**
 * @title ITokenRegistry
 * @dev Interface for a token registry contract
 */
interface IWaltzRegistry is IWaltzRegistryEvents, IWaltzRegistryErrors {
    /**
     * @dev Structure to hold token information
     * @param tokenAddress The address of the token contract
     * @param symbol The symbol of the token
     * @param tokenFactory The address of the token factory contract
     */
    struct Token {
        address tokenAddress;
        string symbol;
        address tokenFactory;
        string extraData;
    }

    /**
     * @dev Adds a token to the registry
     * @param tokenAddress The token address
     * @param symbol The token symbol
     * @param tokenFactory The address of the token factory contract
     */
    function addToken(
        address tokenAddress,
        string memory symbol,
        address tokenFactory,
        string memory extraData
    )
        external;

    /**
     * @dev Retrieves a token by its address
     * @param tokenAddress The address of the token to retrieve
     * @return token The token information
     */
    function getTokenByAddress(address tokenAddress) external view returns (Token memory token);

    /**
     * @dev Retrieves a token by its symbol
     * @param symbol The symbol of the token to retrieve
     * @return token The token information
     */
    function getTokenBySymbol(string memory symbol) external view returns (Token memory token);

    /**
     * @dev Retrieves a token by its index in the registry
     * @param index The index of the token in the registry
     * @return token The token information
     */
    function getTokenByIndex(uint256 index) external view returns (Token memory token);

    /**
     * @dev Retrieves the list of all tokens in the registry
     * @return tokens An array of all token information in the registry
     */
    function getTokenList() external view returns (Token[] memory tokens);
}
