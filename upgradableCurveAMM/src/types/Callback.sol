// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;
pragma abicoder v2;

import {PoolKey} from "v4-core/types/PoolKey.sol";
import "v4-core/types/PoolOperation.sol";

struct Callback {
    address sender;
    PoolKey key;
    ModifyLiquidityParams liquidityParams;
    SwapParams swapParams;
    bytes hookData; // The only available hookdata is
    //something that decodes to ICustomCurveAMMDiamond.setCustomCurve(faucet)
    bool settleUsingBurn;
    bool takeClaims;
}

library CallbackLibrary {
    function validateHookdata(
        Callback memory callback
    ) internal pure returns (bool isValid) {
        // This function verifies if the hookData is a valid request
        // then if abi.encode(swapParams) == "":
        // it assumes it is a liquidity request
        // In this case:
        // hookData = abi.encodeWithSelector(ICustomCurveAMMDiamond.setCustomCurve(address))
        // If that is the case then the hookData is valid
        // else if abi.encode(swapParams) != "":
        // it assumes it is a swap request
        // In this case:
        // hookData = abi.encodeWithSelector(ICustomCurveAMMDiamond.setCustomCurve(address))
        // If that is the case then the hookData is valid
    }
}
