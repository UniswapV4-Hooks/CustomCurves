import math
import numpy as np

class Price:
    
    def __init__(self, price):
        self.price = price
    
    def toTick(self):
        return math.floor(math.log(self.price, 1.0001))

class TickRange:

    def __init__(self, start, end, tickSpacing):
        self.start = math.floor(start / tickSpacing)  
        self.end = math.floor(end / tickSpacing)
        self.tickSpacing = tickSpacing

class TickRanges:

    def __init__(self, TickRange):


class PriceInterval:

    def __init__(self, start, end):
        self.start = start
        self.end = end
        self.Price = Price
    
    def getTickRanges(self, tickSpacing):




    

if __name__ == "__main__":
    
    price = float(input("Enter price: "))
    p = Price(price)
    print(f"Tick: {p.toTick()}")




