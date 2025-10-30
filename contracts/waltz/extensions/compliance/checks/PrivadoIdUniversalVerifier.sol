// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IUniversalVerifier } from "./interfaces/privado-id/IUniversalVerifier.sol";
import { IWaltzComplianceCheck } from "./interfaces/IWaltzComplianceCheck.sol";

/**
 * @title PrivadoIdUniversalVerifier
 * @notice A compliance check contract that verifies addresses using the UniversalVerifier
 * @dev Implements the IWaltzComplianceCheck interface
 * @custom:security-contact security@settlemint.com
 */
contract PrivadoIdUniversalVerifier is IWaltzComplianceCheck {
    IUniversalVerifier immutable universalVerifier;

    /**
     * @dev Struct to hold signature and MTP request IDs
     */
    struct RequestId {
        uint64 sigRequestId;
        uint64 mtpRequestId;
    }

    /**
     * @dev Mapping of calling contract addresses to their respective RequestIds
     */
    // https://github.com/crytic/slither/issues/456
    // slither-disable-next-line uninitialized-state
    mapping(address => RequestId) public _requestIds;
    /**
     * @dev Error thrown when an address fails verification
     */

    error AddressNotVerified(address);

    /**
     * @notice Constructs the PrivadoIdUniversalVerifier contract
     * @param _universalVerifier The address of the UniversalVerifier contract
     */
    constructor(IUniversalVerifier _universalVerifier) {
        universalVerifier = _universalVerifier;
    }

    /**
     * @notice Sets the RequestId for a given contract address
     * @param _contractAddress The address of the contract
     * @param _sigRequestId The signature request ID
     * @param _mtpRequestId The MTP request ID
     */
    function setRequestId(address _contractAddress, uint64 _sigRequestId, uint64 _mtpRequestId) public {
        _requestIds[_contractAddress] = RequestId(_sigRequestId, _mtpRequestId);
    }

    /**
     * @notice Performs the compliance check
     * @dev Verifies both the sender and receiver addresses
     * @param _callingContract The address of the contract calling this function
     * @param addressToCheck The address to check
     */
    function check(address _callingContract, address addressToCheck, uint256) external view {
        RequestId memory requestId = _requestIds[_callingContract];

        if (!_isVerified(addressToCheck, requestId)) {
            revert AddressNotVerified(addressToCheck);
        }
    }

    /**
     * @dev Internal function to check if an address is verified
     * @param _address The address to verify
     * @param _requestId The RequestId struct containing signature and MTP request IDs
     * @return bool True if the address is verified, false otherwise
     */
    function _isVerified(address _address, RequestId memory _requestId) private view returns (bool) {
        return universalVerifier.getProofStatus(_address, _requestId.sigRequestId).isVerified
            && universalVerifier.getProofStatus(_address, _requestId.mtpRequestId).isVerified;
    }
}
