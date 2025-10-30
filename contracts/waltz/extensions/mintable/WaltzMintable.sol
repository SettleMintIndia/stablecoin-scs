// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Waltz } from "../../Waltz.sol";
import { IWaltzMintable } from "./interfaces/IWaltzMintable.sol";
import { ERC165 } from "@openzeppelin/contracts/utils/introspection/ERC165.sol";

/**
 * @title WaltzMintable
 * @notice Abstract contract implementing mintable functionality for Waltz tokens
 * @dev This contract inherits from Waltz and IWaltzMintableErrors
 *      It combines the base Waltz token functionality with the ability to mint tokens
 *      and includes custom error handling for minting operations
 * @custom:security-contact security@settlemint.com
 */
abstract contract WaltzMintable is Waltz, IWaltzMintable, ERC165 {
    /**
     * @dev Role identifier for accounts that can mint tokens
     * @notice This constant is used to define the minter role in the contract
     */
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /**
     * @notice Mints new tokens and assigns them to the specified address
     * @dev This function can be overridden to add additional checks or logic
     * @param to The address that will receive the minted tokens
     * @param amount The amount of tokens to mint
     */
    function mint(address to, uint256 amount) public virtual;

    /**
     * @notice Mints tokens to multiple addresses in a single transaction
     * @dev This function allows for efficient batch minting of tokens
     * @param _userAddresses An array of addresses to which tokens will be minted
     * @param _amounts An array of token amounts to mint, corresponding to each address
     */
    function batchMint(address[] calldata _userAddresses, uint256[] calldata _amounts) external {
        uint256 length = _userAddresses.length;
        if (length != _amounts.length) {
            revert BatchErrorArrayLengthMismatch(length, _amounts.length);
        }
        for (uint256 i; i < length;) {
            mint(_userAddresses[i], _amounts[i]);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Checks if the contract supports a given interface
     * @dev Overrides the supportsInterface function from ERC165
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return bool True if the contract supports the interface, false otherwise
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IWaltzMintable).interfaceId || super.supportsInterface(interfaceId);
    }
}
