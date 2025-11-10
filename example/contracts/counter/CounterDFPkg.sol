// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import {IDiamond} from "@crane/contracts/interfaces/IDiamond.sol";
import {IDiamondFactoryPackage} from "@crane/contracts/interfaces/IDiamondFactoryPackage.sol";
import {IFacet} from "@crane/contracts/interfaces/IFacet.sol";

import {CounterFacet} from "./CounterFacet.sol";
import {ICounter} from "./ICounter.sol";
import {CounterRepo} from "./CounterRepo.sol";

interface ICounterDFPkg {
    struct PkgArgs {
        uint256 initialNumber;
    }
}

contract CounterDFPkg is ICounterDFPkg, IDiamondFactoryPackage {
    IDiamondFactoryPackage immutable SELF;
    IFacet public immutable COUNTER_FACET;

    constructor() {
        SELF = this;
        COUNTER_FACET = IFacet(address(new CounterFacet()));
    }

    function packageName() public pure returns (string memory name_) {
        return type(CounterDFPkg).name;
    }

    function packageMetadata()
        public
        view
        returns (string memory name_, bytes4[] memory interfaces, address[] memory facets)
    {
        name_ = packageName();
        interfaces = facetInterfaces();
        facets = facetAddresses();
    }

    function facetAddresses() public view returns (address[] memory facetAddresses_) {
        facetAddresses_ = new address[](1);
        facetAddresses_[0] = address(COUNTER_FACET);
    }

    function facetInterfaces() public pure returns (bytes4[] memory interfaces) {
        interfaces = new bytes4[](1);
        interfaces[0] = type(ICounter).interfaceId;
    }

    function facetCuts() public view returns (IDiamond.FacetCut[] memory facetCuts_) {
        facetCuts_ = new IDiamond.FacetCut[](1);
        facetCuts_[0] = IDiamond.FacetCut({
            facetAddress: address(COUNTER_FACET),
            action: IDiamond.FacetCutAction.Add,
            functionSelectors: COUNTER_FACET.facetFuncs()
        });
    }

    function diamondConfig() public view returns (IDiamondFactoryPackage.DiamondConfig memory config) {
        config = IDiamondFactoryPackage.DiamondConfig({facetCuts: facetCuts(), interfaces: facetInterfaces()});
    }

    function calcSalt(bytes memory pkgArgs) public pure returns (bytes32 salt) {
        salt = keccak256(abi.encode(pkgArgs));
    }

    function processArgs(bytes memory pkgArgs) public pure returns (bytes memory processedPkgArgs) {
        processedPkgArgs = pkgArgs;
    }

    function updatePkg(address, bytes memory) public returns (bool) {
        return true;
    }

    function initAccount(bytes memory initArgs) public {
        PkgArgs memory args = abi.decode(initArgs, (PkgArgs));
        CounterRepo._setNumber(args.initialNumber);
    }

    function postDeploy(address) public returns (bool) {
        return true;
    }
}
