// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";

// Crane factory infrastructure
import {InitDevService} from "@crane/contracts/InitDevService.sol";
import {ICreate3Factory} from "@crane/contracts/interfaces/ICreate3Factory.sol";
import {IDiamondPackageCallBackFactory} from "@crane/contracts/interfaces/IDiamondPackageCallBackFactory.sol";
import {IDiamondFactoryPackage} from "@crane/contracts/interfaces/IDiamondFactoryPackage.sol";
import {BetterEfficientHashLib} from "@crane/contracts/utils/BetterEfficientHashLib.sol";

// Permissioned Greeter components
import {IGreeter} from "@crane/contracts/test/stubs/greeter/IGreeter.sol";
import {IOperable} from "@crane/contracts/interfaces/IOperable.sol";
import {IMultiStepOwnable} from "@crane/contracts/interfaces/IMultiStepOwnable.sol";

import {PermissionedGreeterDFPkg, IPermissionedGreeterDFPkg} from "../contracts/permissioned-greeter/PermissionedGreeterDFPkg.sol";

contract PermissionedGreeterTest is Test {
    using BetterEfficientHashLib for bytes;

    ICreate3Factory factory;
    IDiamondPackageCallBackFactory diamondFactory;
    PermissionedGreeterDFPkg permissionedGreeterPkg;

    IGreeter greeter;
    IOperable operable;
    IMultiStepOwnable ownable;

    address owner = address(this);
    address operator = address(0xBEEF);
    address stranger = address(0xCAFE);

    string constant INITIAL_MESSAGE = "Hello from Permissioned Greeter!";

    function setUp() public {
        (factory, diamondFactory) = InitDevService.initEnv(owner);

        permissionedGreeterPkg = PermissionedGreeterDFPkg(
            address(
                factory.deployPackage(
                    type(PermissionedGreeterDFPkg).creationCode,
                    abi.encode(type(PermissionedGreeterDFPkg).name)._hash()
                )
            )
        );

        IPermissionedGreeterDFPkg.PkgArgs memory pkgArgs = IPermissionedGreeterDFPkg.PkgArgs({
            initialMessage: INITIAL_MESSAGE,
            owner: owner
        });

        address diamond =
            diamondFactory.deploy(IDiamondFactoryPackage(address(permissionedGreeterPkg)), abi.encode(pkgArgs));

        greeter = IGreeter(diamond);
        operable = IOperable(diamond);
        ownable = IMultiStepOwnable(diamond);
    }

    function test_InitialState() public view {
        assertEq(greeter.getMessage(), INITIAL_MESSAGE);
        assertEq(ownable.owner(), owner);
        assertFalse(operable.isOperator(owner));
    }

    function test_SetMessage_Reverts_WhenNotOperator() public {
        vm.expectRevert(abi.encodeWithSelector(IOperable.NotOperator.selector, owner));
        greeter.setMessage("nope");
    }

    function test_SetOperator_Reverts_WhenNotOwner() public {
        vm.prank(stranger);
        vm.expectRevert(abi.encodeWithSelector(IMultiStepOwnable.NotOwner.selector, stranger));
        operable.setOperator(operator, true);
    }

    function test_OwnerCanSetOperator_ThenOperatorCanSetMessage() public {
        assertTrue(operable.setOperator(operator, true));
        assertTrue(operable.isOperator(operator));

        vm.prank(operator);
        assertTrue(greeter.setMessage("Updated by operator!"));
        assertEq(greeter.getMessage(), "Updated by operator!");
    }

    function test_OwnershipTransfer_ChangesOperatorAdmin() public {
        address newOwner = address(0xD00D);

        ownable.initiateOwnershipTransfer(newOwner);
        ownable.confirmOwnershipTransfer(newOwner);

        vm.prank(newOwner);
        ownable.acceptOwnershipTransfer();

        assertEq(ownable.owner(), newOwner);

        // Old owner can no longer manage operators.
        vm.expectRevert(abi.encodeWithSelector(IMultiStepOwnable.NotOwner.selector, owner));
        operable.setOperator(operator, true);

        // New owner can.
        vm.prank(newOwner);
        assertTrue(operable.setOperator(operator, true));
        assertTrue(operable.isOperator(operator));
    }
}
