// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IWaltz } from "./interfaces/IWaltz.sol";

/**
 * @title Waltz
 * @dev Abstract contract implementing the IWaltz interface
 * @notice This contract serves as a base for implementing the Waltz protocol
 * @custom:experimental This is an experimental contract
 * @custom:security-contact security@settlemint.com
 */
abstract contract Waltz is IWaltz {
    function _transferTransferFromBatch(
        address _fromList,
        address _toList,
        uint256 _amounts
    )
        internal
        virtual
        returns (bool)
    { }
    /**
     * @notice Performs batch transferFrom operations
     * @dev Transfers tokens from multiple addresses to multiple recipients
     * @param _fromList Array of addresses to transfer from
     * @param _toList Array of addresses to transfer to
     * @param _amounts Array of token amounts to transfer
     */

    function batchTransferFrom(
        address[] calldata _fromList,
        address[] calldata _toList,
        uint256[] calldata _amounts
    )
        public
        virtual
    {
        if (_toList.length != _amounts.length || _fromList.length != _amounts.length) {
            revert BatchErrorArrayLengthMismatch(_amounts.length, _toList.length);
        }
        for (uint256 i; i < _amounts.length;) {
            // slither-disable-next-line arbitrary-send-erc20
            _transferTransferFromBatch(_fromList[i], _toList[i], _amounts[i]);
            unchecked {
                ++i;
            }
        }
    }


    function _transferTransferBatch(address _toList, uint256 _amounts) internal virtual returns (bool) { }

    /**
     * @notice Performs batch transfer operations
     * @dev Transfers tokens from the caller to multiple recipients
     * @param _toList Array of addresses to transfer to
     * @param _amounts Array of token amounts to transfer
     */
    function batchTransfer(address[] calldata _toList, uint256[] calldata _amounts) public virtual {
        if (_toList.length != _amounts.length) {
            revert BatchErrorArrayLengthMismatch(_toList.length, _amounts.length);
        }

        for (uint256 i; i < _toList.length;) {
            _transferTransferBatch(_toList[i], _amounts[i]);

            unchecked {
                ++i;
            }
        }
    }
}
