// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IWaltzErrors } from "../../../interfaces/IWaltzErrors.sol";
import { IWaltzComplianceEvents } from "./IWaltzComplianceEvents.sol";
import { IWaltzComplianceCheck } from "../checks/interfaces/IWaltzComplianceCheck.sol";

/**
 * @title IWaltzCompliance
 * @notice Interface for Waltz compliance functionality
 * @dev This interface extends IWaltzComplianceErrors and defines compliance-related events and functions
 * @custom:security-contact security@settlemint.com
 */
interface IWaltzCompliance is IWaltzErrors, IWaltzComplianceEvents {
    /**
     * @notice Adds a new compliance check
     * @dev This function allows the addition of a new compliance check to the system
     * @param _complianceCheck The address of the compliance check to add
     */
    function addComplianceCheck(IWaltzComplianceCheck _complianceCheck) external;

    /**
     * @notice Removes an existing compliance check
     * @dev This function allows the removal of an existing compliance check from the system
     * @param _complianceCheck The address of the compliance check to remove
     */
    function removeComplianceCheck(IWaltzComplianceCheck _complianceCheck) external;

    /**
     * @notice Checks compliance for a transfer
     * @dev This function verifies if a transfer complies with all registered compliance checks
     * @param _from The address sending tokens
     * @param _to The address receiving tokens
     * @param _value The amount of tokens being transferred
     * @custom:security-contact security@settlemint.com
     */
    function checkCompliance(address _from, address _to, uint256 _value) external view;

    /**
     * @notice Adds addresses to the exempt list
     * @dev This function allows the addition of addresses that are exempt from compliance checks
     * @param specialAddresses An array of addresses to be added to the exempt list
     */
    function addExemptAddress(address[] calldata specialAddresses) external;

    /**
     * @notice Removes addresses from the exempt list
     * @dev This function allows the removal of addresses from the exempt list
     * @param specialAddresses An array of addresses to be removed from the exempt list
     */
    function removeExemptAddress(address[] calldata specialAddresses) external;

}
