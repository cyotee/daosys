// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import {IDiamond} from "@crane/contracts/interfaces/IDiamond.sol";
import {IDiamondFactoryPackage} from "@crane/contracts/interfaces/IDiamondFactoryPackage.sol";
import {IFacet} from "@crane/contracts/interfaces/IFacet.sol";
import {IGreeter} from "@crane/contracts/test/stubs/greeter/IGreeter.sol";
import {IOperable} from "@crane/contracts/interfaces/IOperable.sol";
import {IMultiStepOwnable} from "@crane/contracts/interfaces/IMultiStepOwnable.sol";

// Facet implementations
import {OperableGreeterFacet} from "./OperableGreeterFacet.sol";
import {OperableFacet} from "@crane/contracts/access/operable/OperableFacet.sol";
import {MultiStepOwnableFacet} from "@crane/contracts/access/ERC8023/MultiStepOwnableFacet.sol";

// Storage for initialization
import {GreeterRepo} from "@crane/contracts/test/stubs/greeter/GreeterRepo.sol";
import {MultiStepOwnableRepo} from "@crane/contracts/access/ERC8023/MultiStepOwnableRepo.sol";

/**
 * @title IPermissionedGreeterDFPkg
 * @notice Interface for the Permissioned Greeter Diamond Factory Package.
 */
interface IPermissionedGreeterDFPkg {
    /**
     * @notice Deployment arguments for creating a new Permissioned Greeter Diamond.
     * @param initialMessage The initial greeting message.
     * @param owner The initial owner of the Diamond (can manage operators).
     */
    struct PkgArgs {
        string initialMessage;
        address owner;
    }
}

/**
 * @title PermissionedGreeterDFPkg
 * @notice Diamond Factory Package that bundles Greeter + Operable + MultiStepOwnable facets.
 * @dev Demonstrates multi-facet Diamond composition with access control.
 *
 * This package creates Diamonds with:
 * - OperableGreeterFacet: getMessage() (public) + setMessage() (operator only)
 * - OperableFacet: isOperator(), setOperator(), isOperatorFor(), setOperatorFor()
 * - MultiStepOwnableFacet: owner(), initiateOwnershipTransfer(), etc.
 *
 * Access Control Flow:
 * 1. Owner can add/remove operators via setOperator() or setOperatorFor()
 * 2. Operators can call setMessage() to update the greeting
 * 3. Anyone can call getMessage() to read the greeting
 */
contract PermissionedGreeterDFPkg is IPermissionedGreeterDFPkg, IDiamondFactoryPackage {
    // Immutable reference to self for facetCuts
    IDiamondFactoryPackage immutable SELF;

    // Facet instances (immutable after construction)
    IFacet public immutable OPERABLE_GREETER_FACET;
    IFacet public immutable OPERABLE_FACET;
    IFacet public immutable MULTI_STEP_OWNABLE_FACET;

    constructor() {
        SELF = this;

        // Deploy facet instances
        OPERABLE_GREETER_FACET = IFacet(address(new OperableGreeterFacet()));
        OPERABLE_FACET = IFacet(address(new OperableFacet()));
        MULTI_STEP_OWNABLE_FACET = IFacet(address(new MultiStepOwnableFacet()));
    }

    /* -------------------------------------------------------------------------- */
    /*                          IDiamondFactoryPackage                            */
    /* -------------------------------------------------------------------------- */

    /**
     * @inheritdoc IDiamondFactoryPackage
     */
    function packageName() public pure returns (string memory name_) {
        return type(PermissionedGreeterDFPkg).name;
    }

    /**
     * @inheritdoc IDiamondFactoryPackage
     */
    function packageMetadata()
        public
        view
        returns (string memory name_, bytes4[] memory interfaces, address[] memory facets)
    {
        name_ = packageName();
        interfaces = facetInterfaces();
        facets = facetAddresses();
    }

    /**
     * @notice Returns all facet addresses in this package.
     */
    function facetAddresses() public view returns (address[] memory facetAddresses_) {
        facetAddresses_ = new address[](3);
        facetAddresses_[0] = address(OPERABLE_GREETER_FACET);
        facetAddresses_[1] = address(OPERABLE_FACET);
        facetAddresses_[2] = address(MULTI_STEP_OWNABLE_FACET);
    }

    /**
     * @inheritdoc IDiamondFactoryPackage
     */
    function facetInterfaces() public pure returns (bytes4[] memory interfaces) {
        interfaces = new bytes4[](3);
        interfaces[0] = type(IGreeter).interfaceId;
        interfaces[1] = type(IOperable).interfaceId;
        interfaces[2] = type(IMultiStepOwnable).interfaceId;
    }

    /**
     * @inheritdoc IDiamondFactoryPackage
     */
    function facetCuts() public view virtual returns (IDiamond.FacetCut[] memory facetCuts_) {
        facetCuts_ = new IDiamond.FacetCut[](3);

        // OperableGreeterFacet: getMessage, setMessage
        facetCuts_[0] = IDiamond.FacetCut({
            facetAddress: address(OPERABLE_GREETER_FACET),
            action: IDiamond.FacetCutAction.Add,
            functionSelectors: OPERABLE_GREETER_FACET.facetFuncs()
        });

        // OperableFacet: isOperator, setOperator, isOperatorFor, setOperatorFor
        facetCuts_[1] = IDiamond.FacetCut({
            facetAddress: address(OPERABLE_FACET),
            action: IDiamond.FacetCutAction.Add,
            functionSelectors: OPERABLE_FACET.facetFuncs()
        });

        // MultiStepOwnableFacet: owner, initiateOwnershipTransfer, etc.
        facetCuts_[2] = IDiamond.FacetCut({
            facetAddress: address(MULTI_STEP_OWNABLE_FACET),
            action: IDiamond.FacetCutAction.Add,
            functionSelectors: MULTI_STEP_OWNABLE_FACET.facetFuncs()
        });
    }

    /**
     * @inheritdoc IDiamondFactoryPackage
     */
    function diamondConfig() public view virtual returns (IDiamondFactoryPackage.DiamondConfig memory config) {
        config = IDiamondFactoryPackage.DiamondConfig({
            facetCuts: facetCuts(),
            interfaces: facetInterfaces()
        });
    }

    /**
     * @inheritdoc IDiamondFactoryPackage
     */
    function calcSalt(bytes memory pkgArgs) public pure returns (bytes32 salt) {
        salt = keccak256(abi.encode(pkgArgs));
    }

    /**
     * @inheritdoc IDiamondFactoryPackage
     */
    function processArgs(bytes memory pkgArgs) public pure returns (bytes memory processedPkgArgs) {
        processedPkgArgs = pkgArgs;
    }

    /**
     * @inheritdoc IDiamondFactoryPackage
     */
    function updatePkg(address, bytes memory) public virtual returns (bool) {
        return true;
    }

    /**
     * @notice Initialize storage for the newly deployed Diamond proxy.
     * @dev Called via delegatecall from the proxy during deployment.
     * @param initArgs ABI-encoded PkgArgs struct.
     */
    function initAccount(bytes memory initArgs) public {
        PkgArgs memory args = abi.decode(initArgs, (PkgArgs));

        // Initialize the greeting message
        GreeterRepo._setMessage(args.initialMessage);

        // Initialize ownership - set the owner with 0 buffer period for simplicity
        // In production, consider using a non-zero buffer period (e.g., 2 days)
        MultiStepOwnableRepo._initialize(args.owner, 0);
    }

    /**
     * @inheritdoc IDiamondFactoryPackage
     */
    function postDeploy(address) public virtual returns (bool) {
        return true;
    }
}
