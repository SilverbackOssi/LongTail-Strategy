//+------------------------------------------------------------------+
//|                                            PlaceRecoveryStop.mq5 |
//|                                      Copyright 2025, Anyim Ossi. |
//|                                          anyimossi.dev@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Anyim Ossi."
#property link      "anyimossi.dev@gmail.com"
#property version   "1.00"
#include <Trade\Trade.mqh>
CTrade trade;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
//bool EndSession = true;
bool EndSession = false;
int Sequence[]={1, 1, 2, 2, 3, 4, 5, 7, 9, 12, 16, 22, 29, 39, 52, 69, 92, 123,164, 218};
double grid_size = 2.00;
double grid_spread = 0.40;
int reward_multiplier = 5;
/*
### Recovery management(called) ☑️

→places one order *(opposite of the reference ticket type)*
```
def place continuation order(reference ticket)

    get ticket detail
    
    if ticket is open:
    
        order lot = next term of the sequence, relative to the reference(currently open) ticket
    
    else if ticket is a buy stop:
    
        order lot = reference ticket lot
    
    else: fatal error(unforeseen), return
    
    place pending order of type opposite to the ticket type
```
---

**buy stop as recovery position:** recovery buy stops are placed grid_spread higher than the short position’s stop loss.

**sell stop as recovery order:** recovery sell stops are placed on the stop loss of a long position or a buy stop (range delay)
*/