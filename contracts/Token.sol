// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { WaltzFreezable } from "./waltz/extensions/freezable/WaltzFreezable.sol";
import { WaltzTransferFee } from "./waltz/extensions/transfer-fee/WaltzTransferFee.sol";
import { IWaltzTransferFee } from "./waltz/extensions/transfer-fee/interfaces/IWaltzTransferFee.sol";
import { WaltzCompliance } from "./waltz/extensions/compliance/WaltzCompliance.sol";
import { WaltzPausable } from "./waltz/extensions/pausable/WaltzPausable.sol";
import { Waltz } from "./waltz/Waltz.sol";
import { IWaltz } from "./waltz/interfaces/IWaltz.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { WaltzBurnable } from "./waltz/extensions/burnable/WaltzBurnable.sol";
import { WaltzMintable } from "./waltz/extensions/mintable/WaltzMintable.sol";
import { WaltzAccessControl } from "./waltz/extensions/access-control/WaltzAccessControl.sol";
import { IWaltzComplianceCheck } from "./waltz/extensions/compliance/checks/interfaces/IWaltzComplianceCheck.sol";
import { WaltzRescuable } from "./waltz/extensions/rescuable/WaltzRescuable.sol";
import { WaltzCappable } from "./waltz/extensions/cappable/WaltzCappable.sol";

/**
 * @title Token
 * @dev A comprehensive implementation of the Waltz token with various functionalities.
 * @notice This contract combines ERC20 with multiple Waltz extensions to create a feature-rich token.
 * @custom:security-contact security@settlemint.com
 */
// slither-disable-next-line locked-ether

contract Token is
    ERC20,
    Waltz,
    WaltzFreezable,
    WaltzPausable,
    WaltzBurnable,
    WaltzMintable,
    WaltzAccessControl,
    WaltzTransferFee,
    WaltzCompliance,
    WaltzRescuable,
    WaltzCappable
{
    /**
     * @notice Constructs the Token
     * @dev Initializes the token with its core parameters
     * @param name_ The name of the token
     * @param symbol_ The symbol of the token
     * @param feeRecipient_ The address that will receive transfer fees
     * @param cap_ The maximum total supply of the token
     */
    constructor(
        string memory name_,
        string memory symbol_,
        address feeRecipient_,
        uint256 cap_
    )
        payable
        ERC20(name_, symbol_)
        WaltzTransferFee(feeRecipient_)
        WaltzRescuable(feeRecipient_)
        WaltzCappable(cap_)
        WaltzAccessControl(3 days, msg.sender)
    { }

    /**
     * @notice Returns the version of the token contract
     * @return A string representing the version of the contract
     */
    function version() external pure returns (string memory) {
        return "1.0.0";
    }

    /**
     * @notice Mints new tokens
     * @dev Only accounts with the MINTER_ROLE can call this function
     * @param to The address that will receive the minted tokens
     * @param amount The amount of tokens to mint
     */
    function mint(address to, uint256 amount) public virtual override onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    /**
     * @notice Mints/transfer tokens to user in case of lazy mint issuance request
     * @dev Only accounts with the MINTER_ROLE can call this function
     * @param to The address that will receive the tokens
     * @param amount The amount of tokens to mint/transfer
     */
    function mintFromMintSource(address to, uint256 amount) public virtual onlyRole(MINTER_ROLE) {
        address mintSourceAddress = mintSource();
        uint256 balanceOfVault = balanceOf(mintSourceAddress);
        if (amount > balanceOfVault) {
            uint256 excessAmountToBeMinted = amount - balanceOfVault;
            _mint(mintSourceAddress, excessAmountToBeMinted);
            _transfer(mintSourceAddress, to, amount);
        } else {
            _transfer(mintSourceAddress, to, amount);
        }
    }
    

    function _transferTransferBatch(address _toList, uint256 _amounts) internal virtual override returns (bool) {
        _transfer(msg.sender, _toList, _amounts);
        return true;
    }

    function _transferTransferFromBatch(
        address _fromList,
        address _toList,
        uint256 _amounts
    )
        internal
        virtual
        override
        returns (bool)
    {
        _transfer(_fromList, _toList, _amounts);
        return true;
    }

    /**
     * @notice Burns tokens from the caller's account
     * @dev Only accounts with the BURNER_ROLE can call this function
     * @param value The amount of tokens to burn
     */
    function burn(uint256 value) public virtual override onlyRole(BURNER_ROLE) {
        _burn(_msgSender(), value);
    }

    /**
     * @notice sends token from caller's account to burnTarget address
     * @param value The amount of tokens to send it back to burnTarget address
     */
    function burntoBurnTarget(uint256 value) public virtual {
        transfer(burnTarget(), value);
    }

    /**
     * @notice Burns tokens from a specified account
     * @dev Only accounts with the BURNER_ROLE can call this function
     * @param account The account from which tokens will be burned
     * @param value The amount of tokens to burn
     */
    function burnFrom(address account, uint256 value) public virtual override onlyRole(BURNER_ROLE) {
        _burn(account, value);
    }

    /**
     * @notice Updates balances and total supply
     * @dev Overrides the _update function with additional checks
     * @param from The address to transfer from
     * @param to The address to transfer to
     * @param value The amount of tokens to transfer
     */
    function _update(
        address from,
        address to,
        uint256 value
    )
        internal
        virtual
        override(ERC20)
        whenNotPaused
        whenThawed(from)
        whenThawed(to)
        whenCapNotExeeded(from, value)
        notExceedingThawedBalance(from, value)
        whenComplianceChecked(from, to, value)
    {
        uint256 newValue = _transferFee(from, to, value);
        if (value - newValue > 0) super._update(from, this.feeRecipient(), value - newValue);
        super._update(from, to, newValue);
    }

    /**
     * @notice Pauses all token transfers
     * @dev Can only be called by accounts with the PAUSER_ROLE
     */
    function pause() external virtual override onlyRole(PAUSER_ROLE) {
        super._pause();
    }

    /**
     * @notice Unpauses all token transfers
     * @dev Can only be called by accounts with the PAUSER_ROLE
     */
    function unpause() external virtual override onlyRole(PAUSER_ROLE) {
        super._unpause();
    }

    /**
     * @notice Freezes an address for this token
     * @dev Can only be called by accounts with the FREEZER_ROLE
     * @param _userAddress The address to freeze
     */
    function freezeAddress(address _userAddress) public virtual override onlyRole(FREEZER_ROLE) {
        super.freezeAddress(_userAddress);
    }

    /**
     * @notice Unfreezes an address for this token
     * @dev Can only be called by accounts with the FREEZER_ROLE
     * @param _userAddress The address to unfreeze
     */
    function thawAddress(address _userAddress) public virtual override onlyRole(FREEZER_ROLE) {
        super.thawAddress(_userAddress);
    }

    /**
     * @notice Freezes a specified amount of tokens for a given address
     * @dev This function can only be called by a wallet with the FREEZER_ROLE
     * @param _userAddress The address for which to freeze tokens
     * @param _amount Amount of tokens to be frozen
     */
    function freezeTokens(address _userAddress, uint256 _amount) public virtual override onlyRole(FREEZER_ROLE) {
        super.freezeTokens(_userAddress, _amount);
    }

    /**
     * @notice Unfreezes a specified amount of tokens for a given address
     * @dev This function can only be called by a wallet with the FREEZER_ROLE
     * @param _userAddress The address for which to unfreeze tokens
     * @param _amount Amount of tokens to be unfrozen
     */
    function thawTokens(address _userAddress, uint256 _amount) public virtual override onlyRole(FREEZER_ROLE) {
        super.thawTokens(_userAddress, _amount);
    }

    /**
     * @notice Sets a new fee recipient
     * @dev Can only be called by accounts with the DEFAULT_ADMIN_ROLE
     * @param newFeeRecipient The address of the new fee recipient
     */
    function setFeeRecipient(address newFeeRecipient) public virtual override onlyRole(DEFAULT_ADMIN_ROLE) {
        super.setFeeRecipient(newFeeRecipient);
    }

    function feeRecipient() public virtual override returns (address) {
        return super.feeRecipient();
    }

    
    /**
     * @notice Sets the mint source address
     * @dev Can only be called by accounts with the DEFAULT_ADMIN_ROLE
     * @param mintSource_ The new mint source address
     */
    function setMintSource(address mintSource_) public override onlyRole(DEFAULT_ADMIN_ROLE) {
        super.setMintSource(mintSource_);
    }

    /**
     * @notice Sets the burn target address
     * @dev Can only be called by accounts with the DEFAULT_ADMIN_ROLE
     * @param burnTarget_ The new burn target address
     */
    function setBurnTarget(address burnTarget_) public override onlyRole(DEFAULT_ADMIN_ROLE) {
        super.setBurnTarget(burnTarget_);
    }

    /**
     * @notice Sets the percentage fee for minting operations
     * @param mintFeePercentage_ The new minting fee percentage
     * @dev Can only be called by accounts with the MINTER_ROLE
     * @dev Emits a {FeeChanged} event with FeeType.Mint
     */
    function setMintFeePercentage(uint256 mintFeePercentage_) public override onlyRole(MINTER_ROLE) {
        super.setMintFeePercentage(mintFeePercentage_);
    }

    /**
     * @notice Sets the percentage fee for burning operations
     * @param burnFeePercentage_ The new burning fee percentage
     * @dev Can only be called by accounts with the MINTER_ROLE
     * @dev Emits a {FeeChanged} event with FeeType.Burn
     */
    function setBurnFeePercentage(uint256 burnFeePercentage_) public override onlyRole(MINTER_ROLE) {
        super.setBurnFeePercentage(burnFeePercentage_);
    }

    /**
     * @notice Sets the percentage fee for transfer operations
     * @param transferFeePercentage_ The new transfer fee percentage
     * @dev Can only be called by accounts with the MINTER_ROLE
     * @dev Emits a {FeeChanged} event with FeeType.Transfer
     */
    function setTransferFeePercentage(uint256 transferFeePercentage_) public override onlyRole(MINTER_ROLE) {
        super.setTransferFeePercentage(transferFeePercentage_);
    }

    /**
     * @notice Sets the exempt status for a given address
     * @param _address The address to set the exempt status for
     * @param _exempt The new exempt status
     * @dev Can only be called by accounts with the DEFAULT_ADMIN_ROLE
     * @dev Emits an {AddressExemptStatusChanged} event
     */
    function setAddressExemptStatus(address _address, bool _exempt) public override onlyRole(DEFAULT_ADMIN_ROLE) {
        super.setAddressExemptStatus(_address, _exempt);
    }

    /**
     * @notice Adds a new compliance check
     * @dev Can only be called by accounts with the COMPLIANCE_ROLE
     * @param _complianceCheck The address of the compliance check to add
     */
    function addComplianceCheck(IWaltzComplianceCheck _complianceCheck) public override onlyRole(COMPLIANCE_ROLE) {
        super.addComplianceCheck(_complianceCheck);
    }

    /**
     * @notice Removes an existing compliance check
     * @dev Can only be called by accounts with the COMPLIANCE_ROLE
     * @param _complianceCheck The address of the compliance check to remove
     */
    function removeComplianceCheck(IWaltzComplianceCheck _complianceCheck) public override onlyRole(COMPLIANCE_ROLE) {
        super.removeComplianceCheck(_complianceCheck);
    }
    /**
     * @notice Adds addresses to the exempt list
     * @dev This function allows the addition of addresses that are exempt from compliance checks
     * @param specialAddresses_ An array of addresses to be added to the exempt list
     */

    function addExemptAddress(address[] calldata specialAddresses_) public override onlyRole(COMPLIANCE_ROLE) {
        super.addExemptAddress(specialAddresses_);
    }

    /**
     * @notice Removes addresses from the exempt list
     * @dev This function allows the removal of addresses from the exempt list
     * @param specialAddresses_ An array of addresses to be removed from the exempt list
     */
    function removeExemptAddress(address[] calldata specialAddresses_) public override onlyRole(COMPLIANCE_ROLE) {
        super.removeExemptAddress(specialAddresses_);
    }

    /**
     * @notice Sets the address of the rescue vault
     * @dev This function should be overridden to implement access control
     * @param _rescueRecipient The address of the new rescue vault
     */
    function setRescueVault(address _rescueRecipient) public virtual override onlyRole(RESCUER_ROLE) {
        super.setRescueVault(_rescueRecipient);
    }

    /**
     * @notice Rescues tokens accidentally sent to this contract
     * @dev This function transfers ERC20 tokens or the contract's own tokens to the rescue recipient
     * @param token The address of the token to be rescued (use address(0) for this contract's tokens)
     */
    function rescue(address token) public virtual override onlyRole(RESCUER_ROLE) {
        super.rescue(token);
    }

    /**
     * @notice Sets a new cap on the token's total supply
     * @dev Can only be called by authorized roles (to be implemented in child contracts)
     * @param cap_ The new cap value
     */
    function setCap(uint256 cap_) public virtual override onlyRole(MINTER_ROLE) {
        super.setCap(cap_);
    }

    /**
     * @notice Checks if the contract supports a given interface
     * @dev Overrides the supportsInterface function from multiple parent contracts
     * @param interfaceId The interface identifier to check
     * @return bool True if the contract supports the interface, false otherwise
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(
            WaltzAccessControl,
            WaltzCompliance,
            WaltzFreezable,
            WaltzMintable,
            WaltzPausable,
            WaltzTransferFee,
            WaltzRescuable,
            WaltzCappable
        )
        returns (bool)
    {
        return interfaceId == type(IWaltz).interfaceId || super.supportsInterface(interfaceId);
    }
}
