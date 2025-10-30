// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IWaltzRescuableEvents } from "./IWaltzRescuableEvents.sol";

/**
 * @title IWaltzRescuable
 * @notice Interface for rescuable functionality in Waltz tokens
 * @dev This interface defines the functions for rescuing tokens and setting the rescue vault
 * @custom:security-contact security@settlemint.com
 */
interface IWaltzRescuable is IWaltzRescuableEvents {
    /**
     * @notice Rescues tokens accidentally sent to this contract
     * @dev This function should only be callable by addresses with rescue privileges
     * @param token The address of the token to be rescued
     */
    function rescue(address token) external;

    /**
     * @notice Sets the address of the rescue vault
     * @dev This function should only be callable by addresses with appropriate privileges
     * @param _rescueRecipient The address of the new rescue vault
     */
    function setRescueVault(address _rescueRecipient) external;
}
