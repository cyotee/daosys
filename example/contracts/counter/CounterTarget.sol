// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import {ICounter} from "./ICounter.sol";
import {CounterRepo} from "./CounterRepo.sol";

contract CounterTarget is ICounter {
    function getNumber() public view virtual returns (uint256) {
        return CounterRepo._getNumber();
    }

    function setNumber(uint256 newNumber) public virtual returns (bool) {
        uint256 prev = CounterRepo._getNumber();
        CounterRepo._setNumber(newNumber);
        emit NumberChanged(prev, newNumber);
        return true;
    }

    function increment() public virtual returns (bool) {
        uint256 prev = CounterRepo._getNumber();
        uint256 next = prev + 1;
        CounterRepo._setNumber(next);
        emit NumberChanged(prev, next);
        return true;
    }

    function decrement() public virtual returns (bool) {
        uint256 prev = CounterRepo._getNumber();
        uint256 next = prev - 1;
        CounterRepo._setNumber(next);
        emit NumberChanged(prev, next);
        return true;
    }
}
