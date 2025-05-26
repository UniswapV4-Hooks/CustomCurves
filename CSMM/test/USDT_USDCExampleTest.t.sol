// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {Deployers} from "@uniswap/v4-core/test/utils/Deployers.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "v4-core/types/PoolId.sol";
import {CurrencyLibrary, Currency} from "v4-core/types/Currency.sol";
import {TickMath} from "v4-core/libraries/TickMath.sol";
import {PoolSwapTest} from "v4-core/test/PoolSwapTest.sol";
import {PoolModifyLiquidityTest} from "v4-core/test/PoolModifyLiquidityTest.sol";
import {IHooks} from "v4-core/interfaces/IHooks.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";
import "v4-core/types/PoolOperation.sol";
import {StateLibrary} from "v4-core/libraries/StateLibrary.sol";
import {FixedPointMathLib} from "solmate/src/utils/FixedPointMathLib.sol";

contract USDT_USDCExampleTest is Test, Deployers {
    using FixedPointMathLib for uint256;
    using PoolIdLibrary for PoolId;
    using CurrencyLibrary for Currency;

    Currency private usdc;
    Currency private usdt;
    PoolKey private USDC_USDT;

    PoolSwapTest private trader;
    PoolModifyLiquidityTest private liquidityProvider;

    function setUp() public {
        deployFreshManagerAndRouters();
        (currency0, currency1) = deployMintAndApprove2Currencies();

        usdc = currency0;
        usdt = currency1;

        trader = swapRouter;
        liquidityProvider = modifyLiquidityRouter;

        (key, ) = initPool(
            currency0,
            currency1,
            IHooks(address(0)),
            3000,
            TickMath.MIN_TICK_SPACING, //1
            SQRT_PRICE_1_1
        );
        USDC_USDT = key;
    }
    // function test_getSlot0() public {
    //     // create liquidity
    //     modifyLiquidityRouter.modifyLiquidity(key, ModifyLiquidityParams(-60, 60, 10_000 ether, 0), ZERO_BYTES);

    //     modifyLiquidityRouter.modifyLiquidity(key, ModifyLiquidityParams(-600, 600, 10_000 ether, 0), ZERO_BYTES);

    //     // swap to create fees, crossing a tick
    //     uint256 swapAmount = 100 ether;
    //     swap(key, true, -int256(swapAmount), ZERO_BYTES);
    //     (uint160 sqrtPriceX96, int24 tick, uint24 protocolFee, uint24 swapFee) = StateLibrary.getSlot0(manager, poolId);
    //     vm.snapshotGasLastCall("extsload getSlot0");
    //     assertEq(tick, -139);

    //     // magic number verified against a native getter
    //     assertEq(sqrtPriceX96, 78680104762184586858280382455);
    //     assertEq(tick, -139);
    //     assertEq(protocolFee, 0); // tested in protocol fee tests
    //     assertEq(swapFee, 3000);
    // }
    // 2. El otro caso es que alguien agregue
    // liquidez en el rango correcto, pero llegue una orden mas grande
    // que la liquidez agregada, en ese caso el trader
    // recibira menos unidades del token que compra que las
    // que deberia

    //     struct ModifyLiquidityParams {
    //     // the lower and upper tick of the position
    //     int24 tickLower;
    //     int24 tickUpper;
    //     // how to modify the liquidity
    //     int256 liquidityDelta;
    //     // a value to set if you want unique liquidity positions at the same range
    //     bytes32 salt;
    // }

    // function test_getLiquidity() public {
    //     modifyLiquidityRouter.modifyLiquidity(key, ModifyLiquidityParams(-60, 60, 10 ether, 0), ZERO_BYTES);
    //     modifyLiquidityRouter.modifyLiquidity(key, ModifyLiquidityParams(-120, 120, 10 ether, 0), ZERO_BYTES);

    //     uint128 liquidity = StateLibrary.getLiquidity(manager, poolId);
    //     vm.snapshotGasLastCall("extsload getLiquidity");
    //     assertEq(liquidity, 20 ether);
    // }

    function test__getUnwantedSlippageDueToNotEnoughLiquidity() public {
        //Liquidity provider adds 100 USDC and 100 USDT
        // within a price range of [0.5,2] considering
        // a tick spacing of 1
        //He wants his liquidiyt to be gaussian centered
        // around 1 USDC/USDT and with a standard deviation
        // of 0.5 USDC/USDT
        // We have
        //   Price Interval:[0.5,2] --> Tick Range: [-6932, 6931]
        //   tick spacing : 1
    }
}
