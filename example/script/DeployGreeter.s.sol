// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";

// Crane factory infrastructure
import {InitDevService} from "@crane/contracts/InitDevService.sol";
import {ICreate3Factory} from "@crane/contracts/interfaces/ICreate3Factory.sol";
import {IDiamondPackageCallBackFactory} from "@crane/contracts/interfaces/IDiamondPackageCallBackFactory.sol";
import {IDiamondFactoryPackage} from "@crane/contracts/interfaces/IDiamondFactoryPackage.sol";
import {BetterEfficientHashLib} from "@crane/contracts/utils/BetterEfficientHashLib.sol";

// Greeter components
import {IGreeter} from "@crane/contracts/test/stubs/greeter/IGreeter.sol";
import {GreeterFacetDiamondFactoryPackage} from "@crane/contracts/test/stubs/greeter/GreeterFacetDiamondFactoryPackage.sol";

/**
 * @title DeployGreeter
 * @notice Deploys a Greeter Diamond using the Crane framework's CREATE3 factory system.
 *
 * This script demonstrates the standard Crane deployment pattern:
 * 1. Initialize the factory infrastructure (Create3Factory + DiamondPackageCallBackFactory)
 * 2. Deploy the GreeterFacetDiamondFactoryPackage (bundles facet + initialization logic)
 * 3. Deploy a Diamond proxy instance with an initial greeting message
 *
 * Usage:
 *   # Start Anvil in another terminal:
 *   anvil
 *
 *   # Deploy to local Anvil:
 *   forge script script/DeployGreeter.s.sol --rpc-url http://127.0.0.1:8545 --broadcast
 */
contract DeployGreeter is Script {
    using BetterEfficientHashLib for bytes;

    // Deployed addresses (logged for frontend integration)
    ICreate3Factory public factory;
    IDiamondPackageCallBackFactory public diamondFactory;
    GreeterFacetDiamondFactoryPackage public greeterPkg;
    IGreeter public greeterDiamond;

    function run() public {
        // Get deployer from environment or use default Anvil account
        uint256 deployerPrivateKey = vm.envOr("PRIVATE_KEY", uint256(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80));
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deployer address:", deployer);
        console.log("");

        vm.startBroadcast(deployerPrivateKey);

        // Step 1: Initialize factory infrastructure
        console.log("=== Step 1: Initialize Factory Infrastructure ===");
        (factory, diamondFactory) = InitDevService.initEnv(deployer);
        console.log("Create3Factory deployed at:", address(factory));
        console.log("DiamondPackageCallBackFactory deployed at:", address(diamondFactory));
        console.log("");

        // Step 2: Deploy the Greeter package
        console.log("=== Step 2: Deploy Greeter Package ===");
        greeterPkg = GreeterFacetDiamondFactoryPackage(
            address(
                factory.deployPackage(
                    type(GreeterFacetDiamondFactoryPackage).creationCode,
                    abi.encode(type(GreeterFacetDiamondFactoryPackage).name)._hash()
                )
            )
        );
        console.log("GreeterFacetDiamondFactoryPackage deployed at:", address(greeterPkg));
        console.log("");

        // Step 3: Deploy a Greeter Diamond instance
        console.log("=== Step 3: Deploy Greeter Diamond Instance ===");
        string memory initialMessage = "Hello from Crane!";
        bytes memory pkgArgs = abi.encode(initialMessage);

        greeterDiamond = IGreeter(
            diamondFactory.deploy(
                IDiamondFactoryPackage(address(greeterPkg)),
                pkgArgs
            )
        );
        console.log("Greeter Diamond deployed at:", address(greeterDiamond));
        console.log("Initial message:", greeterDiamond.getMessage());
        console.log("");

        vm.stopBroadcast();

        // Summary
        console.log("=== Deployment Summary ===");
        console.log("Create3Factory:        ", address(factory));
        console.log("DiamondFactory:        ", address(diamondFactory));
        console.log("GreeterPackage:        ", address(greeterPkg));
        console.log("GreeterDiamond:        ", address(greeterDiamond));
        console.log("");
        console.log("You can now interact with the Greeter Diamond!");
        console.log("Try calling getMessage() or setMessage(string) on:", address(greeterDiamond));
    }
}
