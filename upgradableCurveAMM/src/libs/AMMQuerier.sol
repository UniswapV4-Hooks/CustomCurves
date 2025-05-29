// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

type tickDelta is int48;
type liquidity is uint256;

//TODO:
//  1 .Implement the tickDelta type
//  2. Implement the liquidity type
//    2.1 Consider the reserves should be uint128
struct GlobalLiquidityParams {
    uint128 reserveX;
    uint128 reverveY;
    int256 addedLiquidityX;
    int256 addedLiquidityY;
    mapping(tickDelta => liquidity) liquidityPerTick;
}
library AMMQuerier {
    function isCSMM(
        GlobalLiquidityParams storage liquidityParams
    ) external view returns (bool) {
        return
            liquidityParams.addedLiquidityX == -liquidityParams.addedLiquidityY;
    }
}
