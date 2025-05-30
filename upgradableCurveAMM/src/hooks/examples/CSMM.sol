// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {PoolId} from "v4-core/types/PoolId.sol";
import {Currency} from "v4-core/types/Currency.sol";
import {CurrencySettler} from "@uniswap/v4-core/test/utils/CurrencySettler.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";
import {BeforeSwapDelta, toBeforeSwapDelta} from "v4-core/types/BeforeSwapDelta.sol";
import {BaseHook} from "v4-periphery/src/utils/BaseHook.sol";
import "v4-core/libraries/Pool.sol";
import {IHooks} from "v4-core/interfaces/IHooks.sol";
import "v4-core/types/PoolOperation.sol";

struct CallBackData {
    uint256 amountEach;
    Currency currency0;
    Currency currency1;
    address sender;
}

contract CSMM is BaseHook {
    using CurrencySettler for Currency;
    error CSMM__NotPossibleToAddLiquidityThroughHook();

    event CSMM__Swap(
        bytes32 indexed v4PoolId,
        address indexed swapRouter,
        int128 amount0, //negative is trader is selling 0
        int128 amount1, //negative is trader is selling 1
        uint128 hookLPfeeAmount0, // amount of LP fee in token0
        uint128 hookLPfeeAmount1 // amount of LP fee in token1
    );
    event CSMM__ModifyLiquidity(
        bytes32 indexed v4PoolId,
        address indexed swapRouter,
        int128 amount0, //negative is lp is withdrawing 0
        int128 amount1 //negative is lp is withdrawing 1
    );

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
        address,
        PoolKey calldata,
        ModifyLiquidityParams calldata,
        bytes calldata
    ) external pure override returns (bytes4) {
        revert CSMM__NotPossibleToAddLiquidityThroughHook();
    }

    function CSMM_customAddLiquidity(
        PoolKey calldata key,
        uint256 amountEach
    ) external {
        poolManager.unlock(
            abi.encode(
                CallBackData({
                    amountEach: amountEach,
                    currency0: key.currency0,
                    currency1: key.currency1,
                    sender: msg.sender
                })
            )
        );

        emit CSMM__ModifyLiquidity(
            PoolId.unwrap(key.toId()),
            address(this),
            int128(uint128(amountEach)),
            int128(uint128(amountEach))
        );
    }

    function unlockCallback(
        bytes calldata data
    ) external onlyPoolManager returns (bytes memory) {
        CallBackData memory callBackData = abi.decode(data, (CallBackData));
        // somehow we need to take the tokens from the user
        // but store them in the PoolManager. But we also want
        // the hook to "own" those tokens even if they're stored
        // within the PoolManager. So how do we do this?
        // ERC-6909 Claim Tokens!
        callBackData.currency0.settle(
            poolManager,
            callBackData.sender,
            callBackData.amountEach,
            false // `burn` = `false` i.e. we're actually transferring tokens, not burning ERC-6909 Claim Tokens
        );
        callBackData.currency1.settle(
            poolManager,
            callBackData.sender,
            callBackData.amountEach,
            false
        );

        callBackData.currency0.take(
            poolManager,
            address(this),
            callBackData.amountEach,
            true // true = mint claim tokens for the hook, equivalent to money we just deposited to the PM
        );
        callBackData.currency1.take(
            poolManager,
            address(this),
            callBackData.amountEach,
            true // true = mint claim tokens for the hook, equivalent to money we just deposited to the PM
        );
        return "";
    }

    function beforeSwap(
        address sender,
        PoolKey calldata key,
        SwapParams calldata params,
        bytes calldata
    ) external override returns (bytes4, BeforeSwapDelta, uint24) {
        //TODO
        // 1. Get the absolute value of how many tokens the user wants to swap
        uint256 amountInOutPositive = params.amountSpecified > 0
            ? uint256(params.amountSpecified)
            : uint256(-params.amountSpecified);
        // 2. Create a BeforeSwapDelta that is (-params.amountSpecified, params.amountSpecified)
        BeforeSwapDelta beforeSwapDelta = toBeforeSwapDelta(
            int128(-params.amountSpecified),
            int128(params.amountSpecified)
        );

        if (params.zeroForOne) {
            // 3. Account for balances, mint/burn claim tokens as needed
            key.currency0.take(
                poolManager,
                address(this),
                amountInOutPositive,
                true
            );

            key.currency1.settle(
                poolManager,
                address(this),
                amountInOutPositive,
                true
            );

            emit CSMM__Swap(
                PoolId.unwrap(key.toId()),
                sender,
                -int128(uint128(amountInOutPositive)),
                int128(int256(amountInOutPositive)),
                0,
                0
            );
        } else {
            key.currency0.settle(
                poolManager,
                address(this),
                amountInOutPositive,
                true
            );

            key.currency1.take(
                poolManager,
                address(this),
                amountInOutPositive,
                true
            );

            emit CSMM__Swap(
                PoolId.unwrap(key.toId()),
                sender,
                int128(int256(amountInOutPositive)),
                -int128(uint128(amountInOutPositive)),
                0,
                0
            );
        }
        return (IHooks.beforeSwap.selector, beforeSwapDelta, 0);
    }
}
