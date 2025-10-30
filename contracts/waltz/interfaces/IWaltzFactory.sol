// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IWaltzFactoryEvents } from "./IWaltzFactoryEvents.sol";
import { IWaltzRegistry } from "./IWaltzRegistry.sol";

/**
 * @title IWaltzFactory
 * @dev Interface for the Waltz Factory contract
 * @notice This interface defines the methods and events for the Waltz Factory
 * @custom:security-contact security@settlemint.com
 */
interface IWaltzFactory is IWaltzFactoryEvents {
    function registry() external view returns (IWaltzRegistry);
}
