// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title IWaltzErrors
 * @notice Interface for defining error messages related to Waltz functionality
 * @dev This interface should be implemented by contracts that handle Waltz errors
 * @custom:security-contact security@settlemint.com
 */
interface IWaltzErrors {
    /**
     * @notice Error thrown when a zero address is provided where it's not allowed
     * @dev This error is used to prevent operations with invalid zero addresses
     */
    error ZeroAddressNotAllowed();

    /**
     * @notice Error thrown when there's a mismatch in array lengths
     * @dev This error is used when two arrays that should have the same length don't match
     * @param firstArray The length of the first array
     * @param secondArray The length of the second array
     */
    error BatchErrorArrayLengthMismatch(uint256 firstArray, uint256 secondArray);

    /**
     * @notice Error thrown when a transfer operation fails
     * @dev This error is used to indicate a failed transfer attempt
     * @param to The address intended to receive tokens
     * @param amount The amount of tokens attempted to be transferred
     */
    error TransferFailed(address to, uint256 amount);

    /**
     * @notice Error thrown when a transfer operation fails
     * @dev This error is used to indicate a failed transfer attempt
     * @param from The address attempting to send tokens
     * @param to The address intended to receive tokens
     * @param amount The amount of tokens attempted to be transferred
     */
    error TransferFromFailed(address from, address to, uint256 amount);

    /**
     * @notice Error thrown when a percentage value more than 100 is used
     * @dev This error is used to indicate the invalid percentage used
     * @param percentage The percentage value you want to set for the fee
     */
    error FeePercentageMoreThan100(uint256 percentage);
}
