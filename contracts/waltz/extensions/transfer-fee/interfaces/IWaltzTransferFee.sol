// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IWaltzTransferFeeEvents } from "./IWaltzTransferFeeEvents.sol";
import { IWaltzErrors } from "../../../interfaces/IWaltzErrors.sol";

/**
 * @title IWaltzTransferFee
 * @notice Interface for transfer fee functionality in Waltz tokens
 * @dev This interface extends IWaltzTransferFeeEvents and IERC20 to provide
 *      a comprehensive interface for tokens with transfer fee capabilities
 * @custom:security-contact security@settlemint.com
 */
interface IWaltzTransferFee is IWaltzTransferFeeEvents, IERC20, IWaltzErrors {
}
