// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";

import {InitDevService} from "@crane/contracts/InitDevService.sol";
import {ICreate3Factory} from "@crane/contracts/interfaces/ICreate3Factory.sol";
import {IDiamondPackageCallBackFactory} from "@crane/contracts/interfaces/IDiamondPackageCallBackFactory.sol";
import {IDiamondFactoryPackage} from "@crane/contracts/interfaces/IDiamondFactoryPackage.sol";
import {BetterEfficientHashLib} from "@crane/contracts/utils/BetterEfficientHashLib.sol";

import {ICounter} from "../contracts/counter/ICounter.sol";
import {CounterDFPkg, ICounterDFPkg} from "../contracts/counter/CounterDFPkg.sol";

contract CounterDiamondTest is Test {
    using BetterEfficientHashLib for bytes;

    ICreate3Factory factory;
    IDiamondPackageCallBackFactory diamondFactory;
    CounterDFPkg counterPkg;

    ICounter counter;

    function setUp() public {
        (factory, diamondFactory) = InitDevService.initEnv(address(this));

        counterPkg = CounterDFPkg(
            address(
                factory.deployPackage(
                    type(CounterDFPkg).creationCode,
                    abi.encode(type(CounterDFPkg).name)._hash()
                )
            )
        );

        ICounterDFPkg.PkgArgs memory pkgArgs = ICounterDFPkg.PkgArgs({initialNumber: 7});
        counter = ICounter(diamondFactory.deploy(IDiamondFactoryPackage(address(counterPkg)), abi.encode(pkgArgs)));
    }

    function test_InitialValue() public view {
        assertEq(counter.getNumber(), 7);
    }

    function test_Increment() public {
        counter.increment();
        assertEq(counter.getNumber(), 8);
    }

    function test_Decrement() public {
        counter.decrement();
        assertEq(counter.getNumber(), 6);
    }

    function test_SetNumber() public {
        assertTrue(counter.setNumber(123));
        assertEq(counter.getNumber(), 123);
    }

    function test_IndependentInstances() public {
        ICounterDFPkg.PkgArgs memory pkgArgs = ICounterDFPkg.PkgArgs({initialNumber: 1});
        ICounter counter2 =
            ICounter(diamondFactory.deploy(IDiamondFactoryPackage(address(counterPkg)), abi.encode(pkgArgs)));

        assertEq(counter.getNumber(), 7);
        assertEq(counter2.getNumber(), 1);

        counter.increment();
        assertEq(counter.getNumber(), 8);
        assertEq(counter2.getNumber(), 1);
    }
}
