// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import {IHooks} from "v4-core/interfaces/IHooks.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";
import {TickMath} from "v4-core/libraries/TickMath.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {BalanceDelta} from "v4-core/types/BalanceDelta.sol";
import {PoolId, PoolIdLibrary} from "v4-core/types/PoolId.sol";
import {CurrencyLibrary, Currency} from "v4-core/types/Currency.sol";
import {PoolSwapTest} from "v4-core/test/PoolSwapTest.sol";
import {Deployers} from "@uniswap/v4-core/test/utils/Deployers.sol";
import {CSMM} from "../src/CSMM.sol";
import {IERC20Minimal} from "v4-core/interfaces/external/IERC20Minimal.sol";
import "v4-core/libraries/Pool.sol";
contract CSMMTest is Test, Deployers {
    using PoolIdLibrary for PoolId;
    using CurrencyLibrary for Currency;

    CSMM private csmm;

    function setUp() public {
        deployFreshManagerAndRouters();
        (currency0, currency1) = deployMintAndApprove2Currencies();

        address csmmAddress = address(
            uint160(
                Hooks.BEFORE_ADD_LIQUIDITY_FLAG |
                    Hooks.BEFORE_SWAP_FLAG |
                    Hooks.BEFORE_SWAP_RETURNS_DELTA_FLAG
            )
        );

        deployCodeTo("CSMM.sol", abi.encode(manager), csmmAddress);
        csmm = CSMM(csmmAddress);
        (key, ) = initPool(currency0, currency1, csmm, 3000, SQRT_PRICE_1_1);

        IERC20Minimal(Currency.unwrap(key.currency0)).approve(
            csmmAddress,
            1000 ether
        );

        IERC20Minimal(Currency.unwrap(key.currency1)).approve(
            csmmAddress,
            1000 ether
        );
        csmm.CSMM_customAddLiquidity(key, 1000e18);
    }

    function test_cannotModifyLiquidity() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                CSMM.CSMM__NotPossibleToAddLiquidityThroughHook.selector
            )
        );
        //TODO: Not finding the fucntion ...
        modifyLiquidityRouter.modifyLiquidity(
            key,
            Pool.ModifyLiquidityParams({
                owner: address(manager),
                tickLower: -60,
                tickUpper: 60,
                liquidityDelta: 1e18,
                tickSpacing: int24((300 / 100) * 2),
                salt: bytes32(0)
            }),
            ZERO_BYTES
        );
    }
}
