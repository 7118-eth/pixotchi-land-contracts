// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import "./LibWareHouseStorage.sol";
import "../shared/Structs.sol";
import {ILandToPlant} from "../shared/ILandToPlant.sol";

library LibWareHouse {

    ILandToPlant internal constant landToPlant = ILandToPlant(0x1723a3F01895c207954d09F633a819c210d758c4);

    function landToPlantAssignPlantPoints(uint256 _nftId, uint256 _addedPoints) internal returns (uint256 _newPlantPoints) {
        return landToPlant.landToPlantAssignPlantPoints(_nftId, _addedPoints);
    }

    function landToPlantAssignLifeTime(uint256 _nftId, uint256 _lifetime) internal returns (uint256 _newLifetime){
        return landToPlant.landToPlantAssignLifeTime(_nftId, _lifetime);
    }


}
