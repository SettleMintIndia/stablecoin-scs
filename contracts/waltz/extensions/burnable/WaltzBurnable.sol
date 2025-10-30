// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Waltz } from "../../Waltz.sol";

/**
 * @title WaltzBurnable
 * @notice Abstract contract implementing burnable functionality for Waltz tokens
 * @dev This contract inherits from Waltz, OpenZeppelin's ERC20Burnable, and IWaltzBurnableErrors
 *      It combines the base Waltz token functionality with the ability to burn tokens
 *      and includes custom error handling for burning operations
 * @custom:security-contact security@settlemint.com
 */
abstract contract WaltzBurnable is Waltz {
    /**
     * @dev Role identifier for accounts that can burn tokens
     * @notice This role should be granted to accounts that are allowed to burn tokens
     */
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    /**
     * @notice Burns a specific amount of tokens
     * @dev Destroys `value` tokens from the caller's account
     *      This function should be overridden in the implementing contract
     *      with proper access control mechanisms
     * @param value The amount of tokens to be burned
     */
    function burn(uint256 value) public virtual;

    /**
     * @notice Burns a specific amount of tokens from a given account
     * @dev Destroys `value` tokens from `account`'s balance, deducting from the caller's allowance
     *      This function should be overridden in the implementing contract
     *      with proper access control and allowance checks
     * @param account The account whose tokens will be burned
     * @param value The amount of tokens to be burned
     */
    function burnFrom(address account, uint256 value) public virtual;

    /**
     * @notice Burns tokens from multiple addresses in a single transaction
     * @dev This function allows for efficient batch burning of tokens
     *      It iterates through the provided arrays and calls burnFrom for each pair
     *      Implementing contracts should ensure proper access control is in place
     * @param _userAddresses An array of addresses from which to burn tokens
     * @param _amounts An array of token amounts to burn, corresponding to each address
     * @custom:throws BatchErrorArrayLengthMismatch if the lengths of _userAddresses and _amounts arrays don't match
     */
    function batchBurnFrom(address[] calldata _userAddresses, uint256[] calldata _amounts) external {
        uint256 length = _userAddresses.length;
        if (length != _amounts.length) {
            revert BatchErrorArrayLengthMismatch(length, _amounts.length);
        }
        for (uint256 i; i < length;) {
            burnFrom(_userAddresses[i], _amounts[i]);
            unchecked {
                ++i;
            }
        }
    }
}
