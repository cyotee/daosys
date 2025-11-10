// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import {IGreeter} from "@crane/contracts/test/stubs/greeter/IGreeter.sol";
import {GreeterLayout, GreeterRepo} from "@crane/contracts/test/stubs/greeter/GreeterRepo.sol";
import {OperableModifiers} from "@crane/contracts/access/operable/OperableModifiers.sol";

/**
 * @title OperableGreeterTarget
 * @notice A Greeter implementation that requires operator authorization to set messages.
 * @dev Demonstrates facet composition with access control.
 *
 * Unlike the basic GreeterTarget, this version restricts setMessage() to:
 * - Global operators (set via setOperator())
 * - Function-specific operators (set via setOperatorFor())
 *
 * getMessage() remains permissionless.
 */
contract OperableGreeterTarget is IGreeter, OperableModifiers {
    /**
     * @notice Get the current greeting message.
     * @return The stored greeting message.
     */
    function getMessage() public view virtual returns (string memory) {
        return GreeterRepo._getMessage();
    }

    /**
     * @notice Set a new greeting message.
     * @dev Restricted to operators only.
     * @param message The new greeting message to store.
     * @return success Boolean indicating success.
     */
    function setMessage(string memory message) public virtual onlyOperator returns (bool) {
        GreeterLayout storage layout = GreeterRepo._layout();
        emit NewMessage(GreeterRepo._getMessage(layout), message);
        GreeterRepo._setMessage(layout, message);
        return true;
    }
}
