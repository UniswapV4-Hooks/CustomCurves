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




# Upgradable Curves with Upgradable Patterns


- How to implement `EIP'S`:
  - Beacons
  - Diamonds
