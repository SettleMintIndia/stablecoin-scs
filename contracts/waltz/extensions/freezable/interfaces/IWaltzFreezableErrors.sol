// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title IWaltzFreezableErrors
 * @notice Interface for defining error messages related to Waltz freezable functionality
 * @dev This interface should be implemented by contracts that handle Waltz freezable errors
 * @custom:security-contact security@settlemint.com
 */
interface IWaltzFreezableErrors {
    /**
     * @notice Error thrown when an amount exceeds the thawed balance
     * @dev This error is used when an operation would result in using more tokens than are available in the thawed
     * balance
     * @param account The address of the account attempting the operation
     * @param availableBalance The current thawed balance of the account
     * @param amount The amount that was attempted to be used
     */
    error AmountExceedsThawedBalance(address account, uint256 availableBalance, uint256 amount);

    /**
     * @notice Error thrown when an amount exceeds the frozen balance
     * @dev This error is used when an operation would result in unfreezing more tokens than are currently frozen
     * @param account The address of the account attempting the operation
     * @param availableBalance The current frozen balance of the account
     * @param amount The amount that was attempted to be unfrozen
     */
    error AmountExceedsFrozenBalance(address account, uint256 availableBalance, uint256 amount);

    /**
     * @notice Error thrown when attempting to thaw an address that is not frozen
     * @dev This error is used to prevent unnecessary thaw operations on already thawed addresses
     * @param account The address of the account that is not frozen
     */
    error AddressNotFrozen(address account);

    /**
     * @notice Error thrown when attempting to perform an operation on a frozen address
     * @dev This error is used to prevent operations on frozen addresses, ensuring proper access control
     * @param account The address of the frozen account
     */
    error AddressNotThawed(address account);
}
