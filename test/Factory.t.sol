//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import { Factory } from "../contracts/Factory.sol";
import { Token } from "../contracts/Token.sol";
import { Registry } from "../contracts/Registry.sol";
import { PrivadoIdUniversalVerifier } from
    "../contracts/waltz/extensions/compliance/checks/PrivadoIdUniversalVerifier.sol";
import { IUniversalVerifier } from
    "../contracts/waltz/extensions/compliance/checks/interfaces/privado-id/IUniversalVerifier.sol";

contract FactoryTest is Test {
    // Addresses
    address public deployer = address(0x75668b893F548166E94B6Cc305B43696d0a033D0);
    address public creator = address(0xf4e69fDf11e743A12561F1CB8bEc092E8FAa00c7);
    address public vault = address(0xA818C7A87604D9cfBFDd2232114FD894A5E446A3);
    address public rescuer = address(0x3772B9cD3d752fFF826B57291B8A9a2B0d915Cf2);
    address public freezer = address(0xd4012FFccC143D3985144dA754b892F1f994C6d1);
    address public pauser = address(0xE74ce20F326dd45FDf7f7c24377cc249EeDB5c00);
    address public burner = address(0xd4012FFccC143D3985144dA754b892F1f994C6d1);
    address public supplier = address(0x99AFbb98dab8413f8d81C23FBc30047475B38549);
    address public complianceManager = address(0x1C6f0c1a0f89725f0D1AB0A30b56F97610559093);
    address public collector = address(0xc2687c80C985B645438d93Dc576E13dCb186BeAD);
    //test address
    address public user1;
    address public user2;
    // Contracts
    Factory public factory;
    Registry public registry;
    PrivadoIdUniversalVerifier public privadoIdUniversalVerifier;
    IUniversalVerifier public universalVerifier;

    function setUp() public {
        vm.startPrank(deployer);

        // Deploy Registry
        registry = new Registry();

        // Deploy LazyMintFactory
        factory = new Factory(registry);

        // Initialize universalVerifier
        universalVerifier = IUniversalVerifier(0x70696036CA1868B42155b06235F95549667Eb0BE);

        // deploying PrivadoIdUVerifier
        privadoIdUniversalVerifier = new PrivadoIdUniversalVerifier(universalVerifier);

        // Grant necessary roles
        registry.grantRole(registry.FACTORY_ROLE(), address(factory));
        factory.grantRole(factory.TOKEN_CREATION_ROLE(), creator);

        vm.stopPrank();
    }

    function testInitialState() public {
        assertEq(address(factory.registry()), address(registry));
        assertTrue(factory.hasRole(factory.TOKEN_CREATION_ROLE(), creator));
    }

    function testRegistry() public {
        address registryAddress = address(factory.registry());
        assertEq(registryAddress, address(registry));
    }

    function testCreateTokenPre() public {
        uint256 cap = 100_000_000 * 10 ** 18;
        uint256 preMintAmount = 1000 * 10 ** 18;
        address[] memory rolesArr = new address[](6);
        rolesArr[0] = freezer;
        rolesArr[1] = pauser;
        rolesArr[2] = supplier;
        rolesArr[3] = burner;
        rolesArr[4] = complianceManager;
        rolesArr[5] = rescuer;
        user1 = address(0x1);
        user2 = address(0x2);

        //  complianceAddress = 0x75668b893F548166E94B6Cc305B43696d0a033D0;

        vm.startPrank(deployer);

        // Deploy Registry
        registry = new Registry();

        // Deploy PreMintFactory
        factory = new Factory(registry);

        // Grant necessary roles
        registry.grantRole(registry.FACTORY_ROLE(), address(factory));
        factory.grantRole(factory.TOKEN_CREATION_ROLE(), creator);
        vm.stopPrank();
        vm.startPrank(creator);
        factory.createToken(
            "test", "TST", collector, cap, rolesArr, vault, preMintAmount, address(privadoIdUniversalVerifier)
        );
        vm.stopPrank();
        Registry.Token memory getToken = registry.getTokenBySymbol("TST");
        Token deployedToken = Token(getToken.tokenAddress);
        assertEq(deployedToken.balanceOf(vault), preMintAmount);
        Registry.Token memory getTokenByIndex = registry.getTokenByIndex(0);
        assertEq(getToken.tokenAddress, getTokenByIndex.tokenAddress);
    }

    function testdeployFactory() public {
        vm.startPrank(deployer);
        factory = new Factory(registry);
        vm.stopPrank();
        address registryAddress = address(factory.registry());
        assertEq(registryAddress, address(registry));
    }

    function testCreateToken() public {
        string memory name = "Test Token";
        string memory symbol = "TST";
        uint256 cap = 100_000_000 * 10 ** 18;
        uint256 preMintAmount = 0;
        address[] memory roles = new address[](6);
        roles[0] = freezer;
        roles[1] = pauser;
        roles[2] = supplier;
        roles[3] = burner;
        roles[4] = complianceManager;
        roles[5] = rescuer;

        vm.startPrank(creator);
        factory.createToken(
            name, symbol, collector, cap, roles, vault, preMintAmount, address(privadoIdUniversalVerifier)
        );
        vm.stopPrank();

        // Verify token is registered
        Registry.Token memory token = registry.getTokenBySymbol(symbol);
        assertEq(token.symbol, symbol);
        assertEq(token.tokenFactory, address(factory));

        // Verify token properties
        Token deployedToken = Token(token.tokenAddress);
        assertEq(deployedToken.name(), name);
        assertEq(deployedToken.symbol(), symbol);
        assertEq(deployedToken.cap(), cap);
        assertEq(deployedToken.feeRecipient(), collector);
        assertEq(deployedToken.totalSupply(), preMintAmount);

        // Verify roles
        assertTrue(deployedToken.hasRole(deployedToken.FREEZER_ROLE(), freezer));
        assertTrue(deployedToken.hasRole(deployedToken.PAUSER_ROLE(), pauser));
        assertTrue(deployedToken.hasRole(deployedToken.MINTER_ROLE(), supplier));
        assertTrue(deployedToken.hasRole(deployedToken.BURNER_ROLE(), burner));
        assertTrue(deployedToken.hasRole(deployedToken.COMPLIANCE_ROLE(), complianceManager));
        assertTrue(deployedToken.hasRole(deployedToken.RESCUER_ROLE(), rescuer));
        assertTrue(deployedToken.hasRole(deployedToken.DEFAULT_ADMIN_ROLE(), address(factory)));
    }

    function testCreatePreMintToken() public {
        string memory name = "Test Token";
        string memory symbol = "TST";
        uint256 cap = 100_000_000 * 10 ** 18;
        uint256 preMintAmount = 1000 * 10 ** 18;
        address[] memory roles = new address[](6);
        roles[0] = freezer;
        roles[1] = pauser;
        roles[2] = supplier;
        roles[3] = rescuer;
        roles[4] = complianceManager;
        roles[5] = rescuer;

        vm.startPrank(creator);
        factory.createToken(
            name, symbol, collector, cap, roles, vault, preMintAmount, address(privadoIdUniversalVerifier)
        );
        vm.stopPrank();

        // Verify token is registered
        Registry.Token memory token = registry.getTokenBySymbol(symbol);
        assertEq(token.symbol, symbol);
        assertEq(token.tokenFactory, address(factory));

        // Verify token properties
        Token deployedToken = Token(token.tokenAddress);
        assertEq(deployedToken.name(), name);
        assertEq(deployedToken.symbol(), symbol);
        assertEq(deployedToken.cap(), cap);
        assertEq(deployedToken.feeRecipient(), collector);
        assertEq(deployedToken.totalSupply(), preMintAmount);

        // Verify roles
        assertTrue(deployedToken.hasRole(deployedToken.FREEZER_ROLE(), freezer));
        assertTrue(deployedToken.hasRole(deployedToken.PAUSER_ROLE(), pauser));
        assertTrue(deployedToken.hasRole(deployedToken.MINTER_ROLE(), supplier));
        assertTrue(deployedToken.hasRole(deployedToken.BURNER_ROLE(), rescuer));
        assertTrue(deployedToken.hasRole(deployedToken.COMPLIANCE_ROLE(), complianceManager));
        assertTrue(deployedToken.hasRole(deployedToken.RESCUER_ROLE(), rescuer));
    }

    function testFailCreateTokenUnauthorized() public {
        string memory name = "Unauthorized Token";
        string memory symbol = "UNT";
        uint256 cap = 1_000_000 * 10 ** 18;
        address[] memory roles = new address[](5);

        vm.prank(address(0xdead));
        vm.expectRevert("AccessControlUnauthorizedAccount");
        factory.createToken(name, symbol, collector, cap, roles, vault, 0, address(privadoIdUniversalVerifier));
    }

    function testFailCreateTokenDuplicateSymbol() public {
        string memory name = "Test Token";
        string memory symbol = "TST";
        uint256 cap = 1_000_000 * 10 ** 18;
        address[] memory roles = new address[](5);

        vm.startPrank(creator);
        factory.createToken(name, symbol, collector, cap, roles, vault, 0, address(privadoIdUniversalVerifier));

        vm.expectRevert("TokenSymbolAlreadyExists");
        factory.createToken(name, symbol, collector, cap, roles, vault, 0, address(privadoIdUniversalVerifier));
        vm.stopPrank();
    }

    function testMultipleTokenCreation() public {
        vm.startPrank(creator);

        for (uint256 i = 0; i < 3; i++) {
            string memory name = string(abi.encodePacked("Test Token ", vm.toString(i)));
            string memory symbol = string(abi.encodePacked("TST", vm.toString(i)));
            uint256 cap = 1_000_000 * 10 ** 18;
            address[] memory roles = new address[](6);
            roles[0] = freezer;
            roles[1] = pauser;
            roles[2] = supplier;
            roles[3] = rescuer;
            roles[4] = complianceManager;
            roles[5] = rescuer;

            factory.createToken(name, symbol, collector, cap, roles, vault, 0, address(privadoIdUniversalVerifier));

            // Verify token is registered
            Registry.Token memory token = registry.getTokenBySymbol(symbol);
            assertEq(token.symbol, symbol);
            assertEq(token.tokenFactory, address(factory));
        }

        vm.stopPrank();

        // Verify total number of tokens in registry
        Registry.Token[] memory tokens = registry.getTokenList();
        assertEq(tokens.length, 3);
    }
}
