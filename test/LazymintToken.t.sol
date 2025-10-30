//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import { Factory } from "../contracts/Factory.sol";
import { Token } from "../contracts/Token.sol";
import { Registry } from "../contracts/Registry.sol";
import { Pausable } from "../contracts/waltz/extensions/pausable/WaltzPausable.sol";
import { IWaltzComplianceCheck } from "../contracts/waltz/extensions/compliance/checks/PrivadoIdUniversalVerifier.sol";
import { PrivadoIdUniversalVerifier } from
    "../contracts/waltz/extensions/compliance/checks/PrivadoIdUniversalVerifier.sol";
import { IUniversalVerifier } from
    "../contracts/waltz/extensions/compliance/checks/interfaces/privado-id/IUniversalVerifier.sol";

contract LazymintToken is Test {
    // Addresses
    Token public token;
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
    address public verifiedAddress = address(0x8e3B1a4E55b826f146a0B61175b497FAd0F245fD);
    address public verifiedAddress2 = address(0x78e339BA558f1785c01b53893A885Ec7e92A40f1);
    uint256 cap = 100_000_000 * 10 ** 18;
    uint256 preMintAmount = 0;
    // uint256 amoyFork;
    //test address
    address public user1;
    address public user2;
    //    IWaltzComplianceCheck public complianceAddress;

    // Contracts
    Factory public factory;
    Registry public registry;
    PrivadoIdUniversalVerifier public privadoIdUniversalVerifier;
    PrivadoIdUniversalVerifier public privadoIdUniversalVerifier2;
    IUniversalVerifier public universalVerifier;
    uint256 amoyFork;
    string AMOY_RPC_URL = vm.envString("AMOY_RPC_URL");

    function setUp() public {
        amoyFork = vm.createFork(AMOY_RPC_URL);
        vm.selectFork(amoyFork);
        assertEq(vm.activeFork(), amoyFork);
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

        // Initialize universalVerifier
        universalVerifier = IUniversalVerifier(0x70696036CA1868B42155b06235F95549667Eb0BE);

        // deploying PrivadoIdUVerifier
        privadoIdUniversalVerifier = new PrivadoIdUniversalVerifier(universalVerifier);

        // Grant necessary roles
        registry.grantRole(registry.FACTORY_ROLE(), address(factory));
        factory.grantRole(factory.TOKEN_CREATION_ROLE(), creator);
        vm.stopPrank();
        vm.startPrank(creator);
        factory.createToken(
            "lazytest", "LTST", collector, cap, rolesArr, vault, preMintAmount, address(privadoIdUniversalVerifier)
        );
        vm.stopPrank();

        address[] memory exemptArr = new address[](9);
        exemptArr[0] = freezer;
        exemptArr[1] = pauser;
        exemptArr[2] = supplier;
        exemptArr[3] = burner;
        exemptArr[4] = complianceManager;
        exemptArr[5] = rescuer;
        exemptArr[6] = vault;
        exemptArr[7] = collector;
        exemptArr[8] = address(0);

        Registry.Token memory getToken = registry.getTokenBySymbol("LTST");
        token = Token(getToken.tokenAddress);
        vm.startPrank(complianceManager);
        token.addComplianceCheck(privadoIdUniversalVerifier);
        token.addExemptAddress(exemptArr);
        vm.stopPrank();
        (uint256 sigRequestId, uint256 mtpRequestId) = privadoIdUniversalVerifier._requestIds(address(token));
        assertEq(sigRequestId, 1_723_452_139_885);
        assertEq(mtpRequestId, 1_723_452_139_885);
        assertEq(token.mintSource(), vault);
        assertEq(token.burnTarget(), vault);
    }

    function testInitialState() public {
        assertEq(token.name(), "lazytest");
        assertEq(token.symbol(), "LTST");
        assertEq(token.cap(), cap);
        assertEq(token.feeRecipient(), collector);
        assertEq(token.totalSupply(), preMintAmount);
        assertEq(token.version(), "1.0.0");
    }

    function testMint() public {
        uint256 mintAmount = 100 * 10 ** 18;
        vm.startPrank(supplier);
        token.mint(vault, mintAmount);
        vm.stopPrank();
        assertEq(token.balanceOf(vault), mintAmount);
    }

    function testBatchMint() public {
        uint256 mintAmount = 100 * 10 ** 18;
        address[] memory addressArr = new address[](2);
        addressArr[0] = vault;
        addressArr[1] = vault;
        uint256[] memory amountArr = new uint256[](2);
        amountArr[0] = mintAmount / 2;
        amountArr[1] = mintAmount / 2;
        vm.startPrank(supplier);
        token.batchMint(addressArr, amountArr);
        vm.stopPrank();
        assertEq(token.balanceOf(vault), mintAmount);
    }

    function testFailBatchMint() public {
        uint256 mintAmount = 100 * 10 ** 18;
        address[] memory addressArr = new address[](1);
        addressArr[0] = vault;
        uint256[] memory amountArr = new uint256[](2);
        amountArr[0] = mintAmount / 2;
        amountArr[1] = mintAmount / 2;
        vm.startPrank(supplier);
        token.batchMint(addressArr, amountArr);
        vm.stopPrank();
        assertEq(token.balanceOf(vault), mintAmount);
    }

    // issue zero address ->vault(internally) -> user1
    function testMintFromMintSource() public {
        uint256 mintAmount = 100 * 10 ** 18;
        vm.startPrank(supplier);
        token.setMintFeePercentage(2 * 10 ** 18);
        token.setTransferFeePercentage(3 * 10 ** 18);
        token.setBurnFeePercentage(4 * 10 ** 18);
        token.setCap(1000 * 10 ** 18);
        vm.stopPrank();
        uint256 feeAmount = mintAmount * token.mintFeePercentage() / (100 * 10 ** 18);
        assertEq(token.mintFeePercentage(), 2 * 10 ** 18);

        vm.startPrank(supplier);
        token.mintFromMintSource(verifiedAddress, mintAmount);
        assertEq(token.balanceOf(collector), feeAmount);
        assertEq(token.balanceOf(verifiedAddress), mintAmount - feeAmount);
    }

    function testMintFromMintSourceWithZeroFee() public {
        uint256 mintAmount = 100 * 10 ** 18;

        vm.startPrank(supplier);
        token.mintFromMintSource(verifiedAddress, mintAmount);
        assertEq(token.balanceOf(collector), 0);
        assertEq(token.balanceOf(verifiedAddress), mintAmount);
    }

    // issue zero address ->vault(internally) -> user1 -> vault -> user2
    function testMintFromMintSourceWhenVaultHaveFewTokens() public {
        uint256 mintAmount = 100 * 10 ** 18;
        vm.startPrank(supplier);
        token.setMintFeePercentage(2 * 10 ** 18);
        vm.stopPrank();
        uint256 feeAmount = mintAmount * token.mintFeePercentage() / (100 * 10 ** 18);
        assertEq(token.mintFeePercentage(), 2 * 10 ** 18);

        vm.startPrank(supplier);
        token.mintFromMintSource(verifiedAddress, mintAmount);
        vm.stopPrank();
        assertEq(token.balanceOf(collector), feeAmount);
        assertEq(token.balanceOf(verifiedAddress), mintAmount - feeAmount);
        assertEq(token.balanceOf(token.mintSource()), 0);

        uint256 redeemAmount = 50 * 10 ** 18;
        vm.startPrank(supplier);
        token.setTransferFeePercentage(1 * 10 ** 18);
        token.setBurnFeePercentage(3 * 10 ** 18);
        vm.stopPrank();
        assertEq(token.burnFeePercentage(), 3 * 10 ** 18);
        uint256 redeemFee = redeemAmount * token.burnFeePercentage() / (100 * 10 ** 18);

        vm.startPrank(verifiedAddress);
        token.burntoBurnTarget(redeemAmount);
        vm.stopPrank();
        assertEq(token.balanceOf(verifiedAddress), mintAmount - feeAmount - redeemAmount);
        assertEq(token.balanceOf(collector), feeAmount + redeemFee);
        assertEq(token.balanceOf(token.mintSource()), redeemAmount - redeemFee);

        uint256 mintToUser2 = 1000 * 10 ** 18;
        assertEq(token.mintFeePercentage(), 2 * 10 ** 18);
        uint256 feeAmountForUser2 = mintToUser2 * token.mintFeePercentage() / (100 * 10 ** 18);
        vm.startPrank(supplier);
        token.mintFromMintSource(verifiedAddress2, mintToUser2);
        assertEq(token.balanceOf(collector), feeAmount + redeemFee + feeAmountForUser2);
        assertEq(token.balanceOf(verifiedAddress2), mintToUser2 - feeAmountForUser2);
        assertEq(token.balanceOf(token.mintSource()), 0);
    }

    // issue zero address ->vault(internally) -> user1 -> vault -> user2
    function testMintFromMintSourceWhenVaultHaveEnoughToken() public {
        uint256 mintAmount = 100 * 10 ** 18;
        vm.startPrank(supplier);
        token.setMintFeePercentage(2 * 10 ** 18);
        vm.stopPrank();
        uint256 feeAmount = mintAmount * token.mintFeePercentage() / (100 * 10 ** 18);
        assertEq(token.mintFeePercentage(), 2 * 10 ** 18);

        vm.startPrank(supplier);
        token.mintFromMintSource(verifiedAddress, mintAmount);
        vm.stopPrank();
        assertEq(token.balanceOf(collector), feeAmount);
        assertEq(token.balanceOf(verifiedAddress), mintAmount - feeAmount);
        assertEq(token.balanceOf(token.mintSource()), 0);

        uint256 redeemAmount = 50 * 10 ** 18;
        vm.startPrank(supplier);
        token.setTransferFeePercentage(1 * 10 ** 18);
        token.setBurnFeePercentage(3 * 10 ** 18);
        vm.stopPrank();
        assertEq(token.burnFeePercentage(), 3 * 10 ** 18);
        uint256 redeemFee = redeemAmount * token.burnFeePercentage() / (100 * 10 ** 18);

        vm.startPrank(verifiedAddress);
        token.burntoBurnTarget(redeemAmount);
        vm.stopPrank();
        assertEq(token.balanceOf(verifiedAddress), mintAmount - feeAmount - redeemAmount);
        assertEq(token.balanceOf(collector), feeAmount + redeemFee);
        assertEq(token.balanceOf(token.mintSource()), redeemAmount - redeemFee);

        uint256 mintToUser2 = 10 * 10 ** 18;
        assertEq(token.mintFeePercentage(), 2 * 10 ** 18);
        uint256 feeAmountForUser2 = mintToUser2 * token.mintFeePercentage() / (100 * 10 ** 18);
        vm.startPrank(supplier);
        token.mintFromMintSource(verifiedAddress2, mintToUser2);
        assertEq(token.balanceOf(collector), feeAmount + redeemFee + feeAmountForUser2);
        assertEq(token.balanceOf(verifiedAddress2), mintToUser2 - feeAmountForUser2);
        assertEq(token.balanceOf(token.mintSource()), redeemAmount - redeemFee - mintToUser2);
    }

    // redeem user1 -> vault address
    function testBurntoBurnTarget() public {
        uint256 mintAmount = 100 * 10 ** 18;
        vm.startPrank(supplier);
        token.setMintFeePercentage(2 * 10 ** 18);
        vm.stopPrank();
        uint256 feeAmount = mintAmount * token.mintFeePercentage() / (100 * 10 ** 18);
        assertEq(token.mintFeePercentage(), 2 * 10 ** 18);

        vm.startPrank(supplier);
        token.mintFromMintSource(verifiedAddress, mintAmount);
        assertEq(token.balanceOf(collector), feeAmount);
        assertEq(token.balanceOf(verifiedAddress), mintAmount - feeAmount);
        assertEq(token.balanceOf(token.mintSource()), 0);

        uint256 redeemAmount = 50 * 10 ** 18;
        vm.startPrank(supplier);
        token.setTransferFeePercentage(1 * 10 ** 18);
        token.setBurnFeePercentage(3 * 10 ** 18);
        vm.stopPrank();
        assertEq(token.burnFeePercentage(), 3 * 10 ** 18);
        uint256 redeemFee = redeemAmount * token.burnFeePercentage() / (100 * 10 ** 18);

        vm.startPrank(verifiedAddress);
        token.burntoBurnTarget(redeemAmount);
        vm.stopPrank();
        assertEq(token.balanceOf(verifiedAddress), mintAmount - feeAmount - redeemAmount);
        assertEq(token.balanceOf(collector), feeAmount + redeemFee);
        assertEq(token.balanceOf(token.mintSource()), redeemAmount - redeemFee);
    }

    function testTransfer() public {
        uint256 mintAmount = 100 * 10 ** 18;
        vm.startPrank(supplier);
        token.setMintFeePercentage(2 * 10 ** 18);
        vm.stopPrank();
        uint256 feeAmount = mintAmount * token.mintFeePercentage() / (100 * 10 ** 18);
        assertEq(token.mintFeePercentage(), 2 * 10 ** 18);

        vm.startPrank(supplier);
        token.mintFromMintSource(verifiedAddress, mintAmount);
        assertEq(token.balanceOf(collector), feeAmount);
        assertEq(token.balanceOf(verifiedAddress), mintAmount - feeAmount);
        uint256 transferAmount = token.balanceOf(verifiedAddress);
        vm.startPrank(supplier);
        token.setTransferFeePercentage(3 * 10 ** 18);
        token.setBurnFeePercentage(1 * 10 ** 18);
        vm.stopPrank();
        assertEq(token.transferFeePercentage(), 3 * 10 ** 18);
        uint256 transferFee = transferAmount * token.transferFeePercentage() / (100 * 10 ** 18);

        vm.startPrank(verifiedAddress);
        token.transfer(verifiedAddress2, transferAmount);
        vm.stopPrank();
        assertEq(token.balanceOf(verifiedAddress), 0);
        assertEq(token.balanceOf(verifiedAddress2), transferAmount - transferFee);
        assertEq(token.balanceOf(collector), feeAmount + transferFee);
    }

    function testFailCheckComplianceRevertWithAddressNotVerified() public {
        uint256 mintAmount = 100 * 10 ** 18;
        vm.startPrank(supplier);
        token.setMintFeePercentage(2 * 10 ** 18);
        token.setTransferFeePercentage(3 * 10 ** 18);
        token.setBurnFeePercentage(4 * 10 ** 18);
        token.setCap(1000 * 10 ** 18);
        vm.stopPrank();
        uint256 feeAmount = mintAmount * token.mintFeePercentage() / (100 * 10 ** 18);
        assertEq(token.mintFeePercentage(), 2 * 10 ** 18);

        vm.startPrank(supplier);
        token.mintFromMintSource(user1, mintAmount);
        assertEq(token.balanceOf(collector), feeAmount);
        assertEq(token.balanceOf(user1), mintAmount - feeAmount);
    }

    function testRemoveComplianceCheck() public {
        //this is for testing only
        privadoIdUniversalVerifier2 = new PrivadoIdUniversalVerifier(universalVerifier);

        vm.startPrank(complianceManager);
        token.addComplianceCheck(privadoIdUniversalVerifier2);
        token.removeComplianceCheck(privadoIdUniversalVerifier2);
        vm.stopPrank();
        uint256 mintAmount = 100 * 10 ** 18;
        vm.startPrank(supplier);
        token.setMintFeePercentage(2 * 10 ** 18);
        token.setTransferFeePercentage(3 * 10 ** 18);
        token.setBurnFeePercentage(4 * 10 ** 18);
        token.setCap(1000 * 10 ** 18);
        vm.stopPrank();
        uint256 feeAmount = mintAmount * token.mintFeePercentage() / (100 * 10 ** 18);
        assertEq(token.mintFeePercentage(), 2 * 10 ** 18);

        vm.startPrank(supplier);
        token.mintFromMintSource(verifiedAddress, mintAmount);
        assertEq(token.balanceOf(collector), feeAmount);
        assertEq(token.balanceOf(verifiedAddress), mintAmount - feeAmount);
    }

    function testFailWhenRemoveExemptAddress() public {
        address[] memory exemptArr = new address[](1);
        exemptArr[0] = address(0);
        vm.startPrank(complianceManager);
        token.removeExemptAddress(exemptArr);
        vm.stopPrank();

        uint256 mintAmount = 100 * 10 ** 18;
        vm.startPrank(supplier);
        token.setMintFeePercentage(2 * 10 ** 18);
        token.setTransferFeePercentage(3 * 10 ** 18);
        token.setBurnFeePercentage(4 * 10 ** 18);
        token.setCap(1000 * 10 ** 18);
        vm.stopPrank();
        uint256 feeAmount = mintAmount * token.mintFeePercentage() / (100 * 10 ** 18);
        assertEq(token.mintFeePercentage(), 2 * 10 ** 18);

        vm.startPrank(supplier);
        token.mintFromMintSource(verifiedAddress, mintAmount);
        assertEq(token.balanceOf(collector), feeAmount);
        assertEq(token.balanceOf(verifiedAddress), mintAmount - feeAmount);
    }

    function testCalculateBurnFeeIsExempt() public {
        uint256 mintAmount = 100 * 10 ** 18;
        vm.startPrank(supplier);
        token.setMintFeePercentage(2 * 10 ** 18);
        token.setTransferFeePercentage(3 * 10 ** 18);
        token.setBurnFeePercentage(4 * 10 ** 18);
        token.setCap(1000 * 10 ** 18);
        vm.stopPrank();
        uint256 feeAmount = mintAmount * token.mintFeePercentage() / (100 * 10 ** 18);
        assertEq(token.mintFeePercentage(), 2 * 10 ** 18);

        vm.startPrank(supplier);
        token.mintFromMintSource(verifiedAddress, mintAmount);
        assertEq(token.balanceOf(collector), feeAmount);
        assertEq(token.balanceOf(verifiedAddress), mintAmount - feeAmount);
        vm.startPrank(collector);
        token.burntoBurnTarget(feeAmount);
        vm.stopPrank();

        assertEq(token.balanceOf(collector), 0);
        assertEq(token.balanceOf(vault), feeAmount);
    }
}
