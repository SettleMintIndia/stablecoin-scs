// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { WaltzFactory } from "./waltz/WaltzFactory.sol";
import { WaltzAccessControl } from "./waltz/extensions/access-control/WaltzAccessControl.sol";
import { IWaltzRegistry } from "./waltz/interfaces/IWaltzRegistry.sol";
import { Token } from "./Token.sol";
import { IWaltzComplianceCheck } from "./waltz/extensions/compliance/checks/interfaces/IWaltzComplianceCheck.sol";

/**
 * @title LazyMintFactory
 * @dev A factory contract for creating and managing LazyMintWaltz tokens.
 * @notice This contract allows for the creation of new LazyMintWaltz tokens with predefined roles.
 * @custom:security-contact security@settlemint.com
 */
contract Factory is WaltzFactory, WaltzAccessControl {
    // PrivadoIdUniversalVerifier immutable privadoIdUniversalVerifier;
    /**
     * @dev Constructor for LazyMintFactory
     * @param registry The address of the WaltzRegistry contract
     */
    constructor(IWaltzRegistry registry) WaltzFactory(registry) WaltzAccessControl(3 days, msg.sender) { }

    /**
     * @notice Creates a new LazyMintWaltz token
     * @dev Only accounts with TOKEN_CREATION_ROLE can call this function
     * @param name_ The name of the new token
     * @param symbol_ The symbol of the new token
     * @param feeRecipient_ The address that will receive fees
     * @param cap_ The maximum supply cap for the token
     * @param roles An array of addresses to be assigned specific roles in the new token
     */
    function createToken(
        string calldata name_,
        string calldata symbol_,
        address feeRecipient_,
        uint256 cap_,
        address[] calldata roles,
        address vault_,
        uint256 preMintAmount_,
        address privadoIdUniversalVerifier_
    )
        external
        onlyRole(TOKEN_CREATION_ROLE)
    {
        Token token = new Token(name_, symbol_, feeRecipient_, cap_);

        token.grantRole(token.FREEZER_ROLE(), roles[0]);
        token.grantRole(token.PAUSER_ROLE(), roles[1]);
        token.grantRole(token.MINTER_ROLE(), roles[2]);
        token.grantRole(token.BURNER_ROLE(), roles[3]);
        token.grantRole(token.COMPLIANCE_ROLE(), roles[4]);
        token.grantRole(token.RESCUER_ROLE(), roles[5]);

        bool isPreMint = preMintAmount_ > 0;
        // forgecov: disable-next-line
        if (isPreMint) {
            token.grantRole(token.MINTER_ROLE(), address(this));
            token.mint(vault_, preMintAmount_);
            token.revokeRole(token.MINTER_ROLE(), address(this));
            token.setMintSource(vault_);
            token.setBurnTarget(vault_);
        } else {
            token.setMintSource(vault_);
            token.setBurnTarget(vault_);
        }

        this.registry().addToken(address(token), symbol_, address(this), isPreMint ? "pre" : "lazy");
        IWaltzComplianceCheck(privadoIdUniversalVerifier_).setRequestId(
            address(token), 1_723_452_139_885, 1_723_452_139_885
        );
        emit TokenCreated(address(token), symbol_);
    }
}
