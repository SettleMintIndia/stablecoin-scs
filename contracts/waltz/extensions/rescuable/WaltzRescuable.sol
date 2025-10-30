// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Waltz } from "../../Waltz.sol";
import { IWaltzRescuable } from "./interfaces/IWaltzRescuable.sol";
import { ERC165 } from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "forge-std/console.sol";

/**
 * @title WaltzRescuable
 * @notice Abstract contract implementing rescuable functionality for Waltz tokens
 * @dev This contract inherits from Waltz, IWaltzRescuable, and ERC165
 *      It provides the ability to rescue tokens accidentally sent to the contract
 *      Inheriting contracts should implement the necessary access controls
 * @custom:security-contact security@settlemint.com
 */
abstract contract WaltzRescuable is Waltz, IWaltzRescuable, ERC165 {
    address public rescueRecipient;

    /**
     * @dev Role identifier for accounts that can rescue the tokens stuck on contract
     * @notice This role should be granted to accounts that are allowed to rescue the tokens stuck on contract
     */
    bytes32 public constant RESCUER_ROLE = keccak256("RESCUER_ROLE");

    /**
     * @notice Constructor that sets the initial rescue recipient
     * @param _rescueRecipient The address that will receive rescued tokens
     */
    constructor(address _rescueRecipient) {
        rescueRecipient = _rescueRecipient;
    }

    /**
     * @notice Sets the address of the rescue vault
     * @dev This function should be overridden to implement access control
     * @param _rescueRecipient The address of the new rescue vault
     */
    function setRescueVault(address _rescueRecipient) public virtual {
        if (_rescueRecipient == address(0)) {
            revert ZeroAddressNotAllowed();
        }
        rescueRecipient = _rescueRecipient;
        emit RescueRecipientChanged(_rescueRecipient);
    }

    /**
     * @notice Rescues tokens accidentally sent to this contract
     * @dev This function transfers ERC20 tokens or the contract's own tokens to the rescue recipient
     * @param token The address of the token to be rescued (use address(0) for this contract's tokens)
     */
    function rescue(address token) public virtual {
        uint256 balance;
        if (token != address(0)) {
            balance = IERC20(token).balanceOf(address(this));
            if (balance > 0) {
                IERC20(token).transfer(rescueRecipient, balance);
            }
        } else {
            balance = address(this).balance;
            console.log("%s:",balance);
            if (balance > 0) {
                payable(rescueRecipient).transfer(balance);
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
        return interfaceId == type(IWaltzRescuable).interfaceId || super.supportsInterface(interfaceId);
    }
}
