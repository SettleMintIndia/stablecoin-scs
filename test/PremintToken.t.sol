//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import { Factory } from "../contracts/Factory.sol";
import { Token } from "../contracts/Token.sol";
import { Registry } from "../contracts/Registry.sol";
import { Pausable } from "../contracts/waltz/extensions/pausable/WaltzPausable.sol";
import { IWaltzComplianceCheck } from "../contracts/waltz/extensions/compliance/checks/PrivadoIdUniversalVerifier.sol";
import { IWaltzErrors } from "../contracts/waltz/interfaces/IWaltzErrors.sol";
import { PrivadoIdUniversalVerifier } from
    "../contracts/waltz/extensions/compliance/checks/PrivadoIdUniversalVerifier.sol";
import { IUniversalVerifier } from
    "../contracts/waltz/extensions/compliance/checks/interfaces/privado-id/IUniversalVerifier.sol";

contract PremintToken is Test {
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
    uint256 preMintAmount = 1000 * 10 ** 18;
    //test address
    address public user1;
    address public user2;
    //    IWaltzComplianceCheck public complianceAddress;

    // Contracts
    Factory public factory;
    Registry public registry;
    PrivadoIdUniversalVerifier public privadoIdUniversalVerifier;
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
            "test", "TST", collector, cap, rolesArr, vault, preMintAmount, address(privadoIdUniversalVerifier)
        );
        vm.stopPrank();
        Registry.Token memory getToken = registry.getTokenBySymbol("TST");
        token = Token(getToken.tokenAddress);
        address[] memory exemptArr = new address[](10);
        exemptArr[0] = freezer;
        exemptArr[1] = pauser;
        exemptArr[2] = supplier;
        exemptArr[3] = burner;
        exemptArr[4] = complianceManager;
        exemptArr[5] = rescuer;
        exemptArr[6] = vault;
        exemptArr[7] = collector;
        exemptArr[8] = address(0);
        exemptArr[9] = address(token);

        vm.startPrank(complianceManager);
        token.addComplianceCheck(privadoIdUniversalVerifier);
        token.addExemptAddress(exemptArr);
        vm.stopPrank();
        (uint256 sigRequestId, uint256 mtpRequestId) = privadoIdUniversalVerifier._requestIds(address(token));
        assertEq(sigRequestId, 1_723_452_139_885);
        assertEq(mtpRequestId, 1_723_452_139_885);
    }

    function testInitialState() public {
        assertEq(token.name(), "test");
        assertEq(token.symbol(), "TST");
        assertEq(token.cap(), cap);
        assertEq(token.feeRecipient(), collector);
        assertEq(token.totalSupply(), preMintAmount);
        assertEq(token.version(), "1.0.0");
    }

    function testPause() public {
        vm.startPrank(pauser);
        token.pause();
        vm.stopPrank();

        assertTrue(token.paused());

        vm.expectRevert(abi.encodeWithSelector(Pausable.EnforcedPause.selector));
        vm.prank(vault);
        token.transfer(verifiedAddress2, 100);
    }

    function testUnpause() public {
        vm.startPrank(pauser);
        token.pause();
        token.unpause();
        vm.stopPrank();

        assertFalse(token.paused());

        vm.prank(vault);
        token.transfer(verifiedAddress, 1);
    }

    function testFrozenAddress() public {
        vm.prank(freezer);
        token.freezeAddress(verifiedAddress);
        assertEq(token.isFrozen(verifiedAddress), true);
    }

    function testFailFrozenAddressWithZeroAddress() public {
        vm.prank(freezer);
        token.freezeAddress(address(0));
    }

    function testBatchFreezeAddress() public {
        address[] memory addressArr = new address[](2);
        addressArr[0] = verifiedAddress;
        addressArr[1] = verifiedAddress2;
        vm.startPrank(freezer);
        token.batchFreezeAddress(addressArr);
        vm.stopPrank();

        assertEq(token.isFrozen(verifiedAddress), true);
        assertEq(token.isFrozen(verifiedAddress2), true);
    }

    function testThawAddress() public {
        vm.prank(freezer);
        token.thawAddress(verifiedAddress);
        assertEq(token.isFrozen(verifiedAddress), false);
    }

    function testBatchThawAddress() public {
        address[] memory addressArr = new address[](2);
        addressArr[0] = verifiedAddress;
        addressArr[1] = verifiedAddress2;
        vm.startPrank(freezer);
        token.batchFreezeAddress(addressArr);
        vm.stopPrank();

        assertEq(token.isFrozen(verifiedAddress), true);
        assertEq(token.isFrozen(verifiedAddress2), true);
        vm.prank(freezer);
        token.batchThawAddress(addressArr);
        assertEq(token.isFrozen(verifiedAddress), false);
        assertEq(token.isFrozen(verifiedAddress2), false);
    }

    function testFreezeTokens() public {
        uint256 amountToMint = 10 * 10 ** 18;
        vm.startPrank(supplier);
        token.mint(verifiedAddress, amountToMint);
        vm.stopPrank();
        assertEq(token.balanceOf(verifiedAddress), amountToMint);

        vm.startPrank(freezer);
        token.freezeTokens(verifiedAddress, amountToMint);
        vm.stopPrank();
        assertEq(token.frozenTokens(verifiedAddress), amountToMint);
        assertEq(token.balanceOf(verifiedAddress), amountToMint);
    }

    function testFailFreezeTokensWithZeroAddress() public {
        uint256 amountToMint = 10 * 10 ** 18;
        vm.startPrank(supplier);
        token.mint(verifiedAddress, amountToMint);
        vm.stopPrank();
        assertEq(token.balanceOf(verifiedAddress), amountToMint);

        vm.startPrank(freezer);
        token.freezeTokens(address(0), amountToMint);
    }

    function testBatchFreezeTokens() public {
        uint256 amountToMint = 10 * 10 ** 18;
        vm.startPrank(supplier);
        token.mint(verifiedAddress, amountToMint / 2);
        token.mint(verifiedAddress2, amountToMint / 2);
        vm.stopPrank();
        assertEq(token.balanceOf(verifiedAddress), amountToMint / 2);
        assertEq(token.balanceOf(verifiedAddress2), amountToMint / 2);
        address[] memory addressArr = new address[](2);
        addressArr[0] = verifiedAddress;
        addressArr[1] = verifiedAddress2;
        uint256[] memory amountArr = new uint256[](2);
        amountArr[0] = amountToMint / 2;
        amountArr[1] = amountToMint / 2;
        vm.startPrank(freezer);
        token.batchFreezeTokens(addressArr, amountArr);
        vm.stopPrank();
        assertEq(token.frozenTokens(verifiedAddress), amountToMint / 2);
        assertEq(token.balanceOf(verifiedAddress), amountToMint / 2);
        assertEq(token.frozenTokens(verifiedAddress2), amountToMint / 2);
        assertEq(token.balanceOf(verifiedAddress2), amountToMint / 2);
    }

    function testFailBatchFreezeTokensRevertWithArrayLengthMismatch() public {
        uint256 amountToMint = 10 * 10 ** 18;
        vm.startPrank(supplier);
        token.mint(verifiedAddress, amountToMint / 2);
        token.mint(verifiedAddress2, amountToMint / 2);
        vm.stopPrank();
        assertEq(token.balanceOf(verifiedAddress), amountToMint / 2);
        assertEq(token.balanceOf(verifiedAddress2), amountToMint / 2);
        address[] memory addressArr = new address[](3);
        addressArr[0] = verifiedAddress;
        addressArr[1] = verifiedAddress2;
        uint256[] memory amountArr = new uint256[](2);
        amountArr[0] = amountToMint / 2;
        amountArr[1] = amountToMint / 2;
        vm.startPrank(freezer);
        token.batchFreezeTokens(addressArr, amountArr);
    }

    function testThawTokens() public {
        uint256 amountToMint = 10 * 10 ** 18;
        vm.startPrank(supplier);
        token.mint(verifiedAddress, amountToMint);
        vm.stopPrank();
        assertEq(token.balanceOf(verifiedAddress), amountToMint);

        vm.startPrank(freezer);
        token.freezeTokens(verifiedAddress, amountToMint);
        vm.stopPrank();
        assertEq(token.frozenTokens(verifiedAddress), amountToMint);
        assertEq(token.balanceOf(verifiedAddress), amountToMint);
        vm.startPrank(freezer);
        token.thawTokens(verifiedAddress, amountToMint);
        vm.stopPrank();
        assertEq(token.frozenTokens(verifiedAddress), 0);
        assertEq(token.balanceOf(verifiedAddress), amountToMint);
    }

    function testFailThawTokensRevertWithAmountExceedsFrozenBalance() public {
        uint256 amountToMint = 10 * 10 ** 18;
        vm.startPrank(supplier);
        token.mint(verifiedAddress, amountToMint);
        vm.stopPrank();
        assertEq(token.balanceOf(verifiedAddress), amountToMint);

        vm.startPrank(freezer);
        token.freezeTokens(verifiedAddress, amountToMint);
        vm.stopPrank();
        assertEq(token.frozenTokens(verifiedAddress), amountToMint);
        assertEq(token.balanceOf(verifiedAddress), amountToMint);
        vm.startPrank(freezer);
        token.thawTokens(verifiedAddress, amountToMint * 2);
    }

    function testBatchThawTokens() public {
        uint256 amountToMint = 10 * 10 ** 18;
        vm.startPrank(supplier);
        token.mint(verifiedAddress, amountToMint / 2);
        token.mint(verifiedAddress2, amountToMint / 2);
        vm.stopPrank();
        assertEq(token.balanceOf(verifiedAddress), amountToMint / 2);
        assertEq(token.balanceOf(verifiedAddress2), amountToMint / 2);
        address[] memory addressArr = new address[](2);
        addressArr[0] = verifiedAddress;
        addressArr[1] = verifiedAddress2;
        uint256[] memory amountArr = new uint256[](2);
        amountArr[0] = amountToMint / 2;
        amountArr[1] = amountToMint / 2;

        vm.startPrank(freezer);
        token.batchFreezeTokens(addressArr, amountArr);
        vm.stopPrank();
        assertEq(token.frozenTokens(verifiedAddress), amountToMint / 2);
        assertEq(token.balanceOf(verifiedAddress), amountToMint / 2);
        assertEq(token.frozenTokens(verifiedAddress2), amountToMint / 2);
        assertEq(token.balanceOf(verifiedAddress2), amountToMint / 2);
        vm.startPrank(freezer);
        token.batchThawTokens(addressArr, amountArr);
        vm.stopPrank();
        assertEq(token.frozenTokens(verifiedAddress), 0);
        assertEq(token.balanceOf(verifiedAddress), amountToMint / 2);
        assertEq(token.frozenTokens(verifiedAddress2), 0);
        assertEq(token.balanceOf(verifiedAddress2), amountToMint / 2);
    }

    function testFailBatchThawTokensRevertWithArrayLengthMismatch() public {
        uint256 amountToMint = 10 * 10 ** 18;
        vm.startPrank(supplier);
        token.mint(verifiedAddress, amountToMint / 2);
        token.mint(verifiedAddress2, amountToMint / 2);
        vm.stopPrank();
        assertEq(token.balanceOf(verifiedAddress), amountToMint / 2);
        assertEq(token.balanceOf(verifiedAddress2), amountToMint / 2);
        address[] memory addressArr = new address[](2);
        addressArr[0] = verifiedAddress;
        addressArr[1] = verifiedAddress2;
        uint256[] memory amountArr = new uint256[](2);
        amountArr[0] = amountToMint / 2;
        amountArr[1] = amountToMint / 2;

        vm.startPrank(freezer);
        token.batchFreezeTokens(addressArr, amountArr);
        vm.stopPrank();
        assertEq(token.frozenTokens(verifiedAddress), amountToMint / 2);
        assertEq(token.balanceOf(verifiedAddress), amountToMint / 2);
        assertEq(token.frozenTokens(verifiedAddress2), amountToMint / 2);
        assertEq(token.balanceOf(verifiedAddress2), amountToMint / 2);
        address[] memory addressArr2 = new address[](3);
        addressArr2[0] = verifiedAddress;
        addressArr2[1] = verifiedAddress2;
        uint256[] memory amountArr2 = new uint256[](2);
        amountArr2[0] = amountToMint / 2;
        amountArr2[1] = amountToMint / 2;
        vm.startPrank(freezer);
        token.batchThawTokens(addressArr2, amountArr2);
    }

    function testSetFeeRecipient() public {
        vm.startPrank(address(factory));
        token.setFeeRecipient(verifiedAddress);
        vm.stopPrank();
        assertEq(token.feeRecipient(), verifiedAddress);
        vm.startPrank(address(factory));
        token.setFeeRecipient(verifiedAddress2);
        vm.stopPrank();
        assertTrue(token._isExempt(verifiedAddress2));
        assertFalse(token._isExempt(verifiedAddress));
    }

    function testMintSource() public {
        vm.prank(address(factory));
        token.setMintSource(vault);
        assertEq(token.mintSource(), vault);
    }

    function testSetBurnTarget() public {
        vm.startPrank(address(factory));
        token.setBurnTarget(vault);
        vm.stopPrank();
        assertEq(token.burnTarget(), vault);
    }

    function testBatchTransfer() public {
        uint256 amountToMint = 10 * 10 ** 18;
        vm.startPrank(supplier);
        token.mint(verifiedAddress, amountToMint);
        //  token.mint(address(token), amountToMint / 5);
        vm.stopPrank();
        assertEq(token.balanceOf(verifiedAddress), amountToMint);
        address[] memory addressArr = new address[](2);
        addressArr[0] = verifiedAddress2;
        addressArr[1] = verifiedAddress2;

        uint256[] memory amountArr = new uint256[](2);
        amountArr[0] = amountToMint / 2;
        amountArr[1] = amountToMint / 2;

        vm.startPrank(verifiedAddress);
        token.batchTransfer(addressArr, amountArr);
        vm.stopPrank();
        assertEq(token.balanceOf(verifiedAddress), 0);
        assertEq(token.balanceOf(verifiedAddress2), amountToMint);
    }

    function testFailBatchTransfer() public {
        uint256 amountToMint = 10 * 10 ** 18;
        vm.startPrank(supplier);
        token.mint(verifiedAddress, amountToMint);
        vm.stopPrank();

        address[] memory addressArr = new address[](3);
        addressArr[1] = verifiedAddress2;
        uint256[] memory amountArr = new uint256[](2);
        amountArr[0] = amountToMint / 2;
        amountArr[1] = amountToMint / 2;

        vm.startPrank(verifiedAddress);
        token.batchTransfer(addressArr, amountArr);
    }

    function testFailBatchTransferFrom() public {
        uint256 amountToMint = 10 * 10 ** 18;
        vm.startPrank(supplier);
        token.mint(verifiedAddress, amountToMint);
        //  token.mint(address(token), amountToMint / 5);
        vm.stopPrank();

        vm.startPrank(verifiedAddress);
        token.approve(supplier, token.balanceOf(verifiedAddress));
        vm.stopPrank();
        assertEq(token.balanceOf(verifiedAddress), amountToMint);

        address[] memory fromAddressArr = new address[](1);
        fromAddressArr[0] = verifiedAddress;

        address[] memory toAddressArr = new address[](2);
        toAddressArr[0] = verifiedAddress2;
        toAddressArr[1] = verifiedAddress2;

        uint256[] memory amountArr = new uint256[](2);
        amountArr[0] = amountToMint / 2;
        amountArr[1] = amountToMint / 2;

        vm.startPrank(supplier);
        token.batchTransferFrom(fromAddressArr, toAddressArr, amountArr);
        vm.stopPrank();
        assertEq(token.balanceOf(verifiedAddress), 0);
        assertEq(token.balanceOf(verifiedAddress2), amountToMint);
    }

    function testBatchTransferFrom() public {
        uint256 amountToMint = 10 * 10 ** 18;
        vm.startPrank(supplier);
        token.mint(verifiedAddress, amountToMint);
        //  token.mint(address(token), amountToMint / 5);
        vm.stopPrank();

        vm.startPrank(verifiedAddress);
        token.approve(supplier, token.balanceOf(verifiedAddress));
        vm.stopPrank();
        assertEq(token.balanceOf(verifiedAddress), amountToMint);

        address[] memory fromAddressArr = new address[](2);
        fromAddressArr[0] = verifiedAddress;
        fromAddressArr[1] = verifiedAddress;

        address[] memory toAddressArr = new address[](2);
        toAddressArr[0] = verifiedAddress2;
        toAddressArr[1] = verifiedAddress2;

        uint256[] memory amountArr = new uint256[](2);
        amountArr[0] = amountToMint / 2;
        amountArr[1] = amountToMint / 2;

        vm.startPrank(supplier);
        token.batchTransferFrom(fromAddressArr, toAddressArr, amountArr);
        vm.stopPrank();
        assertEq(token.balanceOf(verifiedAddress), 0);
        assertEq(token.balanceOf(verifiedAddress2), amountToMint);
    }

    // function testBatchTransferFromRevertsOnFailure() public {
    //     uint256 amountToMint = 10 * 10 ** 18;
    //     vm.startPrank(supplier);
    //     token.mint(verifiedAddress, amountToMint);
    //     //  token.mint(address(token), amountToMint / 5);
    //     vm.stopPrank();

    //     vm.startPrank(verifiedAddress);
    //     token.approve(supplier, token.balanceOf(verifiedAddress));
    //     vm.stopPrank();
    //     assertEq(token.balanceOf(verifiedAddress), amountToMint);

    //     address[] memory fromAddressArr = new address[](2);
    //     fromAddressArr[0] = verifiedAddress;
    //     fromAddressArr[1] = verifiedAddress;

    //     address[] memory toAddressArr = new address[](2);
    //     toAddressArr[0] = verifiedAddress2;
    //     toAddressArr[1] = verifiedAddress2;

    //     uint256[] memory amountArr = new uint256[](2);
    //     amountArr[0] = amountToMint / 2;
    //     amountArr[1] = amountToMint / 2;

    //     vm.mockCall(
    //         address(token),
    //         abi.encodeWithSelector(
    //             token.batchTransferFrom.selector, fromAddressArr[0], toAddressArr[0], amountArr[0]
    //         ),
    //         abi.encodeWithSelector(IWaltzErrors.TransferFromFailed.selector, fromAddressArr[0], toAddressArr[0],
    // amountArr[0])
    //     );
    //     vm.expectRevert(
    //         abi.encodeWithSelector(IWaltzErrors.TransferFromFailed.selector, fromAddressArr[0], toAddressArr[0],
    // amountArr[0])
    //     );
    //     token.batchTransferFrom(fromAddressArr, toAddressArr, amountArr);

    //         bytes memory customError = abi.encodeWithSelector(TestError.selector, "ERROR_MESSAGE");
    // vm.mockCallRevert(
    //     address(0),
    //     abi.encodeWithSelector(MyToken.balanceOf.selector, address(1)),
    //     customError
    // );
    // vm.expectRevert(customError);
    // IERC20(address(0)).balanceOf(address(1));
    // token.batchTransferFrom(fromAddressArr, toAddressArr, amountArr);
    // vm.stopPrank();
    // assertEq(token.balanceOf(verifiedAddress), 0);
    // assertEq(token.balanceOf(verifiedAddress2), amountToMint);
    // }

    //pre mint
    function testMintWithZeroFee() public {
        uint256 amountToMint = 10 * 10 ** 18;
        vm.startPrank(supplier);
        token.mint(verifiedAddress, amountToMint);
        vm.stopPrank();
        assertEq(token.balanceOf(verifiedAddress), amountToMint);
    }

    function testFailPremintMoreThanCap() public {
        vm.startPrank(supplier);
        token.mint(vault, cap + preMintAmount);
    }

    // issue from vault -> verifiedAddress
    function testTransferForIssuanceWithZeroFee() public {
        vm.prank(address(factory));
        token.setMintSource(vault);
        assertEq(token.mintSource(), vault);

        uint256 mintAmount = 100 * 10 ** 18;
        vm.startPrank(vault);
        token.transfer(verifiedAddress, mintAmount);
        vm.stopPrank();
        assertEq(token.balanceOf(collector), 0);
        assertEq(token.balanceOf(verifiedAddress), mintAmount);
    }

    // issue from vault -> verifiedAddress with 0 fee
    function testTransferForIssuance() public {
        vm.prank(address(factory));
        token.setMintSource(vault);
        assertEq(token.mintSource(), vault);

        uint256 mintAmount = 100 * 10 ** 18;
        vm.startPrank(supplier);
        token.setMintFeePercentage(2 * 10 ** 18);
        vm.stopPrank();
        uint256 feeAmount = mintAmount * token.mintFeePercentage() / (100 * 10 ** 18);
        assertEq(token.mintFeePercentage(), 2 * 10 ** 18);
        vm.startPrank(vault);
        token.transfer(verifiedAddress, mintAmount);
        vm.stopPrank();
        assertEq(token.balanceOf(collector), feeAmount);
        assertEq(token.balanceOf(verifiedAddress), mintAmount - feeAmount);
    }
    // issue from vault -> verifiedAddress with 0 fee

    function testBurnFromColletor() public {
        vm.prank(address(factory));
        token.setMintSource(vault);
        assertEq(token.mintSource(), vault);

        uint256 mintAmount = 100 * 10 ** 18;
        vm.startPrank(supplier);
        token.setMintFeePercentage(2 * 10 ** 18);
        vm.stopPrank();
        uint256 feeAmount = mintAmount * token.mintFeePercentage() / (100 * 10 ** 18);
        assertEq(token.mintFeePercentage(), 2 * 10 ** 18);
        vm.startPrank(vault);
        token.transfer(verifiedAddress, mintAmount);
        vm.stopPrank();
        assertEq(token.balanceOf(collector), feeAmount);
        assertEq(token.balanceOf(verifiedAddress), mintAmount - feeAmount);

        vm.startPrank(address(factory));
        token.setAddressExemptStatus(burner, true);
        vm.stopPrank();
        assertTrue(token._isExempt(burner));

        vm.startPrank(burner);
        token.burnFrom(collector, feeAmount);
    }

    // redeem user -> vault
    function testTransferForRedemption() public {
        vm.prank(address(factory));
        token.setMintSource(vault);
        assertEq(token.mintSource(), vault);

        uint256 mintAmount = 100 * 10 ** 18;
        vm.startPrank(supplier);
        token.setMintFeePercentage(2 * 10 ** 18);
        vm.stopPrank();
        uint256 feeAmount = mintAmount * token.mintFeePercentage() / (100 * 10 ** 18);
        assertEq(token.mintFeePercentage(), 2 * 10 ** 18);
        vm.startPrank(vault);
        token.transfer(verifiedAddress, mintAmount);
        vm.stopPrank();
        assertEq(token.balanceOf(verifiedAddress), mintAmount - feeAmount);
        assertEq(token.balanceOf(collector), feeAmount);
        assertEq(token.balanceOf(vault), preMintAmount - mintAmount);

        uint256 redeemAmount = token.balanceOf(verifiedAddress);
        vm.startPrank(supplier);
        token.setBurnFeePercentage(2 * 10 ** 18);
        vm.stopPrank();
        assertEq(token.burnFeePercentage(), 2 * 10 ** 18);
        uint256 redeemFee = redeemAmount * token.burnFeePercentage() / (100 * 10 ** 18);

        vm.prank(address(factory));
        token.setBurnTarget(vault);
        vm.stopPrank();
        assertEq(token.burnTarget(), vault);
        //redeeming
        vm.startPrank(verifiedAddress);
        token.transfer(vault, redeemAmount);
        vm.stopPrank();
        assertEq(token.balanceOf(verifiedAddress), 0);
        assertEq(token.balanceOf(collector), feeAmount + redeemFee);
        assertEq(token.balanceOf(vault), preMintAmount - mintAmount + redeemAmount - redeemFee);
    }

    // redeem user -> vault
    function testTransferForRedemptionWithZeroFee() public {
        vm.prank(address(factory));
        token.setMintSource(vault);
        assertEq(token.mintSource(), vault);

        uint256 mintAmount = 100 * 10 ** 18;
        vm.startPrank(supplier);
        token.setMintFeePercentage(2 * 10 ** 18);
        vm.stopPrank();
        uint256 feeAmount = mintAmount * token.mintFeePercentage() / (100 * 10 ** 18);
        assertEq(token.mintFeePercentage(), 2 * 10 ** 18);
        vm.startPrank(vault);
        token.transfer(verifiedAddress, mintAmount);
        vm.stopPrank();
        assertEq(token.balanceOf(verifiedAddress), mintAmount - feeAmount);
        assertEq(token.balanceOf(collector), feeAmount);
        assertEq(token.balanceOf(vault), preMintAmount - mintAmount);

        uint256 redeemAmount = token.balanceOf(verifiedAddress);

        vm.prank(address(factory));
        token.setBurnTarget(vault);
        vm.stopPrank();
        assertEq(token.burnTarget(), vault);
        //redeeming
        vm.startPrank(verifiedAddress);
        token.transfer(vault, redeemAmount);
        vm.stopPrank();
        assertEq(token.balanceOf(verifiedAddress), 0);
        assertEq(token.balanceOf(collector), feeAmount);
        assertEq(token.balanceOf(vault), preMintAmount - mintAmount + redeemAmount);
    }

    // transfer user -> verifiedAddress2
    function testTransferForTransferFeeWithZeroFee() public {
        vm.prank(address(factory));
        token.setMintSource(vault);
        assertEq(token.mintSource(), vault);

        uint256 mintAmount = 100 * 10 ** 18;
        vm.startPrank(supplier);
        token.setMintFeePercentage(2 * 10 ** 18);
        vm.stopPrank();
        uint256 feeAmount = mintAmount * token.mintFeePercentage() / (100 * 10 ** 18);
        assertEq(token.mintFeePercentage(), 2 * 10 ** 18);
        vm.startPrank(vault);
        token.transfer(verifiedAddress, mintAmount);
        vm.stopPrank();
        assertEq(token.balanceOf(verifiedAddress), mintAmount - feeAmount);
        assertEq(token.balanceOf(collector), feeAmount);
        assertEq(token.balanceOf(vault), preMintAmount - mintAmount);

        uint256 transferAmount = token.balanceOf(verifiedAddress);

        //transferring
        vm.startPrank(verifiedAddress);
        token.transfer(verifiedAddress2, transferAmount);
        vm.stopPrank();
        assertEq(token.balanceOf(verifiedAddress), 0);
        assertEq(token.balanceOf(collector), feeAmount);
        assertEq(token.balanceOf(verifiedAddress2), transferAmount);
    }

    // transfer user -> verifiedAddress2
    function testFailTransferForNotExceedingThawedBalance() public {
        vm.prank(address(factory));
        token.setMintSource(vault);
        assertEq(token.mintSource(), vault);

        uint256 mintAmount = 100 * 10 ** 18;
        vm.startPrank(supplier);
        token.setMintFeePercentage(2 * 10 ** 18);
        vm.stopPrank();
        uint256 feeAmount = mintAmount * token.mintFeePercentage() / (100 * 10 ** 18);
        assertEq(token.mintFeePercentage(), 2 * 10 ** 18);
        vm.startPrank(vault);
        token.transfer(verifiedAddress, mintAmount);
        vm.stopPrank();
        assertEq(token.balanceOf(verifiedAddress), mintAmount - feeAmount);
        assertEq(token.balanceOf(collector), feeAmount);
        assertEq(token.balanceOf(vault), preMintAmount - mintAmount);

        uint256 transferAmount = token.balanceOf(verifiedAddress);

        vm.startPrank(freezer);
        token.freezeTokens(verifiedAddress, transferAmount);
        vm.stopPrank();

        //transferring
        vm.startPrank(verifiedAddress);
        token.transfer(verifiedAddress2, transferAmount);
        vm.stopPrank();
    }
    // transfer user -> verifiedAddress2

    function testFailTransferForWhenNotThawed() public {
        vm.prank(address(factory));
        token.setMintSource(vault);
        assertEq(token.mintSource(), vault);

        uint256 mintAmount = 100 * 10 ** 18;
        vm.startPrank(supplier);
        token.setMintFeePercentage(2 * 10 ** 18);
        vm.stopPrank();
        uint256 feeAmount = mintAmount * token.mintFeePercentage() / (100 * 10 ** 18);
        assertEq(token.mintFeePercentage(), 2 * 10 ** 18);
        vm.startPrank(vault);
        token.transfer(verifiedAddress, mintAmount);
        vm.stopPrank();
        assertEq(token.balanceOf(verifiedAddress), mintAmount - feeAmount);
        assertEq(token.balanceOf(collector), feeAmount);
        assertEq(token.balanceOf(vault), preMintAmount - mintAmount);

        uint256 transferAmount = token.balanceOf(verifiedAddress);

        vm.startPrank(freezer);
        token.freezeAddress(verifiedAddress);
        vm.stopPrank();

        //transferring
        vm.startPrank(verifiedAddress);
        token.transfer(verifiedAddress2, transferAmount);
        vm.stopPrank();
    }

    // transfer user -> verifiedAddress2
    function testTransferForTransferFee() public {
        vm.prank(address(factory));
        token.setMintSource(vault);
        assertEq(token.mintSource(), vault);

        uint256 mintAmount = 100 * 10 ** 18;
        vm.startPrank(supplier);
        token.setMintFeePercentage(2 * 10 ** 18);
        vm.stopPrank();
        uint256 feeAmount = mintAmount * token.mintFeePercentage() / (100 * 10 ** 18);
        assertEq(token.mintFeePercentage(), 2 * 10 ** 18);
        vm.startPrank(vault);
        token.transfer(verifiedAddress, mintAmount);
        vm.stopPrank();
        assertEq(token.balanceOf(verifiedAddress), mintAmount - feeAmount);
        assertEq(token.balanceOf(collector), feeAmount);
        assertEq(token.balanceOf(vault), preMintAmount - mintAmount);

        uint256 transferAmount = token.balanceOf(verifiedAddress);
        vm.startPrank(supplier);
        token.setTransferFeePercentage(3 * 10 ** 18);
        vm.stopPrank();
        assertEq(token.transferFeePercentage(), 3 * 10 ** 18);
        uint256 transferFee = transferAmount * token.transferFeePercentage() / (100 * 10 ** 18);

        //transferring
        vm.startPrank(verifiedAddress);
        token.transfer(verifiedAddress2, transferAmount);
        vm.stopPrank();
        assertEq(token.balanceOf(verifiedAddress), 0);
        assertEq(token.balanceOf(collector), feeAmount + transferFee);
        assertEq(token.balanceOf(verifiedAddress2), transferAmount - transferFee);
    }

    function testSetRescueVault() public {
        assertEq(token.rescueRecipient(), collector);
        vm.startPrank(rescuer);
        token.setRescueVault(vault);
        vm.stopPrank();
        assertEq(token.rescueRecipient(), vault);
    }

    function testFailSetRescueVaultRevertWithZeroAddressNotAllowed() public {
        assertEq(token.rescueRecipient(), collector);
        vm.startPrank(rescuer);
        token.setRescueVault(address(0));
    }

    function testRescue() public {
        assertEq(token.rescueRecipient(), collector);
        assertEq(token.balanceOf(collector), 0);
        uint256 mintAmount = 100 * 10 ** 18;
        vm.startPrank(vault);
        token.transfer(address(token), mintAmount);
        vm.stopPrank();
        assertEq(token.balanceOf(address(token)), mintAmount);
        vm.startPrank(rescuer);
        token.rescue(address(token));
        vm.stopPrank();
        assertEq(token.balanceOf(collector), mintAmount);
        assertEq(token.balanceOf(address(token)), 0);
    }

    function testRescueForNativeToken() public {
        vm.deal(address(token), 10 ether);
        assertEq(address(token).balance, 10 ether);
        vm.startPrank(rescuer);
        token.rescue(address(0));
        vm.stopPrank();
        assertGt(address(collector).balance, 9 ether);
        assertEq(address(token).balance, 0);
    }

    function testSetCap() public {
        assertEq(token.cap(), cap);
        uint256 newCap = 500_000_000 * 10 ** 18;
        vm.startPrank(supplier);
        token.setCap(newCap);
        vm.stopPrank();
        assertEq(token.cap(), newCap);
    }

    function testSetCapChange() public {
        assertEq(token.cap(), cap);
        uint256 newCap = 500_000_000 * 10 ** 18;
        vm.startPrank(supplier);
        token.setCap(newCap);
        vm.stopPrank();
        assertEq(token.cap(), newCap);
        uint256 newSetCap = 500_000 * 10 ** 18;
        vm.startPrank(supplier);
        token.setCap(newSetCap);
        vm.stopPrank();
        assertEq(token.cap(), newSetCap);
    }

    function testFailSetCap() public {
        //uint256 cap = 100_000_000 * 10 ** 18;
        assertEq(token.cap(), cap);
        uint256 newCap = 500_000_000 * 10 ** 18;
        vm.startPrank(supplier);
        token.setCap(newCap);
        vm.stopPrank();
        assertEq(token.cap(), newCap);
        uint256 amountToMint = 100_000 * 10 ** 18;
        vm.startPrank(supplier);
        token.mint(verifiedAddress, amountToMint);
        vm.stopPrank();
        assertEq(token.balanceOf(verifiedAddress), amountToMint);
        assertEq(token.cap(), newCap);
        uint256 newSetCap = 500 * 10 ** 18;
        vm.startPrank(supplier);
        token.setCap(newSetCap);
        vm.stopPrank();
    }

    function testBurn() public {
        uint256 amountToMint = 10 * 10 ** 18;
        vm.startPrank(supplier);
        token.mint(burner, amountToMint);
        vm.stopPrank();
        assertEq(token.balanceOf(burner), amountToMint);
        vm.startPrank(burner);
        token.burn(amountToMint);
        vm.stopPrank();
        assertEq(token.balanceOf(burner), 0);
    }

    function testBurnFrom() public {
        uint256 amountToMint = 10 * 10 ** 18;
        vm.startPrank(supplier);
        token.mint(verifiedAddress, amountToMint);
        vm.stopPrank();
        assertEq(token.balanceOf(verifiedAddress), amountToMint);
        vm.startPrank(burner);
        token.burnFrom(verifiedAddress, amountToMint);
        vm.stopPrank();
        assertEq(token.balanceOf(verifiedAddress), 0);
    }

    function testBatchBurnFrom() public {
        uint256 amountToMint = 10 * 10 ** 18;
        vm.startPrank(supplier);
        token.mint(verifiedAddress, amountToMint / 2);
        token.mint(verifiedAddress2, amountToMint / 2);
        vm.stopPrank();
        assertEq(token.balanceOf(verifiedAddress), amountToMint / 2);
        assertEq(token.balanceOf(verifiedAddress2), amountToMint / 2);
        uint256[] memory amountArr = new uint256[](2);
        amountArr[0] = amountToMint / 2;
        amountArr[1] = amountToMint / 2;
        address[] memory addressArr = new address[](2);
        addressArr[0] = verifiedAddress;
        addressArr[1] = verifiedAddress2;

        vm.startPrank(burner);
        token.batchBurnFrom(addressArr, amountArr);
        vm.stopPrank();
        assertEq(token.balanceOf(verifiedAddress), 0);
        assertEq(token.balanceOf(verifiedAddress2), 0);
    }

    function testFailBatchBurnFrom() public {
        uint256 amountToMint = 10 * 10 ** 18;
        vm.startPrank(supplier);
        token.mint(verifiedAddress, amountToMint / 2);
        token.mint(verifiedAddress2, amountToMint / 2);
        vm.stopPrank();
        assertEq(token.balanceOf(verifiedAddress), amountToMint / 2);
        assertEq(token.balanceOf(verifiedAddress2), amountToMint / 2);
        uint256[] memory amountArr = new uint256[](1);
        amountArr[0] = amountToMint / 2;
        address[] memory addressArr = new address[](2);
        addressArr[0] = verifiedAddress;
        addressArr[1] = verifiedAddress2;

        vm.startPrank(burner);
        token.batchBurnFrom(addressArr, amountArr);
        vm.stopPrank();
        assertEq(token.balanceOf(verifiedAddress), 0);
        assertEq(token.balanceOf(verifiedAddress2), 0);
    }

    function testFailSetMintFeePercentage() public {
        vm.startPrank(supplier);
        token.setMintFeePercentage(200 * 10 ** 18);
        vm.stopPrank();
    }

    function testFailSetTransferFeePercentage() public {
        vm.startPrank(supplier);
        token.setTransferFeePercentage(300 * 10 ** 18);
        vm.stopPrank();
    }

    function testFailSetBurnFeePercentage() public {
        vm.startPrank(supplier);
        token.setBurnFeePercentage(400 * 10 ** 18);
        vm.stopPrank();
    }

    function testSetAddressExemptStatus() public {
        assertTrue(token._isExempt(address(token)));
        assertTrue(token._isExempt(collector));
        vm.startPrank(address(factory));
        token.setAddressExemptStatus(supplier, true);
        vm.stopPrank();
        assertTrue(token._isExempt(supplier));
    }

    function testFailSetAddressExemptStatus() public {
        assertTrue(token._isExempt(address(token)));
        assertTrue(token._isExempt(collector));
        vm.startPrank(address(factory));
        token.setAddressExemptStatus(address(0), true);
        vm.stopPrank();
    }

    function testSupportsInterface() public {
        assertTrue(token.supportsInterface(0x01ffc9a7));
    }
}
