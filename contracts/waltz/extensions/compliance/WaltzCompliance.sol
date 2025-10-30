// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IWaltzCompliance } from "./interfaces/IWaltzCompliance.sol";
import { IWaltzComplianceCheck } from "./checks/interfaces/IWaltzComplianceCheck.sol";
import { ERC165 } from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";


/**
 * @title WaltzCompliance
 * @notice This contract implements compliance functionality for Waltz tokens
 * @dev This contract inherits from IWaltzCompliance interface and ERC165
 * @custom:security-contact security@settlemint.com
 */
abstract contract WaltzCompliance is IWaltzCompliance, ERC165 {
    /**
     * @dev Role identifier for accounts that can manage compliance checks
     * @notice This role is used to restrict access to compliance management operations
     */
    bytes32 public constant COMPLIANCE_ROLE = keccak256("COMPLIANCE_ROLE");

    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private exemptAddressList;

    /**
     * @dev Array of compliance check contracts
     */
    IWaltzComplianceCheck[] private _complianceChecks;

    /**
     * @notice Modifier to check the compliance rules
     * @dev Reverts at any point of failure on compliance checks
     * @param _from The address sending tokens
     * @param _to The address receiving tokens
     * @param _value The amount of tokens being transferred
     */
    modifier whenComplianceChecked(address _from, address _to, uint256 _value) {
        checkCompliance(_from, _to, _value);
        _;
    }

    /**
     * @notice Adds a new compliance check
     * @dev Reverts if the provided address is zero
     * @param _complianceCheck The address of the compliance check to add
     */
    function addComplianceCheck(IWaltzComplianceCheck _complianceCheck) public virtual {
        _complianceChecks.push(_complianceCheck);
        emit ComplianceAdded(address(_complianceCheck));
    }

    /**
     * @notice Removes an existing compliance check
     * @dev Removes the first occurrence of the compliance check if found
     * @param _complianceCheck The address of the compliance check to remove
     */
    function removeComplianceCheck(IWaltzComplianceCheck _complianceCheck) public virtual {
        uint256 length = _complianceChecks.length;
        for (uint256 i = 0; i < length;) {
            if (_complianceChecks[i] == _complianceCheck) {
                _complianceChecks[i] = _complianceChecks[length - 1];
                _complianceChecks.pop();
                emit ComplianceRemoved(address(_complianceCheck));
                break;
            }
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Adds addresses to the exempt list
     * @dev This function allows the addition of addresses that are exempt from compliance checks
     * @param specialAddresses_ An array of addresses to be added to the exempt list
     * @custom:security-contact security@settlemint.com
     */
    function addExemptAddress(address[] calldata specialAddresses_) public virtual {
        for (uint256 i = 0; i < specialAddresses_.length;) {
            EnumerableSet.add(exemptAddressList, specialAddresses_[i]);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Removes addresses from the exempt list
     * @dev This function allows the removal of addresses from the exempt list
     * @param specialAddresses_ An array of addresses to be removed from the exempt list
     * @custom:security-contact security@settlemint.com
     */
    function removeExemptAddress(address[] calldata specialAddresses_) public virtual {
        for (uint256 i = 0; i < specialAddresses_.length;) {
            EnumerableSet.remove(exemptAddressList, specialAddresses_[i]);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Checks compliance for a transfer
     * @dev Iterates through all compliance checks and calls their check function
     * @param _from The address sending tokens
     * @param _to The address receiving tokens
     * @param _value The amount of tokens being transferred
     */
    function checkCompliance(address _from, address _to, uint256 _value) public view {
        uint256 length = _complianceChecks.length;
        for (uint256 i = 0; i < length;) {
            if (!EnumerableSet.contains(exemptAddressList, _from)) {
                _complianceChecks[i].check(address(this), _from, _value);
            }
            if (!EnumerableSet.contains(exemptAddressList, _to)) {
                _complianceChecks[i].check(address(this), _to, _value);
            }
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Checks if the contract supports a given interface
     * @dev Overrides the supportsInterface function from ERC165
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return bool True if the contract supports the interface, false otherwise
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IWaltzCompliance).interfaceId || super.supportsInterface(interfaceId);
    }
}
