// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { AccessControlDefaultAdminRules } from
    "@openzeppelin/contracts/access/extensions/AccessControlDefaultAdminRules.sol";
import { IAccessControlDefaultAdminRules } from
    "@openzeppelin/contracts/access/extensions/IAccessControlDefaultAdminRules.sol";

/**
 * @title WaltzAccessControl
 * @notice Abstract contract implementing access control functionality for Waltz tokens
 * @dev This contract inherits from OpenZeppelin's AccessControlDefaultAdminRules contract
 */
abstract contract WaltzAccessControl is AccessControlDefaultAdminRules {
    /**
     * @notice Constructs the WaltzAccessControl contract
     * @dev Sets up the default admin role with a 3-day delay and assigns it to the contract deployer
     */
    constructor(
        uint48 initialDelay,
        address initialDefaultAdmin
    )
        AccessControlDefaultAdminRules(initialDelay, initialDefaultAdmin)
    { }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlDefaultAdminRules).interfaceId || super.supportsInterface(interfaceId);
    }
}
