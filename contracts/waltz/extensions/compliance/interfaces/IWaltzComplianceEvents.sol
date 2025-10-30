// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title IWaltzComplianceEvents
 * @notice Interface for defining events related to Waltz compliance functionality
 * @dev This interface should be implemented by contracts that handle Waltz compliance events
 * @custom:security-contact security@settlemint.com
 */
interface IWaltzComplianceEvents {
    /**
     * @notice Emitted when a new compliance check is added
     * @dev This event is triggered when a new compliance check is successfully added to the system
     * @param _compliance The address of the added compliance check
     */
    event ComplianceAdded(address indexed _compliance);

    /**
     * @notice Emitted when a compliance check is removed
     * @dev This event is triggered when an existing compliance check is successfully removed from the system
     * @param _compliance The address of the removed compliance check
     */
    event ComplianceRemoved(address indexed _compliance);
}
