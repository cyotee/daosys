// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import {IGreeter} from "@crane/contracts/test/stubs/greeter/IGreeter.sol";
import {OperableGreeterTarget} from "./OperableGreeterTarget.sol";
import {IFacet} from "@crane/contracts/interfaces/IFacet.sol";

/**
 * @title OperableGreeterFacet
 * @notice Diamond facet for the Operable Greeter - requires operator authorization to set messages.
 * @dev Extends OperableGreeterTarget and implements IFacet for Diamond integration.
 *
 * This facet should be combined with OperableFacet in a Diamond proxy:
 * - OperableFacet: Provides operator management (isOperator, setOperator, etc.)
 * - OperableGreeterFacet: Provides greeting functionality with operator-restricted writes
 */
contract OperableGreeterFacet is OperableGreeterTarget, IFacet {
    /**
     * @inheritdoc IFacet
     */
    function facetName() public pure returns (string memory name) {
        return type(OperableGreeterFacet).name;
    }

    /**
     * @inheritdoc IFacet
     */
    function facetInterfaces() public pure virtual returns (bytes4[] memory interfaces) {
        interfaces = new bytes4[](1);
        interfaces[0] = type(IGreeter).interfaceId;
    }

    /**
     * @inheritdoc IFacet
     */
    function facetFuncs() public pure virtual returns (bytes4[] memory funcs) {
        funcs = new bytes4[](2);
        funcs[0] = IGreeter.getMessage.selector;
        funcs[1] = IGreeter.setMessage.selector;
    }

    /**
     * @inheritdoc IFacet
     */
    function facetMetadata()
        external
        pure
        virtual
        returns (string memory name, bytes4[] memory interfaces, bytes4[] memory functions)
    {
        name = facetName();
        interfaces = facetInterfaces();
        functions = facetFuncs();
    }
}
