// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";

import {InitDevService} from "@crane/contracts/InitDevService.sol";
import {ICreate3Factory} from "@crane/contracts/interfaces/ICreate3Factory.sol";
import {IDiamondPackageCallBackFactory} from "@crane/contracts/interfaces/IDiamondPackageCallBackFactory.sol";
import {IDiamondFactoryPackage} from "@crane/contracts/interfaces/IDiamondFactoryPackage.sol";
import {BetterEfficientHashLib} from "@crane/contracts/utils/BetterEfficientHashLib.sol";

import {ICounter} from "../contracts/counter/ICounter.sol";
import {CounterDFPkg, ICounterDFPkg} from "../contracts/counter/CounterDFPkg.sol";

contract DeployCounter is Script {
    using BetterEfficientHashLib for bytes;

    ICreate3Factory public factory;
    IDiamondPackageCallBackFactory public diamondFactory;
    CounterDFPkg public counterPkg;
    address public counterDiamond;

    function run() public {
        uint256 deployerPrivateKey = vm.envOr(
            "PRIVATE_KEY",
            uint256(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80)
        );
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deployer address:", deployer);
        console.log("");

        vm.startBroadcast(deployerPrivateKey);

        (factory, diamondFactory) = InitDevService.initEnv(deployer);

        counterPkg = CounterDFPkg(
            address(
                factory.deployPackage(
                    type(CounterDFPkg).creationCode,
                    abi.encode(type(CounterDFPkg).name)._hash()
                )
            )
        );

        ICounterDFPkg.PkgArgs memory pkgArgs = ICounterDFPkg.PkgArgs({initialNumber: 0});
        counterDiamond = diamondFactory.deploy(IDiamondFactoryPackage(address(counterPkg)), abi.encode(pkgArgs));

        ICounter counter = ICounter(counterDiamond);
        console.log("Counter Diamond deployed at:", counterDiamond);
        console.log("Initial number:", counter.getNumber());

        vm.stopBroadcast();
    }
}
