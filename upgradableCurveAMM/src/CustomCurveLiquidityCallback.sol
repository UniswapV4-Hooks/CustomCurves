// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {IUnlockCallback} from "v4-core/interfaces/callback/IUnlockCallback.sol";
import {BaseHook} from "v4-periphery/src/utils/BaseHook.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import "./base/interfaces/ITemplateCustomCurveAMM.sol";
import {Currency} from "v4-core/types/Currency.sol";
import {CurrencySettler} from "@uniswap/v4-core/test/utils/CurrencySettler.sol";

struct CallBackData {
    address sender;
    uint256 amountEach;
    Currency currency0;
    Currency currency1;
}

abstract contract CustomCurveLiquidityCallback is IUnlockCallback, BaseHook {
    using CurrencySettler for Currency;
    ITemplateCustomCurveAMM private customCurveAMM;

    // mapping(PoolKey => CallBackData) private callBackData;

    constructor(
        IPoolManager poolManager,
        ITemplateCustomCurveAMM _customCurveAMM
    ) BaseHook(poolManager) {
        customCurveAMM = _customCurveAMM;
    }

    function unlockCallback(
        bytes calldata data
    ) external onlyPoolManager returns (bytes memory) {
        // 2.Data only is supposed to have the
        // ICustomCurve(implementationAddress).addLiquidity(liquidityParams).
        // to be valid. Thus it forwards the liqudityParams with no changes to
        // ICustomCurve and its ICustomCurve implementation to mutate this parameters
        // as needed to provide the liquidity to the user
        // 1. liquidityRouter.modifyLiquidity(L (in the form given by the router impl), poolManager).
        //         The liquidity is stored at the pool Manager but is meant to be managed by the
        // =================================================================================================
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

    // somehow we need to take the tokens from the user
    // but store them in the PoolManager. But we also want
    // the hook to "own" those tokens even if they're stored
    // within the PoolManager. So how do we do this?
    // ERC-6909 Claim Tokens!
}
