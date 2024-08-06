// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { MetaTxContextStorage } from "../shared/Structs.sol";

library LibNFTStorage {
    bytes32 internal constant DIAMOND_STORAGE_POSITION = keccak256("eth.pixotchi.land.nft.storage");

    /// @notice Returns the diamond storage for NFT-related data
    /// @return ds The NFTStorage struct
    function data() internal pure returns (Data storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    /// @notice Initializes the NFT storage with default values
    /// @dev This function can only be called once
    function initializeNFTStorage() internal initializer(1) {
        Data storage s = data();
        s.maxSupply = 10000;
        s.minX = -56;
        s.maxX = 56;
        s.minY = -56;
        s.maxY = 56;
    }

    error AlreadyInitialized(uint256 currentVersion, uint256 newVersion);

    /// @notice Modifier to ensure initialization is done only once per version
    /// @param version The version number of the initializer
    modifier initializer(uint256 version) {
        Data storage s = data();
        if (s.initializationNumber >= version) {
            revert AlreadyInitialized(s.initializationNumber, version);
        }
        _;
        s.initializationNumber = version;
    }

    struct Coordinates {
        int256 x;
        int256 y;
        bool occupied;
    }

    struct Data {
        uint256 initializationNumber;
        uint256 reentrancyStatus;
        MetaTxContextStorage metaTxContext;

        uint256 maxSupply;
        // Mapping to store coordinates for each token ID
        mapping(uint256 => Coordinates) tokenCoordinates;

        // Boundaries for x and y coordinates
        int256 minX;
        int256 maxX;
        int256 minY;
        int256 maxY;

        // Mapping to access coordinates directly
        mapping(int256 => mapping(int256 => uint256)) coordinateToTokenId;
    }
}