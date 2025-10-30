// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IWaltzMetadata } from "./IWaltzMetadata.sol";
import { IWaltzErrors } from "./IWaltzErrors.sol";

/**
 * @title IWaltz
 * @notice Interface for the Waltz token, combining ERC20 functionality with Waltz-specific metadata and error handling
 * @dev This interface extends IERC20, IWaltzMetadata, and IWaltzErrors to provide a comprehensive
 *      interface for the Waltz token system. It encapsulates standard ERC20 functionality,
 *      Waltz-specific metadata operations, and custom error definitions.
 * @custom:security-contact security@settlemint.com
 */
interface IWaltz is IERC20, IWaltzMetadata, IWaltzErrors { }
