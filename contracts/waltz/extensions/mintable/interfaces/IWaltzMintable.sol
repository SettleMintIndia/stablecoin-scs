// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IWaltzErrors } from "../../../interfaces/IWaltzErrors.sol";

/**
 * @title IWaltzMintable
 * @notice Interface for mintable functionality in Waltz tokens
 * @dev This interface defines the function for minting new tokens
 * @custom:security-contact security@settlemint.com
 */
interface IWaltzMintable is IWaltzErrors {
    /**
     * @notice Mints new tokens and assigns them to the specified address
     * @dev This function should only be callable by addresses with minting privileges
     * @param to The address that will receive the minted tokens
     * @param amount The amount of tokens to mint
     */
    function mint(address to, uint256 amount) external;
}
