// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title IWaltzComplianceCheck
 * @notice Interface for implementing compliance checks in Waltz tokens
 * @dev This interface should be implemented by contracts that perform compliance checks
 * @custom:security-contact security@settlemint.com
 */
interface IWaltzComplianceCheck {
    /**
     * @notice Performs a compliance check for a token transfer
     * @dev This function should be implemented to define specific compliance rules
     *      It is called during token transfers to ensure compliance with predefined rules
     *      Implementing contracts should return true if the transfer is compliant, false otherwise
     * @param callingContract The address of the contract calling the check function
     * @param addressToCheck The address to check
     * @param _value The amount of tokens being transferred
     */
    function check(address callingContract, address addressToCheck, uint256 _value) external view;

    /**
     * @notice Sets the RequestId for a given contract address
     * @param _contractAddress The address of the contract
     * @param _sigRequestId The signature request ID
     * @param _mtpRequestId The MTP request ID
     */
    function setRequestId(address _contractAddress, uint64 _sigRequestId, uint64 _mtpRequestId) external;
}
