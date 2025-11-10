// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

interface ICounter {
    event NumberChanged(uint256 previousNumber, uint256 newNumber);

    function getNumber() external view returns (uint256);
    function setNumber(uint256 newNumber) external returns (bool);
    function increment() external returns (bool);
    function decrement() external returns (bool);
}
