// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.26;

import { ICircuitValidator } from "./ICircuitValidator.sol";
import { IZKPVerifier } from "./IZKPVerifier.sol";

/// @title IUniversalVerifier Interface
/// @notice Interface for the UniversalVerifier contract
interface IUniversalVerifier {
    event ZKPResponseSubmitted(uint64 indexed requestId, address indexed caller);
    event ZKPRequestSet(
        uint64 indexed requestId, address indexed requestOwner, string metadata, address validator, bytes data
    );

    function initialize() external;

    function version() external pure returns (string memory);

    function setZKPRequest(uint64 requestId, IZKPVerifier.ZKPRequest calldata request) external;

    function submitZKPResponse(
        uint64 requestId,
        uint256[] calldata inputs,
        uint256[2] calldata a,
        uint256[2][2] calldata b,
        uint256[2] calldata c
    )
        external;

    function verifyZKPResponse(
        uint64 requestId,
        uint256[] calldata inputs,
        uint256[2] calldata a,
        uint256[2][2] calldata b,
        uint256[2] calldata c,
        address sender
    )
        external
        view
        returns (ICircuitValidator.KeyToInputIndex[] memory);

    function setRequestOwner(uint64 requestId, address requestOwner) external;

    function disableZKPRequest(uint64 requestId) external;

    function enableZKPRequest(uint64 requestId) external;

    function addValidatorToWhitelist(ICircuitValidator validator) external;

    function removeValidatorFromWhitelist(ICircuitValidator validator) external;

    function getProofStatus(
        address sender,
        uint64 requestId
    )
        external
        view
        returns (IZKPVerifier.ProofStatus memory);
}
