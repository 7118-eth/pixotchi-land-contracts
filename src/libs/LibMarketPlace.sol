// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../shared/Structs.sol";
import "./LibMarketPlaceStorage.sol";
import "./LibTown.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


library LibMarketPlace {

    function _sM() internal pure returns (LibMarketPlaceStorage.Data storage data) {
        data = LibMarketPlaceStorage.data();
    }


    // Modifiers
    modifier orderExists(uint256 orderId) {
        require(_sM().orders[orderId].amount >= 0, "Order amount must be greater than 0");
        _;
    }

    modifier orderActive(uint256 orderId) {
        require(_sM().orders[orderId].isActive, "Order is not active");
        _;
    }

    modifier sufficientBalance(LibMarketPlaceStorage.TokenType tokenType, uint256 amount) {
        IERC20 token = tokenType == LibMarketPlaceStorage.TokenType.A ? TOKEN_A : TOKEN_B;
        require(token.balanceOf(msg.sender) >= amount, "Insufficient balance");
        _;
    }

    modifier sufficientAllowance(LibMarketPlaceStorage.TokenType tokenType, uint256 amount) {
        IERC20 token = tokenType == LibMarketPlaceStorage.TokenType.A ? TOKEN_A : TOKEN_B;
        require(token.allowance(msg.sender, address(this)) >= amount, "Insufficient allowance");
        _;
    }
    modifier sufficientAmount(LibMarketPlaceStorage.TokenType tokenType, uint256 amount) {
        //IERC20 token = tokenType == LibMarketPlaceStorage.TokenType.A ? TOKEN_A : TOKEN_B;
        require(amount >= 0, "Insufficient amount");
        _;
    }



    IERC20 public constant TOKEN_A = IERC20(0xc64F740D216B6ec49e435a8a08132529788e8DD0);
    IERC20 public constant TOKEN_B = IERC20(0x33feeD5a3eD803dc03BBF4B6041bB2b86FACD6C4);

    using SafeERC20 for IERC20;

    //using LibMarketPlaceStorage for LibMarketPlaceStorage.Storage;

    // Events
    event OrderCreated(
        uint256 orderId,
        address seller,
        LibMarketPlaceStorage.TokenType sellToken,
        uint256 amount
    );
    event OrderTaken(uint256 orderId, address buyer);
    event OrderCancelled(uint256 orderId, address seller, uint256 amount); // New event

    // Create order
    function createOrder(
        LibMarketPlaceStorage.TokenType sellToken,
        uint256 amount
    ) internal
    sufficientBalance(sellToken, amount)
    sufficientAllowance(sellToken, amount)
    sufficientAmount(sellToken, amount)
    {
        IERC20 token = sellToken == LibMarketPlaceStorage.TokenType.A ? TOKEN_A : TOKEN_B;

        // Transfer tokens from seller to contract
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        // Create order
        uint256 orderId = _sM().nextOrderId;
        _sM().orders[orderId] = LibMarketPlaceStorage.Order({
        //id: orderId,
            seller: msg.sender,
            sellToken: sellToken,
            amount: amount,
            isActive: true
        });

        // Update state
        _sM().nextOrderId += 1;
        _sM().userOrders[msg.sender].push(orderId);

        // Emit event
        emit OrderCreated(
            orderId,
            msg.sender,
            sellToken,
            amount
        );
    }

    // Take order
    function takeOrder(uint256 orderId) internal
    orderExists(orderId)
    orderActive(orderId)
    {
        LibMarketPlaceStorage.Order storage order = _sM().orders[orderId];
        LibMarketPlaceStorage.TokenType sellTokenType = order.sellToken;
        LibMarketPlaceStorage.TokenType buyTokenType = sellTokenType ==
        LibMarketPlaceStorage.TokenType.A
            ? LibMarketPlaceStorage.TokenType.B
            : LibMarketPlaceStorage.TokenType.A;

        IERC20 buyToken = buyTokenType == LibMarketPlaceStorage.TokenType.A ? TOKEN_A : TOKEN_B;
        IERC20 sellToken = sellTokenType == LibMarketPlaceStorage.TokenType.A ? TOKEN_A : TOKEN_B;

        uint256 amount = order.amount;


        require(
            buyToken.balanceOf(msg.sender) >= amount,
            "Insufficient balance to buy"
        );

        require(
            buyToken.allowance(msg.sender, address(this)) >= amount,
            "Insufficient allowance to buy"
        );

        // Mark order as inactive
        order.isActive = false;

        // Transfer buyToken from buyer to seller
        require(
            buyToken.transferFrom(
                msg.sender,
                order.seller,
                amount
            ),
            "Transfer failed"
        );

        // Transfer sellToken from contract to buyer
        require(
            sellToken.transfer(msg.sender, amount),
            "Transfer failed"
        );



        // Emit event
        emit OrderTaken(orderId, msg.sender);
    }

    // Cancel order
    function cancelOrder(uint256 orderId) internal
    orderExists(orderId)
    orderActive(orderId)
    {
        LibMarketPlaceStorage.Order storage order = _sM().orders[orderId];
        require(order.seller == msg.sender, "Only the seller can cancel the order");

        // Mark order as inactive
        order.isActive = false;

        // Determine the token to refund
        IERC20 token = order.sellToken == LibMarketPlaceStorage.TokenType.A ? TOKEN_A : TOKEN_B;

        // Transfer tokens back to the seller
        require(token.transfer(msg.sender, order.amount), "Refund transfer failed");

        // Emit event
        emit OrderCancelled(orderId, msg.sender, order.amount);
    }

    // View all active orders
    function getActiveOrders() internal view returns (MarketPlaceOrderView[] memory) {
        uint256 totalOrders = _sM().nextOrderId;
        uint256 activeCount = 0;
        uint256[] memory activeOrderIds = new uint256[](totalOrders);

        // First pass: count active orders and store their IDs
        for (uint256 i = 0; i < totalOrders; i++) {
            if (_sM().orders[i].isActive) {
                activeOrderIds[activeCount] = i;
                activeCount++;
            }
        }

        // Create an array of active orders with the exact size needed
        MarketPlaceOrderView[] memory activeOrders = new MarketPlaceOrderView[](activeCount);

        // Second pass: populate the activeOrders array
        for (uint256 i = 0; i < activeCount; i++) {
            uint256 orderId = activeOrderIds[i];
            LibMarketPlaceStorage.Order storage order = _sM().orders[orderId];
            activeOrders[i] = MarketPlaceOrderView({
                id: orderId,
                seller: order.seller,
                sellToken: uint8(order.sellToken),
                amount: order.amount,
                isActive: order.isActive
            });
        }

        return activeOrders;
    }

    // View user's orders
    function getUserOrders(
        address user
    ) internal view returns (MarketPlaceOrderView[] memory) {
        uint256[] storage userOrderIds = _sM().userOrders[user];
        uint256 totalOrders = userOrderIds.length;
        MarketPlaceOrderView[] memory userOrderList = new MarketPlaceOrderView[](totalOrders);

        for (uint256 i = 0; i < totalOrders; i++) {
            uint256 orderId = userOrderIds[i];
            LibMarketPlaceStorage.Order storage order = _sM().orders[orderId];
            userOrderList[i] = MarketPlaceOrderView({
                id: orderId,
                seller: order.seller,
                sellToken: uint8(order.sellToken),
                amount: order.amount,
                isActive: order.isActive
            });
        }

        return userOrderList;
    }



    // Getter for all inactive orders
    function getInactiveOrders() internal view returns (MarketPlaceOrderView[] memory) {
        uint256 totalOrders = _sM().nextOrderId;
        uint256 inactiveCount = 0;

        // Determine the number of inactive orders
        for (uint256 i = 0; i < totalOrders; i++) {
            if (!_sM().orders[i].isActive) {
                inactiveCount += 1;
            }
        }

        // Create an array of inactive orders
        MarketPlaceOrderView[] memory inactiveOrders = new MarketPlaceOrderView[](inactiveCount);
        uint256 index = 0;
        for (uint256 i = 0; i < totalOrders; i++) {
            if (!_sM().orders[i].isActive) {
                LibMarketPlaceStorage.Order storage order = _sM().orders[i];
                inactiveOrders[index] = MarketPlaceOrderView({
                    id: i,
                    seller: order.seller,
                    sellToken: uint8(order.sellToken),
                    amount: order.amount,
                    isActive: order.isActive
                });
                index += 1;
            }
        }

        return inactiveOrders;
    }
}
