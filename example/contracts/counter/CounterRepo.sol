// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

library CounterRepo {
    bytes32 internal constant STORAGE_SLOT = keccak256(abi.encode("daosys.example.counter"));

    struct Storage {
        uint256 number;
    }

    function _layout(bytes32 slot) internal pure returns (Storage storage layout) {
        assembly {
            layout.slot := slot
        }
    }

    function _layout() internal pure returns (Storage storage) {
        return _layout(STORAGE_SLOT);
    }

    function _getNumber(Storage storage layout) internal view returns (uint256) {
        return layout.number;
    }

    function _getNumber() internal view returns (uint256) {
        return _getNumber(_layout());
    }

    function _setNumber(Storage storage layout, uint256 newNumber) internal {
        layout.number = newNumber;
    }

    function _setNumber(uint256 newNumber) internal {
        _setNumber(_layout(), newNumber);
    }
}
