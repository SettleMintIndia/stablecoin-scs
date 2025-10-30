// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IWaltzTransferFee } from "./interfaces/IWaltzTransferFee.sol";
import { ERC165 } from "@openzeppelin/contracts/utils/introspection/ERC165.sol";

/**
 * @title WaltzTransferFee
 * @notice Implements transfer fee functionality for Waltz tokens
 * @dev Inherits from IWaltzTransferFee interface and ERC165
 * @custom:security-contact security@settlemint.com
 */

abstract contract WaltzTransferFee is IWaltzTransferFee, ERC165 {
    /// @notice The address from which minting occurs
    address private _mintSource;

    /// @notice The address to which burning occurs
    address private _burnTarget;

    /// @notice Mapping of addresses exempt from transfer fees
    mapping(address => bool) private _exemptAddresses;

    /// @notice The address that receives the collected fees
    address private _feeRecipient;

    /// @notice The percentage fee applied to minting operations
    uint256 private _mintFeePercentage = 0;

    /// @notice The percentage fee applied to burning operations
    uint256 private _burnFeePercentage = 0;

    /// @notice The percentage fee applied to transfer operations
    uint256 private _transferFeePercentage = 0;

    /**
     * @notice Initializes the contract with a fee recipient
     * @param feeRecipient_ The address that will receive the collected fees
     * @dev Sets the initial fee recipient and marks it as exempt from fees
     */
    constructor(address feeRecipient_) {
        _feeRecipient = feeRecipient_;
        _exemptAddresses[feeRecipient_] = true;
        _exemptAddresses[address(this)] = true;
    }

    /**
     * @notice Returns the current fee recipient address
     * @return The address that receives the collected fees
     */
    function feeRecipient() public virtual returns (address) {
        return _feeRecipient;
    }
    
    /**
     * @notice Sets a new fee recipient address
     * @param newFeeRecipient The address to set as the new fee recipient
     * @dev Should be restricted to authorized roles
     * @dev Emits a {FeeRecipientChanged} event
     */
    function setFeeRecipient(address newFeeRecipient) public virtual {
        address oldFeeRecipient = _feeRecipient;
        _feeRecipient = newFeeRecipient;
        _exemptAddresses[oldFeeRecipient] = false;
        _exemptAddresses[newFeeRecipient] = true;
        emit FeeRecipientChanged(newFeeRecipient);
    }

    /**
     * @notice Sets the address from which minting occurs
     * @param mintSource_ The new mint source address
     * @dev Should be restricted to authorized roles
     * @dev Emits a {MintSourceChanged} event
     */
    function setMintSource(address mintSource_) public virtual {
        _mintSource = mintSource_;
        emit MintSourceChanged(mintSource_);
    }

    /**
     * @notice Sets the address to which burning occurs
     * @param burnTarget_ The new burn target address
     * @dev Should be restricted to authorized roles
     * @dev Emits a {BurnTargetChanged} event
     */
    function setBurnTarget(address burnTarget_) public virtual {
        _burnTarget = burnTarget_;
        emit BurnTargetChanged(burnTarget_);
    }

    /**
     * @notice Returns the current mint source address
     * @return The address from which minting occurs
     */
    function mintSource() public view returns (address) {
        return _mintSource;
    }

    /**
     * @notice Returns the current burn target address
     * @return The address to which burning occurs
     */
    function burnTarget() public view returns (address) {
        return _burnTarget;
    }

    /**
     * @notice Sets the percentage fee for minting operations
     * @param mintFeePercentage_ The new minting fee percentage
     * @dev Should be restricted to authorized roles
     * @dev Emits a {FeeChanged} event with FeeType.Mint
     */
    function setMintFeePercentage(uint256 mintFeePercentage_) public virtual {
        if (mintFeePercentage_ > 100 * 10 ** 18) {
            revert FeePercentageMoreThan100(mintFeePercentage_);
        }
        _mintFeePercentage = mintFeePercentage_;
        emit FeeChanged(FeeType.Mint, mintFeePercentage_);
    }

    /**
     * @notice Sets the percentage fee for burning operations
     * @param burnFeePercentage_ The new burning fee percentage
     * @dev Should be restricted to authorized roles
     * @dev Emits a {FeeChanged} event with FeeType.Burn
     */
    function setBurnFeePercentage(uint256 burnFeePercentage_) public virtual {
        if (burnFeePercentage_ > 100 * 10 ** 18) {
            revert FeePercentageMoreThan100(burnFeePercentage_);
        }
        _burnFeePercentage = burnFeePercentage_;
        emit FeeChanged(FeeType.Burn, burnFeePercentage_);
    }

    /**
     * @notice Sets the percentage fee for transfer operations
     * @param transferFeePercentage_ The new transfer fee percentage
     * @dev Should be restricted to authorized roles
     * @dev Emits a {FeeChanged} event with FeeType.Transfer
     */
    function setTransferFeePercentage(uint256 transferFeePercentage_) public virtual {
        if (transferFeePercentage_ > 100 * 10 ** 18) {
            revert FeePercentageMoreThan100(transferFeePercentage_);
        }
        _transferFeePercentage = transferFeePercentage_;
        emit FeeChanged(FeeType.Transfer, transferFeePercentage_);
    }

    /**
     * @notice Returns the current minting fee percentage
     * @return The minting fee percentage
     */
    function mintFeePercentage() external view returns (uint256) {
        return _mintFeePercentage;
    }

    /**
     * @notice Returns the current burning fee percentage
     * @return The burning fee percentage
     */
    function burnFeePercentage() external view returns (uint256) {
        return _burnFeePercentage;
    }

    /**
     * @notice Returns the current transfer fee percentage
     * @return The transfer fee percentage
     */
    function transferFeePercentage() external view returns (uint256) {
        return _transferFeePercentage;
    }

    /**
     * @notice Sets the exempt status for a given address
     * @param _address The address to set the exempt status for
     * @param _exempt The new exempt status
     * @dev Should be restricted to authorized roles
     * @dev Emits an {AddressExemptStatusChanged} event
     */
    function setAddressExemptStatus(address _address, bool _exempt) public virtual {
        if (_address == address(0)) {
            revert ZeroAddressNotAllowed();
        }
        _exemptAddresses[_address] = _exempt;
        emit AddressExemptStatusChanged(_address, _exempt);
    }

    /**
     * @notice Checks if an address is exempt from fees
     * @param _address The address to check
     * @return True if the address is exempt, false otherwise
     */
    function _isExempt(address _address) public view returns (bool) {
        return _exemptAddresses[_address];
    }

    /**
     * @notice Calculates the fee for burning operations
     * @param _from The address sending tokens
     * @param _amount The amount of tokens being burned
     * @return feeAmount The amount of fee to be collected
     * @return amountAfterFee The amount of tokens after fee deduction
     * @dev Emits a {FeeCollected} event if a fee is applied
     */
    function _calculateBurnFee(
        address _from,
        address, /*_to*/
        uint256 _amount
    )
        private
        returns (uint256 feeAmount, uint256 amountAfterFee)
    {
        if (_isExempt(_from)) {
            return (0, _amount);
        }
        feeAmount = (_amount * _burnFeePercentage) / (100 * 10 ** 18);
        amountAfterFee = _amount - feeAmount;

        emit FeeCollected(_from, feeAmount);
    }

    /**
     * @notice Calculates the mint fee for a given transfer
     * @param _from The address sending the tokens
     * @param _to The address receiving the tokens
     * @param _amount The amount of tokens being transferred
     * @return feeAmount The amount of fee collected
     * @return amountAfterFee The amount of tokens after deducting the fee
     */
    function _calculateMintFee(
        address _from,
        address _to,
        uint256 _amount
    )
        private
        returns (uint256 feeAmount, uint256 amountAfterFee)
    {
        if (_isExempt(_to)) {
            return (0, _amount);
        }

        feeAmount = (_amount * _mintFeePercentage) / (100 * 10 ** 18);
        amountAfterFee = _amount - feeAmount;
        emit FeeCollected(_from, feeAmount);
    }

    /**
     * @notice Calculates the fee for transfer operations
     * @param _from The address sending tokens
     * @param _amount The amount of tokens being transferred
     * @return feeAmount The amount of fee to be collected
     * @return amountAfterFee The amount of tokens after fee deduction
     * @dev Emits a {FeeCollected} event if a fee is applied
     */
    function _calculateTransferFee(
        address _from,
        address, /*_to*/
        uint256 _amount
    )
        private
        returns (uint256 feeAmount, uint256 amountAfterFee)
    {
        if (_isExempt(_from)) {
            return (0, _amount);
        }
        feeAmount = (_amount * _transferFeePercentage) / (100 * 10 ** 18);
        amountAfterFee = _amount - feeAmount;
        emit FeeCollected(_from, feeAmount);
    }

    /**
     * @notice Handles the transfer fee calculation and application
     * @param _from The address sending tokens
     * @param _to The address receiving tokens
     * @param _amount The amount of tokens that should be transferred
     * @return The amount of tokens after fee deduction
     * @dev Called during transfer operations
     * @dev Determines the type of operation (burn, mint, or transfer) and applies the appropriate fee
     * @dev The collected fee is transferred to the fee recipient
     */
    function _transferFee(address _from, address _to, uint256 _amount) internal returns (uint256) {
        uint256 feeAmount;
        uint256 amountAfterFee;
        if (_from == address(0) || _to == address(0)) {
            return _amount;
        }

        if (_to == _burnTarget && _from != address(0)) {
            (feeAmount, amountAfterFee) = _calculateBurnFee(_from, _to, _amount);
        } else if (_from == _mintSource ) {
            (feeAmount, amountAfterFee) = _calculateMintFee(_from, _to, _amount);
        } else {
            (feeAmount, amountAfterFee) = _calculateTransferFee(_from, _to, _amount);
        }
        return amountAfterFee;
    }

    /**
     * @notice Checks if the contract supports a given interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return bool True if the contract supports the interface, false otherwise
     * @dev Overrides the supportsInterface function from ERC165
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IWaltzTransferFee).interfaceId || super.supportsInterface(interfaceId);
    }
}
