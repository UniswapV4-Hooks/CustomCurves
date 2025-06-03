

- The LP router sneds a modifiLiquidity Request


## `Liquidity Router`

```solidity
function modifyLiquidity(
    PoolKey memory key,
    ModifyLiquidityParams memory params,
    bytes memory hookData,
    bool settleUsingBurn,
    bool takeClaims
) public payable returns (BalanceDelta delta) {
    // ...

    (BalanceDelta delta,) = manager.modifyLiquidity(data.key, data.params, data.hookData);
    // ...
}
```

## `Pool Manager`

```solidity
function modifyLiquidity(
    PoolKey memory key,
    ModifyLiquidityParams memory params, 
    bytes calldata hookData
    ) external onlyWhenUnlocked noDelegateCall 
returns (BalanceDelta callerDelta, BalanceDelta feesAccrued){
    //..
    key.hooks.beforeModifyLiquidity(key, params, hookData);
    //..
}
```

## `Custom Curve Hook`

```solidity
function beforeAddLiquidity(
    address sender,
    PoolKey calldata key,
    ModifyLiquidityParams calldata params,
    bytes calldata hookData
) external pure override returns (bytes4) {
    // ..
    if (valid(hookData)){
        
        poolManager.unlock(
                abi.encode(
                CallBackData({
                    sender: sender
                    PoolKey: key,
                    params: params,
                    hookData: hookData,
                    settleUsingClaims: true,
                    takeClaims: true
                })
            )
        );
    }
    
}
```

## `Pool Manager`


```solidity
function unlock(
    bytes calldata data
) 
external override returns (bytes memory result) 
{
        // ..
result = IUnlockCallback(msg.sender).unlockCallback(data);
// ..
}
```

## `Custom Curve Hook (COMMAND UPGRADABLE)`

```solidity
function unlockCallback(
    bytes calldata rawData
)
external onlyPoolManager returns (bytes memory) {
CallbackData memory data =
          abi.decode(rawData, (CallbackData));
    
data.hookData =  
    ICustomCurveAMM(facetAddress).modifyLiquiditySelector 
// POOL MANAGER STORES THE LIQUIDITY
// BUT CustomCurveImplementation Liquidity Manager OWNS LIQUIDITY
if (data.settleUsingClaims ==true && data.takeClaims.true){
    
    data.hookData.settleTake(rawData);
    
    // NOW WE HAVE TO ROUTE THE LIQUIDITY PARAMS TO THE
    // CORRESPONDING CUSTOM CURVE LIQUIDITY POOL
    // THIS IS SIGNALED BY THE HOOK DATA
    // WHICH HAS TO FOLLOW CERTAIN SPECS TO BE VALID
    
    data.hookData.modifyLiquidity(data.params,data.key);
}


} 
```

Then we need to do a couple of things.

- How to validate if `hookData` is valid, this is

`hookData decodes to ICSMM(facetAddress).modifyLiquidity(data.params, data.key)`

With this `CustomCurveHookCommandDiamond` routes the liquidity provision to be handled by the specific `CustomCurveImplementation(facetAddress)`