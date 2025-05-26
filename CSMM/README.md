# CSMM

Porque quiero construir una curva personalizada ?
R:/ La taxonomia de ciertos pares requiere curvas optimizadas para motivar a los agentes a participar en el mercado

- Caso especifico de CSMM
 -   Naturalmente los proveedores de liquidez racionales proveeran liquidez en rangos de precios minimos para pares estables, sin embargo el mecanismo de ajuste de curvatura de la curva de liquidez se ajusta (sin Hooks) a medida que los LP's proveen liquidez, a mas liquidez menos curvatura hasta el punto que hay tanta liquidez que la curva de liquidez refleja el grado real de sustituibilidad del par en cuestion , esto implica que mientras se llega a este estado (de no ser reforzado por un Hook(Una curva desde el principio diseñada para este caso especifico)) los comerciantes estan expuestos a impactos de precios (dar ejemplo practico de esto)

## Diseño de ejemplo

Supongase un Pool sin hooks de USDC, USDT
1. En un estado inicial  yo fijo mi precio en el PoolManager, mediante `manager.initialize(key, 1)`.
```solidity
function initialize(PoolKey memory key, uint160 sqrtPriceX96) external noDelegateCall returns (int24 tick)
``` 
Sin embargo no hay liquidez que habilite comercio en el mercado, entonces el comerciante no recibe nada a cambio:
`test__canNotTradeWithNoLiquidity()`
2. El otro caso es que alguien agregue liquidez en el rango correcto, pero llegue una orden mas grande que la liquidez agregada, en ese caso el trader recibira menos unidades del token que compra que las que deberia


Porque no utilizar AMM's como CURVE para ejecutar mis swaps
- R:/ 
  - Fragmentacion de liquidez: Quiero maximizar la cantidad de liquidez en un pool para aceptar mayores volumenes de comercio sin impacto de precio. Si la liquidez es fragmentada en diferentes pools, algunos tendran mas liquidez que otras, por los que un mercado puede aceptar ordenes mas grandes de comercio sin grandes impactos de precios, mientras que el otro esta rezagado, esto implica que los precios difieren entre ambos pools y comerciar en un mercado me da mejores precios que en otro (arbitraje -> ineficiencia de mercado)
    
    - Hacer simulacion con dos mercados conliquidez heterogenea donde esto suceda (un par estable es mas estable en un mercado que en otro)
    - Si refuerzo el uso de Uniswap V4 como AMM unico minimizo la ineficiencia de mercado (Hay riesgo de monopolios? ...)
 
[Swap Sequence Diagram](./docs/swapSequenceDiagram.excalidraw.png)
