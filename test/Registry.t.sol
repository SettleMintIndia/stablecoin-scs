//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import { Registry } from "../contracts/Registry.sol";

contract RegistryTest is Test {
    // Contract instances
    Registry public registry;

    // Addresses
    address public deployer = address(0x75668b893F548166E94B6Cc305B43696d0a033D0);
    address public creator = address(0xf4e69fDf11e743A12561F1CB8bEc092E8FAa00c7);
    address public vault = address(0xA818C7A87604D9cfBFDd2232114FD894A5E446A3);
    address public rescuer = address(0x3772B9cD3d752fFF826B57291B8A9a2B0d915Cf2);
    address public freezer = address(0xd4012FFccC143D3985144dA754b892F1f994C6d1);
    address public pauser = address(0xE74ce20F326dd45FDf7f7c24377cc249EeDB5c00);
    address public supplier = address(0x99AFbb98dab8413f8d81C23FBc30047475B38549);
    address public complianceManager = address(0x1C6f0c1a0f89725f0D1AB0A30b56F97610559093);

    function setUp() public {
        vm.startPrank(deployer);
        registry = new Registry();
        vm.stopPrank();
    }

    function testInitialState() public {
        assertEq(registry.hasRole(registry.DEFAULT_ADMIN_ROLE(), deployer), true);
    }

    function testGrantRole() public {
        vm.startPrank(deployer);
        registry.grantRole(registry.FACTORY_ROLE(), creator);
        vm.stopPrank();

        assertEq(registry.hasRole(registry.FACTORY_ROLE(), creator), true);
    }

    function testRevokeRole() public {
        vm.startPrank(deployer);
        registry.grantRole(registry.FACTORY_ROLE(), creator);
        registry.revokeRole(registry.FACTORY_ROLE(), creator);
        vm.stopPrank();

        assertEq(registry.hasRole(registry.FACTORY_ROLE(), creator), false);
    }

    function testRegisterToken() public {
        address mockToken = address(0x1234);

        vm.startPrank(deployer);
        registry.grantRole(registry.FACTORY_ROLE(), creator);
        vm.stopPrank();

        vm.startPrank(creator);
        registry.addToken(mockToken, "MOCK", address(this), "test");
        vm.stopPrank();

        Registry.Token memory token = registry.getTokenByAddress(mockToken);
        assertEq(token.tokenAddress, mockToken);
        assertEq(token.symbol, "MOCK");
        assertEq(token.tokenFactory, address(this));
    }

    function testFailRegisterTokenUnauthorized() public {
        address mockToken = address(0x1234);

        vm.expectRevert();
        vm.prank(creator);
        registry.addToken(mockToken, "MOCK", address(this), "test");
    }

    function testGetRegisteredTokens() public {
        address mockToken1 = address(0x1234);
        address mockToken2 = address(0x5678);

        vm.startPrank(deployer);
        registry.grantRole(registry.FACTORY_ROLE(), creator);
        vm.stopPrank();

        vm.startPrank(creator);
        registry.addToken(mockToken1, "MOCK1", address(this), "test");
        registry.addToken(mockToken2, "MOCK2", address(this), "test");
        vm.stopPrank();

        Registry.Token[] memory tokens = registry.getTokenList();
        assertEq(tokens.length, 2);
    }

    function testGetTokenByIndex() public {
        address mockToken = address(0x1234);

        vm.startPrank(deployer);
        registry.grantRole(registry.FACTORY_ROLE(), creator);
        vm.stopPrank();

        vm.startPrank(creator);
        registry.addToken(mockToken, "MOCK", address(this), "test");
        vm.stopPrank();

        Registry.Token memory token = registry.getTokenByIndex(0);
        assertEq(token.tokenAddress, mockToken);
        assertEq(token.symbol, "MOCK");
        assertEq(token.tokenFactory, address(this));
    }

    function testFailGetTokenByIndex() public {
        address mockToken = address(0x1234);

        vm.startPrank(deployer);
        registry.grantRole(registry.FACTORY_ROLE(), creator);
        vm.stopPrank();

        vm.startPrank(creator);
        registry.addToken(mockToken, "MOCK", address(this), "test");
        vm.stopPrank();

        registry.getTokenByIndex(1);
    }

    function testTokenBySymbol() public {
        address mockToken = address(0x1234);

        vm.startPrank(deployer);
        registry.grantRole(registry.FACTORY_ROLE(), creator);
        vm.stopPrank();

        vm.startPrank(creator);
        registry.addToken(mockToken, "MOCK", address(this), "test");
        vm.stopPrank();

        Registry.Token memory token = registry.getTokenBySymbol("MOCK");
        assertEq(token.tokenAddress, mockToken);
        assertEq(token.symbol, "MOCK");
        assertEq(token.tokenFactory, address(this));
    }

    function testFailGetTokenBySymbol() public {
        address mockToken = address(0x1234);

        vm.startPrank(deployer);
        registry.grantRole(registry.FACTORY_ROLE(), creator);
        vm.stopPrank();

        vm.startPrank(creator);
        registry.addToken(mockToken, "MOCK", address(this), "test");
        vm.stopPrank();

        registry.getTokenBySymbol("MOCK1");
    }

    function testFailGetTokenByAddress() public {
        address mockToken = address(0x1234);
        address mockToken2 = address(0x12345);

        vm.startPrank(deployer);
        registry.grantRole(registry.FACTORY_ROLE(), creator);
        vm.stopPrank();

        vm.startPrank(creator);
        registry.addToken(mockToken, "MOCK", address(this), "test");
        vm.stopPrank();

        registry.getTokenByAddress(mockToken2);
    }

    function testFailTokenAddressAlreadyExistsRevert() public {
        address mockToken = address(0x1234);

        vm.startPrank(deployer);
        registry.grantRole(registry.FACTORY_ROLE(), creator);
        vm.stopPrank();

        vm.startPrank(creator);
        registry.addToken(mockToken, "MOCK", address(this), "test");
        vm.stopPrank();

        Registry.Token memory token = registry.getTokenByAddress(mockToken);
        assertEq(token.tokenAddress, mockToken);
        assertEq(token.symbol, "MOCK");
        assertEq(token.tokenFactory, address(this));

        vm.startPrank(creator);
        registry.addToken(mockToken, "MOCK", address(this), "test");
        vm.stopPrank();
    }

    function testFailTokenSymbolAlreadyExistsRevert() public {
        address mockToken = address(0x1234);

        vm.startPrank(deployer);
        registry.grantRole(registry.FACTORY_ROLE(), creator);
        vm.stopPrank();

        vm.startPrank(creator);
        registry.addToken(mockToken, "MOCK", address(this), "test");
        vm.stopPrank();

        Registry.Token memory token = registry.getTokenByAddress(mockToken);
        assertEq(token.tokenAddress, mockToken);
        assertEq(token.symbol, "MOCK");
        assertEq(token.tokenFactory, address(this));
        address mockTokenNew = address(0x12345);
        vm.startPrank(creator);
        registry.addToken(mockTokenNew, "MOCK", address(this), "test");
        vm.stopPrank();
    }
}
