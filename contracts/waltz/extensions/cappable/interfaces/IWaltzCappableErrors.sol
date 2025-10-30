// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title IWaltzCappableErrors
 * @notice Interface for defining error messages related to Waltz cappable functionality
 * @dev This interface should be implemented by contracts that handle Waltz cappable errors
 * @custom:security-contact security@settlemint.com
 */
interface IWaltzCappableErrors {
    /**
     * @notice Error thrown when the total supply cap has been exceeded
     * @dev This error is triggered when an operation would cause the total supply to exceed the cap
     */
    error ExceededCap();

    /**
     * @notice Error thrown when an invalid cap value is provided
     * @dev This error is triggered when attempting to set an invalid cap value
     * @param cap The invalid cap value that was provided
     */
    error InvalidCap(uint256 cap);
}
