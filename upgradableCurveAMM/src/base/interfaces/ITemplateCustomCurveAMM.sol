// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {PoolKey} from "v4-core/types/PoolKey.sol";
import "v4-core/types/PoolOperation.sol";
import {BeforeSwapDelta, toBeforeSwapDelta} from "v4-core/types/BeforeSwapDelta.sol";

interface ITemplateCustomCurveAMM {
    error TemplateCustomCurveAMM__NotPossibleToAddLiquidityThroughHook();

    event HookSwap(
        bytes32 indexed v4PoolId,
        address indexed swapRouter,
        int128 amount0, //negative is trader is selling 0
        int128 amount1, //negative is trader is selling 1
        uint128 hookLPfeeAmount0, // amount of LP fee in token0
        uint128 hookLPfeeAmount1 // amount of LP fee in token1
    );
    event HookModifyLiquidity(
        bytes32 indexed v4PoolId,
        address indexed swapRouter,
        int128 amount0, //negative is lp is withdrawing 0
        int128 amount1 //negative is lp is withdrawing 1
    );

    function beforeAddLiquidity(
        address,
        PoolKey calldata,
        ModifyLiquidityParams calldata,
        bytes calldata
    ) external returns (bytes4);

    function beforeSwap(
        address sender,
        PoolKey calldata key,
        SwapParams calldata params,
        bytes calldata hookData
    ) external returns (bytes4, BeforeSwapDelta, uint24);
}
