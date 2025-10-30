// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";
import { IWaltzPausable } from "./interfaces/IWaltzPausable.sol";
import { ERC165 } from "@openzeppelin/contracts/utils/introspection/ERC165.sol";

/**
 * @title WaltzPausable
 * @notice Abstract contract implementing pausable functionality for Waltz tokens
 * @dev This contract inherits from OpenZeppelin's Pausable contract
 *      It provides the ability to pause and unpause token operations
 *      Inheriting contracts should implement the necessary pause controls
 * @custom:security-contact security@settlemint.com
 */
abstract contract WaltzPausable is Pausable, IWaltzPausable, ERC165 {
    /**
     * @dev Role identifier for accounts that can pause and unpause the contract
     * @notice This role is used to restrict access to pausing and unpausing operations
     */
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    /**
     * @notice Pauses all token operations
     * @dev This function should only be callable by addresses with pausing privileges
     *      Inheriting contracts must implement the necessary access control
     */
    function pause() external virtual override;

    /**
     * @notice Unpauses all token operations
     * @dev This function should only be callable by addresses with unpausing privileges
     *      Inheriting contracts must implement the necessary access control
     */
    function unpause() external virtual override;

    /**
     * @notice Checks if the contract supports a given interface
     * @dev Overrides the supportsInterface function from ERC165
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return bool True if the contract supports the interface, false otherwise
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IWaltzPausable).interfaceId || super.supportsInterface(interfaceId);
    }
}
