// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/**
 * @title IWaltzMetadata
 * @notice Interface for metadata functionality in Waltz tokens
 * @dev This interface extends IERC20Metadata to provide additional metadata
 *      functionality specific to Waltz tokens
 * @custom:security-contact security@settlemint.com
 */
interface IWaltzMetadata is IERC20Metadata {
    /**
     * @notice Returns the version of the Waltz token
     * @dev This function should be implemented to provide version information
     *      for the Waltz token
     * @return A string representing the version of the token
     */
    function version() external pure returns (string memory);
}
