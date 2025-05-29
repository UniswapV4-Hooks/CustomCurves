# Analysis of DiamondsX


# NoOP Hooks for Custom Curves

## Design Standards


### `beforeSwapReturnDelta`: 

- **Enables** the ability to partially, or completely:
  
  - `bypass the core swap logic of the pool manager --> takes care of the swap request itself inside beforeSwap`

### `afterSwapReturnDelta`: 

- **Enables** the ability to:

-  Extract tokens to keep for itself from the swap's output amount

-  Ask the user to send more than the input amount of the swap:

   -  Additonal tokens going to the hook
   -  Additonal tokens going to the swap's output amount for the user

### `afterAddLiquidityReturnDelta & afterRemoveLiquidityReturnDelta`: 

- **Enables** the ability to:
  
  -  Charge the user an additional amount over what they're adding as liquidity
  
  - Send them some tokens


### `BalanceDelta VS BeforeSwapDelta`

| Feature                 | BalanceDelta                                                               | BeforeSwapDelta                                                               |
| ----------------------- | -------------------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| **Definition**          | Type returned from `swap` and `modifyLiquidity`                            | Type that can be returned from `beforeSwapReturnDelta` (`beforeSwap`)         |
| **Structure**           | `int256 BalanceDelta = int128 dx                                           | int128 dy`                                                                    | `int256 BeforeSwapDelta = int128 d_spec | int128 d_Unspec` |
| **Token Meaning**       | First delta: X, Second delta: Y                                            | First delta: specified token (can be X or Y), Second delta: unspecified token |
| **Context**             | Used to represent changes after swap or liquidity modification             | Used to potentially override swap logic before the swap occurs                |
| **User Responsibility** | User must account for this delta to receive/pay tokens to/from PoolManager | Used by hooks to specify custom swap deltas before core logic                 |
| **Sign of Value**       | Positive: owed to trader; Negative: owed to pool                           | Depends on swap direction and specification (see explanation below)           |
| **Usage Example**       | `user ==> poolManager.BalanceDelta = (dx + user.dx, dy + user.dy)`         | `d_spec`: delta of specified token; `d_Unspec`: delta of unspecified token    |
| **Swap Direction**      | Always X and Y                                                             | Specified token depends on swap type (zeroForOne, exact input/output, etc.)   |

*Note: In BeforeSwapDelta, the specified token is determined by the swap direction and whether the swap is exact input or output. See explanation above for details.*




- `BalanceDelta`: The first delta representing X and the second delta representing Y
  
- `BeforeSwapDelta`: The first delta is for the specified token - which can be, but is not necessarily, X, and the second delta is for the unspecified token - which can be, but is not necessarily, Y.

### `BalanceDelta`

- **type** returned from `swap` and `modifyLiquidity`

- `int256 BalanceDelta = int128 dx | int128 dy`

```typescript

user.swap(user.dx, user.dy) | user.modifyLiquidity(user.dx, user.dy)
      
      user ==> poolManager.BalanceDelta = (dx + user.dx, dy + user.dy)
==>
      hook ==> hook.BalanceDelta =  (dx + user.dx, dy + user.dy)
```
- **User's responsibility** is to account for this balance delta and receive the tokens it's supposed to receive, and pay the tokens it's supposed to pay, from and to the PoolManager.


```typescript

// ==========================afterSwap.BalanceDelta===============:

//  POSITIVE: Amount owed to TRADER is it always the trader router?
//  NEGATIVE Amount owed to the POOL

/// @return Hook.BalanceDelta.amount.UnspecifiedCurrency

//      POSITIVE: Hook is owed/took amount of Unspecified of urrency, 
//      NEGATIVE: Hook owes/sent amount of UnspecifiedCurrency

function afterSwap(
    BalanceDelta deltaIn
) external returns (int128 deltaOut);

```

### `BeforeSwapDelta`

- **type** that _can be_ returned from `[beforeSwapReturnDelta]beforeSwap`

- `int256 BeforeSwapDelta = int128 d_spec | int128 d_Unspec`

    - `d_spec (zefoForOne)`: 

      - delta amount of the token which was "specified" by the user.
  
      - **specified**
        
        - **Exact Input Zero for One = (zeroForOne = true & amountSpecified < 0)**
  
          - Specifying an amount of X to exactly take out of the user's wallet to use for the swap. In this case, then, the "specified" token is X.
  
        - **Exact Output Zero for One= (zeroForOne = true & amountSpecified > 0)**
  
            - Specifying an amount of Y to exactly receive in the user's wallet as the output of the swap. In this case, the "specified" token is therefore Y.

    - `d_Unspec (zefoForOne)`:








# Upgradable Curves with Upgradable Patterns


- How to implement `EIP'S`:
  - Beacons
  - Diamonds
