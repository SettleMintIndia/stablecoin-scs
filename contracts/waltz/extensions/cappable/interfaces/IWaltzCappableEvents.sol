// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title IWaltzCappableEvents
 * @notice Interface for defining events related to Waltz cappable functionality
 * @dev This interface should be implemented by contracts that handle Waltz cappable events
 * @custom:security-contact security@settlemint.com
 */
interface IWaltzCappableEvents {
    /**
     * @dev Emitted when the cap value is changed
     * @param cap The new cap value
     */
    event CapChanged(uint256 cap);
}
