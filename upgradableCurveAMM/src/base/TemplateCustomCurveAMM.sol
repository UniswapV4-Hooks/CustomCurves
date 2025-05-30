// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {PoolId} from "v4-core/types/PoolId.sol";
import {Currency} from "v4-core/types/Currency.sol";
import {CurrencySettler} from "@uniswap/v4-core/test/utils/CurrencySettler.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";
import {BaseHook} from "v4-periphery/src/utils/BaseHook.sol";
import "v4-core/libraries/Pool.sol";
import {IHooks} from "v4-core/interfaces/IHooks.sol";
import "./interfaces/ITemplateCustomCurveAMM.sol";
//TODO:
//   This contract should be upgradble because one would want
//   to update the hook permssions
//   TO ONLY ADD new compatible permissions

// This is updating the getHookPermissions function and restrcting to delete the
//default permissions, ONLY ADD PERMISSIONS
struct CallBackData {
    uint256 amountEach;
    Currency currency0;
    Currency currency1;
    address sender;
}

abstract contract TemplateCustomCurveAMM is BaseHook, ITemplateCustomCurveAMM {
    using CurrencySettler for Currency;
    //TODO: This goes under transient storage as it is done in one single transaction

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
        bytes calldata data
    )
        external
        override(BaseHook, ITemplateCustomCurveAMM)
        returns (bytes4 selector)
    {
        {
            CallBackData memory callBackData = _getUnderlyingReserves(
                key,
                liquidityParams,
                sender
            );
            _settleAndTake(callBackData);
        }

        if (data.length != 0) {
            //If data is passed user has some request:
            // What curve he wants to implement liquidity on
            // this data should decode:
            // The interface of the custom Curve hook
            poolManager.unlock(abi.encode(key, liquidityParams, data));
        }
        selector = ITemplateCustomCurveAMM.beforeAddLiquidity.selector;
    }

    function beforeSwap(
        address sender,
        PoolKey calldata key,
        SwapParams calldata params,
        bytes calldata hookData
    )
        external
        override(BaseHook, ITemplateCustomCurveAMM)
        returns (bytes4, BeforeSwapDelta, uint24)
    {}

    function _getUnderlyingReserves(
        PoolKey calldata key,
        ModifyLiquidityParams calldata params,
        address sender
    ) internal pure returns (CallBackData memory callBackData) {
        //TODO: how to get amountEach
        // this is where the until now not used params parameter
        // comes into play
        uint256 _amountEach = 200;
        callBackData = CallBackData({
            amountEach: _amountEach,
            currency0: key.currency0,
            currency1: key.currency1,
            sender: sender
        });
    }

    function _settleAndTake(CallBackData memory callBackData) internal {
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
    }
}
