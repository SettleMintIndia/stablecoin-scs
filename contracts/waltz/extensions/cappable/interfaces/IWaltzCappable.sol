// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IWaltzCappableErrors } from "./IWaltzCappableErrors.sol";
import { IWaltzCappableEvents } from "./IWaltzCappableEvents.sol";

/**
 * @title IWaltzCappable
 * @notice Interface for capping functionality in Waltz tokens
 * @dev This interface defines the events, errors, and functions for setting and querying the token supply cap
 * @custom:security-contact security@settlemint.com
 */
interface IWaltzCappable is IWaltzCappableErrors, IWaltzCappableEvents {
    /**
     * @notice Sets a new cap for the token's total supply
     * @dev This function allows changing the maximum total supply of the token
     * @param cap_ The new cap value to set
     */
    function setCap(uint256 cap_) external;

    /**
     * @notice Returns the current cap on the token's total supply
     * @dev This function provides the maximum allowed total supply of the token
     * @return The current cap value
     */
    function cap() external view returns (uint256);
}
