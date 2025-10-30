// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { ERC165 } from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import { IWaltzCappable } from "./interfaces/IWaltzCappable.sol";
import { Waltz } from "../../Waltz.sol";

/**
 * @title WaltzCappable
 * @notice Abstract contract implementing cappable functionality for Waltz tokens
 * @dev This contract inherits from Waltz and implements IWaltzCappable
 *      It provides the ability to set and enforce a cap on the total token supply
 *      Inheriting contracts should implement the necessary cap controls
 * @custom:security-contact security@settlemint.com
 */
abstract contract WaltzCappable is Waltz, IWaltzCappable, ERC165 {
    uint256 private _cap;

    /**
     * @dev Sets the initial value of the `cap`. This value can be changed later using setCap.
     * @param cap_ The initial cap value
     */
    constructor(uint256 cap_) {
        _cap = cap_;
    }

    /**
     * @notice Sets a new cap on the token's total supply
     * @dev Can only be called by authorized roles (to be implemented in child contracts)
     * @param cap_ The new cap value
     */
    function setCap(uint256 cap_) public virtual {
        uint256 supply = this.totalSupply();
        if (supply > 0 && cap_ < supply) {
            revert ExceededCap();
        }
        _cap = cap_;
        emit CapChanged(cap_);
    }

    /**
     * @notice Returns the current cap on the token's total supply
     * @return The current cap value
     */
    function cap() public view virtual returns (uint256) {
        return _cap;
    }

    /**
     * @notice Modifier to ensure the cap is not exceeded
     * @dev Reverts if the cap would not be exceeded
     * @param from The address from which tokens are being transferred or minted
     */
    modifier whenCapNotExeeded(address from, uint256 value) {
        if (_checkCap(from, value)) {
            revert ExceededCap();
        }
        _;
    }

    /**
     * @notice Checks if a mint operation would exceed the cap
     * @dev This function should be called before any mint operation
     * @param from The address from which tokens are being minted (should be address(0) for minting)
     * @return bool True if the cap would be exceeded, false otherwise
     */
    function _checkCap(address from, uint256 value) internal virtual returns (bool) {
        if (from == address(0) && cap() > 0) {
            uint256 maxSupply = cap();
            uint256 supply = this.totalSupply() + value;
            if (supply > maxSupply) {
                return true;
            }
        }
        return false;
    }

    /**
     * @notice Checks if the contract supports a given interface
     * @dev Overrides the supportsInterface function from ERC165
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return bool True if the contract supports the interface, false otherwise
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IWaltzCappable).interfaceId || super.supportsInterface(interfaceId);
    }
}
