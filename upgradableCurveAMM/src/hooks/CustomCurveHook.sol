// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import "./interfaces/ICustomCurveHook.sol";
import {BaseHook} from "v4-periphery/src/utils/BaseHook.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";
import "../types/Callback.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";

abstract contract CustomCurveHook is ICustomCurveHook, BaseHook {
    using CallbackLibrary for *;
    constructor(IPoolManager poolManager) BaseHook(poolManager) {}

    function getHookPermissions()
        public
        pure
        override
        returns (Hooks.Permissions memory permissions)
    {
        permissions = Hooks.Permissions({
            beforeInitialize: false,
            afterInitialize: false,
            beforeAddLiquidity: true, // Don't allow adding liquidity normally
            afterAddLiquidity: false,
            beforeRemoveLiquidity: false,
            afterRemoveLiquidity: false,
            beforeSwap: true, // Override how swaps are done
            afterSwap: false,
            beforeDonate: false,
            afterDonate: false,
            beforeSwapReturnDelta: true, // Allow beforeSwap to return a custom delta
            afterSwapReturnDelta: false,
            afterAddLiquidityReturnDelta: false,
            afterRemoveLiquidityReturnDelta: false
        });
    }

    function beforeAddLiquidity(
        address sender,
        PoolKey calldata key,
        ModifyLiquidityParams calldata liquidityParams,
        bytes calldata hookData
    ) external pure override(BaseHook, ICustomCurveHook) returns (bytes4) {
        if (hookData.validateHookdata()) {
            poolManager.unlock(
                abi.encode(
                    CallBackData({
                        sender: sender,
                        key: key,
                        liquidityParams: liquidityParams,
                        swapParms: SwapParams({
                            zeroForOne: true,
                            amountSpecified: 0,
                            sqrtPriceLimitX96: 0
                        }),
                        hookData: hookData,
                        settleUsingClaims: true,
                        takeClaims: true
                    })
                )
            );
        }
    }

    function unlockCallback(
        bytes calldata rawData
    ) external onlyPoolManager returns (bytes memory) {
        // Callback memory data = abi.decode(rawData, (Callback));
    }
}
