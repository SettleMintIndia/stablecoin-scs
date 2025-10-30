// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IWaltzFreezableErrors } from "./IWaltzFreezableErrors.sol";
import { IWaltzFreezableEvents } from "./IWaltzFreezableEvents.sol";
import { IWaltzErrors } from "../../../interfaces/IWaltzErrors.sol";

/**
 * @title IWaltzFreezable
 * @notice Interface for freezable functionality in Waltz tokens
 * @dev This interface defines the events and functions for freezing and thawing addresses and tokens
 * @custom:security-contact security@settlemint.com
 */
interface IWaltzFreezable is IWaltzFreezableErrors, IWaltzFreezableEvents, IWaltzErrors {
    /**
     * @notice Freezes the specified address, preventing it from performing token operations
     * @dev Sets an address's frozen status for this token
     * @dev This function can only be called by a wallet with the FREEZER_ROLE
     * @param _userAddress The address for which to update frozen status
     */
    function freezeAddress(address _userAddress) external;

    /**
     * @notice Thaws (unfreezes) the specified address, allowing it to perform token operations
     * @dev Unfreezes an address, allowing normal token operations
     * @dev This function can only be called by a wallet with the FREEZER_ROLE
     * @param _userAddress The address to unfreeze
     */
    function thawAddress(address _userAddress) external;

    /**
     * @notice Freezes the specified amount of tokens for the given address
     * @dev Freezes a specified amount of tokens for a given address
     * @dev This function can only be called by a wallet with the FREEZER_ROLE
     * @param _userAddress The address for which to freeze tokens
     * @param _amount Amount of tokens to be frozen
     */
    function freezeTokens(address _userAddress, uint256 _amount) external;

    /**
     * @notice Thaws (unfreezes) the specified amount of tokens for the given address
     * @dev Unfreezes a specified amount of tokens for a given address
     * @dev This function can only be called by a wallet with the FREEZER_ROLE
     * @param _userAddress The address for which to unfreeze tokens
     * @param _amount Amount of tokens to be unfrozen
     */
    function thawTokens(address _userAddress, uint256 _amount) external;

    /**
     * @notice Checks if the specified address is frozen
     * @dev Returns the freezing status of a wallet
     * @dev If returns `true`, the wallet is frozen. If `false`, the wallet is not frozen.
     * @dev Note that `true` doesn't necessarily mean the entire balance is frozen; tokens could be partially frozen.
     * @param _userAddress The address of the wallet to check
     * @return bool The frozen status of the address
     */
    function isFrozen(address _userAddress) external view returns (bool);

    /**
     * @notice Retrieves the amount of frozen tokens for the specified address
     * @dev Returns the amount of tokens that are partially frozen for a wallet
     * @dev The amount of frozen tokens is always less than or equal to the total balance of the wallet
     * @param _userAddress The address of the wallet to check
     * @return uint256 The amount of frozen tokens for the address
     */
    function frozenTokens(address _userAddress) external view returns (uint256);
}
