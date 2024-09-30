// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../shared/Structs.sol";
import {NFTModifiers} from "../libs/LibNFT.sol";
import {LibMarketPlace} from "../libs/LibMarketPlace.sol";
import {LibMarketPlaceStorage} from "../libs/LibMarketPlaceStorage.sol";
import {AccessControl2} from "../libs/libAccessControl2.sol";

contract MarketPlaceFacet is AccessControl2 {
    //using LibMarketPlace for *;

    // Events
    // event OrderCreated(
    //     uint256 orderId,
    //     address seller,
    //     LibMarketPlaceStorage.TokenType sellToken,
    //     uint256 amount
    // );
    // event OrderTaken(uint256 orderId, address buyer);

    // Create order
    function createOrder(
        uint256 landId,
        uint8 sellToken,
        uint256 amount
    ) external
    isApproved(landId)
    {
        LibMarketPlaceStorage.TokenType sellTokenEnum = sellToken == 0 
            ? LibMarketPlaceStorage.TokenType.A 
            : LibMarketPlaceStorage.TokenType.B;
        LibMarketPlace.createOrder(sellTokenEnum, amount);
    }

    // Take order
    function takeOrder(uint256 landId, uint256 orderId) isApproved(landId) external {
        LibMarketPlace.takeOrder(orderId);
    }

    // Cancel order
    function cancelOrder(uint256 landId, uint256 orderId) isApproved(landId) external {
        LibMarketPlace.cancelOrder(orderId);
    }

    // View all active orders
    function getActiveOrders() external view returns (MarketPlaceOrderView[] memory) {
        return LibMarketPlace.getActiveOrders();
    }

    // View user's orders
    function getUserOrders(address user) external view returns (MarketPlaceOrderView[] memory) {
        return LibMarketPlace.getUserOrders(user);
    }

    // Getter for all inactive orders
    function getInactiveOrders() external view returns (MarketPlaceOrderView[] memory) {
        return LibMarketPlace.getInactiveOrders();
    }
}

