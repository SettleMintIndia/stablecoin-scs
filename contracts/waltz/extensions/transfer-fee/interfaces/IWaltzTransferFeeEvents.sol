// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title IWaltzTransferFeeEvents
 * @notice Interface for defining events related to Waltz transfer fee functionality
 * @dev This interface should be implemented by contracts that handle Waltz transfer fee events
 * @custom:security-contact security@settlemint.com
 */
interface IWaltzTransferFeeEvents {
    /**
     * @notice Enum representing different types of fees
     * @dev Used to specify the type of fee in events and functions
     */
    enum FeeType {
        Mint,
        Burn,
        Transfer
    }

    /**
     * @notice Emitted when a fee percentage is changed
     * @dev This event is triggered whenever the fee percentage for a specific fee type is updated
     * @param _feeType The type of fee that was changed
     * @param _feePercentage The new fee percentage
     */
    event FeeChanged(FeeType indexed _feeType, uint256 _feePercentage);

    /**
     * @notice Emitted when the fee recipient address is changed
     * @dev This event is triggered when the address designated to receive fees is updated
     * @param _feeRecipient The new fee recipient address
     */
    event FeeRecipientChanged(address indexed _feeRecipient);

    /**
     * @notice Emitted when an address's exempt status is changed
     * @dev This event is triggered when an address is either exempted from or made subject to fees
     * @param _address The address whose exempt status was changed
     * @param _exempt The new exempt status (true if exempt, false if not)
     */
    event AddressExemptStatusChanged(address indexed _address, bool _exempt);

    /**
     * @notice Emitted when a fee is collected
     * @dev This event is triggered whenever a fee is deducted from a transaction
     * @param _from The address from which the fee was collected
     * @param _feeAmount The amount of fee collected
     */
    event FeeCollected(address indexed _from, uint256 _feeAmount);

    /**
     * @notice Emitted when the burn target address is changed
     * @dev This event is triggered when the address designated for burning tokens is updated
     * @param _burnTarget The new burn target address
     */
    event BurnTargetChanged(address indexed _burnTarget);

    /**
     * @notice Emitted when the mint source address is changed
     * @dev This event is triggered when the address designated as the source for minting tokens is updated
     * @param _mintSource The new mint source address
     */
    event MintSourceChanged(address indexed _mintSource);
}
