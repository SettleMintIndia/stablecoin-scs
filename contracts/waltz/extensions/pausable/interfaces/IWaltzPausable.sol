// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title IWaltzPausable
 * @notice Interface for pausable functionality in Waltz tokens
 * @dev This interface defines the functions for pausing and unpausing token operations
 * @custom:security-contact security@settlemint.com
 */
interface IWaltzPausable {
    /**
     * @notice Pauses all token operations
     * @dev This function should only be callable by addresses with pausing privileges
     */
    function pause() external;

    /**
     * @notice Unpauses all token operations
     * @dev This function should only be callable by addresses with unpausing privileges
     */
    function unpause() external;
}
