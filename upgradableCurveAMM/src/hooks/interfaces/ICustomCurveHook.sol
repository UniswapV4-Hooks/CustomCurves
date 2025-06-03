// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {PoolKey} from "v4-core/types/PoolKey.sol";
import "v4-core/types/PoolOperation.sol";
import {BeforeSwapDelta} from "v4-core/types/BalanceDelta.sol";

interface ICustomCurveHook {
    function beforeAddLiquidity(
        address sender,
        PoolKey calldata key,
        ModifyLiquidityParams calldata liquidityParams,
        bytes calldata data
    ) external returns (bytes4 selector);

    function beforeSwap(
        address sender,
        PoolKey calldata key,
        SwapParams calldata params,
        bytes calldata hookData
    ) external returns (bytes4, BeforeSwapDelta, uint24);
}
