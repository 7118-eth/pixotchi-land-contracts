// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { LibWareHouse } from "../libs/LibWareHouse.sol";
import "../shared/Structs.sol";
import { AccessControl2 } from "../libs/libAccessControl2.sol";

/// @title WareHouseFacet
/// @notice This contract manages warehouse operations for plant points and lifetime assignments
/// @dev Inherits from AccessControl2 for access control functionality
contract WareHouseFacet is AccessControl2 {
  /// @notice Assigns plant points to a specific NFT
  /// @param _nftId The ID of the NFT to assign points to
  /// @param _addedPoints The number of points to add
  /// @return _newPlantPoints The updated total plant points for the NFT
  function wareHouseAssignPlantPoints(
    uint256 _nftId,
    uint256 _addedPoints
  ) external isApproved(_nftId) returns (uint256 _newPlantPoints) {
    return LibWareHouse.landToPlantAssignPlantPoints(_nftId, _addedPoints);
  }

  /// @notice Assigns lifetime to a specific NFT
  /// @param _nftId The ID of the NFT to assign lifetime to
  /// @param _lifetime The lifetime value to assign
  /// @return _newLifetime The updated lifetime for the NFT
  function wareHouseAssignLifeTime(
    uint256 _nftId,
    uint256 _lifetime
  ) external isApproved(_nftId) returns (uint256 _newLifetime) {
    return LibWareHouse.landToPlantAssignLifeTime(_nftId, _lifetime);
  }
}
