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

//TODO: This contract should be upgradble because one would want to update the hook permssions
// TO ONLY ADD new compatible permissions

// This is updating the getHookPermissions function and restrcting to delete the
//default permissions, ONLY ADD PERMISSIONS

contract TemplateCustomCurveAMM is BaseHook {
    using CurrencySettler for Currency;
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
        revert TemplateCustomCurveAMM__NotPossibleToAddLiquidityThroughHook();
    }
    function unlockCallback(
        bytes calldata data
    ) external onlyPoolManager returns (bytes memory) {
        // 1. liquidityRouter.modifyLiquidity(L (in the form given by the router impl), poolManager).
        //         The liquidity is stored at the pool Manager but is meant to be managed by the
        // ===========================UpgradableLiquidityManager=======================================
        // =========================================================================================
        //   Notice that at core we have that liquidity is defined by the price ranges where is being provided
        //   and the underlying reserve amounts to this price ranges, all other liquidity metrics are derived
        //   from this, so the immutableLiquidityProvition params are
        //         int256 addedLiquidityX;
        //        int256 addedLiquidityY;
        //        mapping(tickDelta => liquidity) liquidityPerTick;
        // ================================================================================
        // ==========================(NOT UPGRADABLE)=====================================
        //   1. UpgradableLiquidityManager.setImmutableLiquidityProvisionParams(L (in the form given by the router impl), poolManager).
        // ================================================================================
        // ==========================(UPGRADABLE)=====================================
        //   2. UpgradableLiquidityManager.updateLiquidityProvisionParams(ImmutableLiquidityProvisionParams).
        //   3. UpgradableLiquidityManager.manageLiquidity(currentLiquidityProvisionParams, poolManager)
        //        3.1 X.claim(dx), Y.claim(dy) . (CurrencySettler is making us have ownership of this liquidity)
        //   So for custom liquidity provisions a developer can build on top of this immutableLiquidityProvition params
        // User needs to send us dx .
        //   hook.mint()
        //  ERC-6909 claim tokens for them representing that the hook has ownership over those 500 tokens without actually owning the underlying tokens.
        //  It's the same strategy that daytraders can use to keep their funds on the PM while only holding claim tokens.
        // We'll use that strategy to take money from the user in both currencies, send it all to the PM, and then
        //  mint an equivalent amount of claim tokens for both that the hook will actually keep.
    }
}
