// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { WaltzRegistry } from "./waltz/WaltzRegistry.sol";
import { WaltzAccessControl } from "./waltz/extensions/access-control/WaltzAccessControl.sol";

contract Registry is WaltzRegistry, WaltzAccessControl {
    constructor() WaltzAccessControl(3 days, msg.sender) { }
}
