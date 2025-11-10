// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";

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
 * @title HelloDiamondTest
 * @notice Tests the Greeter Diamond deployment and interaction.
 *
 * This test demonstrates:
 * 1. Setting up Crane's factory infrastructure
 * 2. Deploying a Diamond via GreeterFacetDiamondFactoryPackage
 * 3. Interacting with the deployed Diamond (read/write)
 * 4. Verifying events are emitted correctly
 */
contract HelloDiamondTest is Test {
    using BetterEfficientHashLib for bytes;

    ICreate3Factory factory;
    IDiamondPackageCallBackFactory diamondFactory;
    GreeterFacetDiamondFactoryPackage greeterPkg;
    IGreeter greeter;

    address deployer = address(this);
    string constant INITIAL_MESSAGE = "Hello, Diamond!";

    function setUp() public {
        // Initialize factory infrastructure
        (factory, diamondFactory) = InitDevService.initEnv(deployer);

        // Deploy the Greeter package
        greeterPkg = GreeterFacetDiamondFactoryPackage(
            address(
                factory.deployPackage(
                    type(GreeterFacetDiamondFactoryPackage).creationCode,
                    abi.encode(type(GreeterFacetDiamondFactoryPackage).name)._hash()
                )
            )
        );

        // Deploy a Greeter Diamond instance
        bytes memory pkgArgs = abi.encode(INITIAL_MESSAGE);
        greeter = IGreeter(
            diamondFactory.deploy(
                IDiamondFactoryPackage(address(greeterPkg)),
                pkgArgs
            )
        );
    }

    /// @notice Test that the initial message is set correctly
    function test_InitialMessage() public view {
        assertEq(greeter.getMessage(), INITIAL_MESSAGE);
    }

    /// @notice Test that we can update the message
    function test_SetMessage() public {
        string memory newMessage = "Updated message!";

        bool success = greeter.setMessage(newMessage);

        assertTrue(success);
        assertEq(greeter.getMessage(), newMessage);
    }

    /// @notice Test that NewMessage event is emitted when message changes
    function test_SetMessage_EmitsEvent() public {
        string memory newMessage = "Event test message";

        vm.expectEmit(true, true, true, true);
        emit IGreeter.NewMessage(INITIAL_MESSAGE, newMessage);

        greeter.setMessage(newMessage);
    }

    /// @notice Test multiple message updates
    function test_MultipleUpdates() public {
        string[3] memory messages = ["First", "Second", "Third"];

        for (uint256 i = 0; i < messages.length; i++) {
            greeter.setMessage(messages[i]);
            assertEq(greeter.getMessage(), messages[i]);
        }
    }

    /// @notice Fuzz test for message setting
    function testFuzz_SetMessage(string memory message) public {
        greeter.setMessage(message);
        assertEq(greeter.getMessage(), message);
    }

    /// @notice Test that different instances have independent state
    function test_IndependentInstances() public {
        // Deploy a second Greeter Diamond
        string memory secondMessage = "Second Greeter";
        IGreeter greeter2 = IGreeter(
            diamondFactory.deploy(
                IDiamondFactoryPackage(address(greeterPkg)),
                abi.encode(secondMessage)
            )
        );

        // Verify they have different messages
        assertEq(greeter.getMessage(), INITIAL_MESSAGE);
        assertEq(greeter2.getMessage(), secondMessage);

        // Update one, verify the other is unchanged
        greeter.setMessage("Changed first");
        assertEq(greeter.getMessage(), "Changed first");
        assertEq(greeter2.getMessage(), secondMessage);
    }
}
