// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import {IFacet} from "@crane/contracts/interfaces/IFacet.sol";
import {ICounter} from "./ICounter.sol";
import {CounterTarget} from "./CounterTarget.sol";

contract CounterFacet is CounterTarget, IFacet {
    function facetName() public pure returns (string memory name) {
        return type(CounterFacet).name;
    }

    function facetInterfaces() public pure returns (bytes4[] memory interfaces) {
        interfaces = new bytes4[](1);
        interfaces[0] = type(ICounter).interfaceId;
    }

    function facetFuncs() public pure returns (bytes4[] memory funcs) {
        funcs = new bytes4[](4);
        funcs[0] = ICounter.getNumber.selector;
        funcs[1] = ICounter.setNumber.selector;
        funcs[2] = ICounter.increment.selector;
        funcs[3] = ICounter.decrement.selector;
    }

    function facetMetadata()
        external
        pure
        returns (string memory name, bytes4[] memory interfaces, bytes4[] memory functions)
    {
        name = facetName();
        interfaces = facetInterfaces();
        functions = facetFuncs();
    }
}
