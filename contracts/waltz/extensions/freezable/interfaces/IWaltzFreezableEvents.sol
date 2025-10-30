// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title IWaltzFreezableEvents
 * @notice Interface for defining events related to Waltz freezable functionality
 * @dev This interface should be implemented by contracts that handle Waltz freezable events
 * @custom:security-contact security@settlemint.com
 */
interface IWaltzFreezableEvents {
    /**
     * @notice Emitted when an address's frozen status is updated to frozen
     * @dev This event is triggered when an address is frozen, preventing it from performing token operations
     * @param _userAddress The address whose frozen status was updated to frozen
     * @param _owner The address that initiated the freeze
     */
    event AddressFrozen(address indexed _userAddress, address indexed _owner);

    /**
     * @notice Emitted when an address's frozen status is updated to thawed (unfrozen)
     * @dev This event is triggered when an address is thawed, allowing it to resume normal token operations
     * @param _userAddress The address whose frozen status was updated to thawed
     * @param _owner The address that initiated the thaw
     */
    event AddressThawed(address indexed _userAddress, address indexed _owner);

    /**
     * @notice Emitted when tokens are frozen for an address
     * @dev This event is triggered when a specific amount of tokens is frozen for an address
     * @param _userAddress The address for which tokens were frozen
     * @param _amount The amount of tokens frozen
     * @param _owner The address that initiated the token freeze
     */
    event TokensFrozen(address indexed _userAddress, uint256 _amount, address indexed _owner);

    /**
     * @notice Emitted when tokens are thawed (unfrozen) for an address
     * @dev This event is triggered when a specific amount of frozen tokens is thawed for an address
     * @param _userAddress The address for which tokens were thawed
     * @param _amount The amount of tokens thawed
     * @param _owner The address that initiated the token thaw
     */
    event TokensThawed(address indexed _userAddress, uint256 _amount, address indexed _owner);
}
