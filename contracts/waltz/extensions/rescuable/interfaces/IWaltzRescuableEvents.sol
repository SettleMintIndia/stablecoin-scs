// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title IWaltzRescuableEvents
 * @notice Interface for defining events related to Waltz rescuable functionality
 * @dev This interface should be implemented by contracts that handle Waltz rescuable events
 * @custom:security-contact security@settlemint.com
 */
interface IWaltzRescuableEvents {
    /**
     * @notice Emitted when the rescue recipient address is changed
     * @param _rescueRecipient The new address of the rescue recipient
     */
    event RescueRecipientChanged(address indexed _rescueRecipient);
}
