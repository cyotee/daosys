// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";

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

/**
 * @title DeployPermissionedGreeter
 * @notice Deploys a Permissioned Greeter Diamond with access control.
 *
 * This script demonstrates multi-facet Diamond composition:
 * 1. Initialize the factory infrastructure
 * 2. Deploy the PermissionedGreeterDFPkg (bundles Greeter + Operable + MultiStepOwnable)
 * 3. Deploy a Diamond proxy instance with owner and initial message
 *
 * The deployed Diamond supports:
 * - getMessage() - public read
 * - setMessage() - operator-only write
 * - setOperator() - owner-only operator management
 * - owner() - ownership queries
 *
 * Usage:
 *   # Start Anvil in another terminal:
 *   anvil
 *
 *   # Deploy to local Anvil:
 *   forge script script/DeployPermissionedGreeter.s.sol --rpc-url http://127.0.0.1:8545 --broadcast
 */
contract DeployPermissionedGreeter is Script {
    using BetterEfficientHashLib for bytes;

    // Deployed addresses (logged for frontend integration)
    ICreate3Factory public factory;
    IDiamondPackageCallBackFactory public diamondFactory;
    PermissionedGreeterDFPkg public permissionedGreeterPkg;
    address public permissionedGreeterDiamond;

    function run() public {
        // Get deployer from environment or use default Anvil account
        uint256 deployerPrivateKey = vm.envOr(
            "PRIVATE_KEY",
            uint256(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80)
        );
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

        // Step 2: Deploy the PermissionedGreeter package
        console.log("=== Step 2: Deploy PermissionedGreeter Package ===");
        permissionedGreeterPkg = PermissionedGreeterDFPkg(
            address(
                factory.deployPackage(
                    type(PermissionedGreeterDFPkg).creationCode,
                    abi.encode(type(PermissionedGreeterDFPkg).name)._hash()
                )
            )
        );
        console.log("PermissionedGreeterDFPkg deployed at:", address(permissionedGreeterPkg));
        console.log("");

        // Step 3: Deploy a Permissioned Greeter Diamond instance
        console.log("=== Step 3: Deploy Permissioned Greeter Diamond Instance ===");

        // Package arguments: initial message + owner address
        IPermissionedGreeterDFPkg.PkgArgs memory pkgArgs = IPermissionedGreeterDFPkg.PkgArgs({
            initialMessage: "Hello from Permissioned Greeter!",
            owner: deployer
        });
        bytes memory encodedArgs = abi.encode(pkgArgs);

        permissionedGreeterDiamond = diamondFactory.deploy(
            IDiamondFactoryPackage(address(permissionedGreeterPkg)),
            encodedArgs
        );

        console.log("Permissioned Greeter Diamond deployed at:", permissionedGreeterDiamond);
        console.log("");

        // Verify deployment
        console.log("=== Verification ===");
        IGreeter greeter = IGreeter(permissionedGreeterDiamond);
        IOperable operable = IOperable(permissionedGreeterDiamond);
        IMultiStepOwnable ownable = IMultiStepOwnable(permissionedGreeterDiamond);

        console.log("Initial message:", greeter.getMessage());
        console.log("Owner:", ownable.owner());
        console.log("Deployer is operator:", operable.isOperator(deployer));
        console.log("");

        // Make deployer an operator so they can set messages
        console.log("=== Setting up deployer as operator ===");
        operable.setOperator(deployer, true);
        console.log("Deployer is now operator:", operable.isOperator(deployer));
        console.log("");

        // Test setMessage (should work now)
        console.log("=== Testing setMessage ===");
        greeter.setMessage("Updated by operator!");
        console.log("New message:", greeter.getMessage());
        console.log("");

        vm.stopBroadcast();

        // Summary
        console.log("=== Deployment Summary ===");
        console.log("Create3Factory:              ", address(factory));
        console.log("DiamondFactory:              ", address(diamondFactory));
        console.log("PermissionedGreeterPackage:  ", address(permissionedGreeterPkg));
        console.log("PermissionedGreeterDiamond:  ", permissionedGreeterDiamond);
        console.log("");
        console.log("Access Control:");
        console.log("- Owner can add/remove operators via setOperator()");
        console.log("- Operators can update messages via setMessage()");
        console.log("- Anyone can read messages via getMessage()");
        console.log("");
        console.log("Try these commands:");
        console.log("  cast call", permissionedGreeterDiamond, "\"getMessage()\"");
        console.log("  cast call", permissionedGreeterDiamond, "\"owner()\"");
        console.log("  cast call", permissionedGreeterDiamond, "\"isOperator(address)\"", deployer);
    }
}
