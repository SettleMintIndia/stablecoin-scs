// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IWaltzFreezable } from "./interfaces/IWaltzFreezable.sol";
import { Waltz } from "../../Waltz.sol";
import { ERC165 } from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
/**
 * @title WaltzFreezable
 * @notice Abstract contract implementing freezable functionality for Waltz tokens
 * @dev This contract inherits from IWaltzFreezable interface and Waltz contract
 * @custom:security-contact security@settlemint.com
 */

abstract contract WaltzFreezable is Waltz, IWaltzFreezable, ERC165 {
    /**
     * @dev Role identifier for accounts that can freeze and thaw addresses and tokens
     * @notice This role is used to restrict access to freezing and thawing operations
     */
    bytes32 public constant FREEZER_ROLE = keccak256("FREEZER_ROLE");

    /**
     * @notice Mapping of addresses to their frozen status
     * @dev True if the address is frozen, false otherwise
     */
    mapping(address => bool) private frozenAddress;

    /**
     * @notice Mapping of addresses to the amount of frozen tokens
     * @dev The amount of tokens that are frozen for each address
     */
    mapping(address => uint256) private _frozenTokens;

    /**
     * @notice Modifier to ensure the address is not frozen
     * @dev Reverts if the address is frozen
     * @param _userAddress The address to check
     */
    modifier whenThawed(address _userAddress) {
        if (frozenAddress[_userAddress]) {
            revert AddressNotThawed(_userAddress);
        }
        _;
    }

    /**
     * @notice Modifier to ensure the thawed balance is not exceeded
     * @dev Reverts if the amount exceeds the thawed balance
     * @param _userAddress The address to check
     * @param _amount The amount to check against the thawed balance
     */
    modifier notExceedingThawedBalance(address _userAddress, uint256 _amount) {
        if (_userAddress != address(0)) {
            uint256 thawedBalance = this.balanceOf(_userAddress) - _frozenTokens[_userAddress];
            if (thawedBalance < _amount) {
                revert AmountExceedsThawedBalance(_userAddress, thawedBalance, _amount);
            }
        }
        _;
    }

    /**
     * @notice Internal function to freeze or thaw an address
     * @dev Updates the frozen status of an address and emits the appropriate event
     * @param _userAddress The address to freeze or thaw
     * @param _freeze True to freeze the address, false to thaw
     */
    function _freezeAddress(address _userAddress, bool _freeze) private {
        if (_userAddress == address(0)) {
            revert ZeroAddressNotAllowed();
        }
        frozenAddress[_userAddress] = _freeze;
        if (_freeze) {
            emit AddressFrozen(_userAddress, msg.sender);
        } else {
            emit AddressThawed(_userAddress, msg.sender);
        }
    }

    /**
     * @notice Sets an address's frozen status for this token
     * @dev This function can only be called by a wallet with the FREEZER_ROLE
     * @param _userAddress The address for which to update frozen status
     */
    function freezeAddress(address _userAddress) public virtual {
        _freezeAddress(_userAddress, true);
    }

    /**
     * @notice Unfreezes an address, allowing normal token operations
     * @dev This function can only be called by a wallet with the FREEZER_ROLE
     * @param _userAddress The address to unfreeze
     */
    function thawAddress(address _userAddress) public virtual {
        _freezeAddress(_userAddress, false);
    }

    /**
     * @notice Internal function to freeze or thaw a specific amount of tokens for an address
     * @dev Updates the amount of frozen tokens for an address and emits the appropriate event
     * @param _userAddress The address for which to freeze or thaw tokens
     * @param _freeze True to freeze tokens, false to thaw
     * @param _amount The amount of tokens to freeze or thaw
     */
    function _freezeTokens(address _userAddress, bool _freeze, uint256 _amount) internal {
        if (_userAddress == address(0)) {
            revert ZeroAddressNotAllowed();
        }
        uint256 frozenBalance = _frozenTokens[_userAddress];
        if (_freeze) {
            _frozenTokens[_userAddress] = frozenBalance + _amount;
            emit TokensFrozen(_userAddress, _amount, msg.sender);
        } else {
            if (_amount > frozenBalance) {
                revert AmountExceedsFrozenBalance(_userAddress, frozenBalance, _amount);
            }
            _frozenTokens[_userAddress] = frozenBalance - _amount;
            emit TokensThawed(_userAddress, _amount, msg.sender);
        }
    }

    /**
     * @notice Freezes a specified amount of tokens for a given address
     * @dev This function can only be called by a wallet with the FREEZER_ROLE
     * @param _userAddress The address for which to freeze tokens
     * @param _amount Amount of tokens to be frozen
     */
    function freezeTokens(address _userAddress, uint256 _amount) public virtual {
        _freezeTokens(_userAddress, true, _amount);
    }

    /**
     * @notice Unfreezes a specified amount of tokens for a given address
     * @dev This function can only be called by a wallet with the FREEZER_ROLE
     * @param _userAddress The address for which to unfreeze tokens
     * @param _amount Amount of tokens to be unfrozen
     */
    function thawTokens(address _userAddress, uint256 _amount) public virtual {
        _freezeTokens(_userAddress, false, _amount);
    }

    /**
     * @notice Returns the freezing status of a wallet
     * @dev If returns `true`, the wallet is frozen. If `false`, the wallet is not frozen.
     *      Note that `true` doesn't necessarily mean the entire balance is frozen; tokens could be partially frozen.
     * @param _userAddress The address of the wallet to check
     * @return bool The frozen status of the address
     */
    function isFrozen(address _userAddress) external view virtual returns (bool) {
        return frozenAddress[_userAddress];
    }

    /**
     * @notice Returns the amount of tokens that are partially frozen for a wallet
     * @dev The amount of frozen tokens is always less than or equal to the total balance of the wallet
     * @param _userAddress The address of the wallet to check
     * @return uint256 The amount of frozen tokens for the address
     */
    function frozenTokens(address _userAddress) external view virtual returns (uint256) {
        return _frozenTokens[_userAddress];
    }

    /**
     * @notice Freeze multiple addresses in a single transaction
     * @dev This function iterates through the provided addresses and freezes each one
     * @param _userAddresses An array of addresses to freeze
     */
    function batchFreezeAddress(address[] calldata _userAddresses) external {
        uint256 length = _userAddresses.length;
        for (uint256 i; i < length;) {
            freezeAddress(_userAddresses[i]);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Thaws multiple addresses in a single transaction
     * @dev Only callable by authorized addresses
     * @param _userAddresses An array of addresses to thaw
     */
    function batchThawAddress(address[] calldata _userAddresses) external {
        uint256 length = _userAddresses.length;
        for (uint256 i; i < length;) {
            thawAddress(_userAddresses[i]);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Freeze tokens for multiple addresses in a single transaction
     * @dev This function checks that the input arrays have matching lengths before processing
     * @param _userAddresses An array of addresses for which to freeze tokens
     * @param _amounts An array of token amounts to freeze, corresponding to each address
     */
    function batchFreezeTokens(address[] calldata _userAddresses, uint256[] calldata _amounts) external {
        uint256 length = _userAddresses.length;
        if (length != _amounts.length) {
            revert BatchErrorArrayLengthMismatch(length, _amounts.length);
        }
        for (uint256 i; i < length;) {
            freezeTokens(_userAddresses[i], _amounts[i]);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Thaw tokens for multiple addresses in a single transaction
     * @dev This function checks that the input arrays have matching lengths before processing
     * @param _userAddresses An array of addresses for which to thaw tokens
     * @param _amounts An array of token amounts to thaw, corresponding to each address
     */
    function batchThawTokens(address[] calldata _userAddresses, uint256[] calldata _amounts) external {
        uint256 length = _userAddresses.length;
        if (length != _amounts.length) {
            revert BatchErrorArrayLengthMismatch(length, _amounts.length);
        }
        for (uint256 i; i < length;) {
            thawTokens(_userAddresses[i], _amounts[i]);
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
        return interfaceId == type(IWaltzFreezable).interfaceId || super.supportsInterface(interfaceId);
    }
}
