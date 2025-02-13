# Documentation 
LongTails is modified version of the Remora strategy, designed to capitalize on trends and last through ranges. Parent versions were based on a 1:1 reward system, but this is a 1:R; where R is greater that 1. For this study our focus is on 1:3.

### Strength and weaknesses (why it works and why it doesn't)

Like every other MarketCrusher, LongTails thrives in a trending market and dies in a ranging market. This model seems to outlive other models in ranging markets although we’re yet to discover the maximum range it survives.

### Dependencies and Market analysis

- none

### **Scope**

- Study was performed on XAU/USD pair, hence **grid_spread** = 40*points*
- Potentially Volatility 75 and 75(1s)

### Entry rules

- set trading time(daily session)
    - Start time = 7:30am
    - EndSession = False

### Exit rules

- end of trading day, no new cycle.
    - End time = 5:30pm
    - EndSession = True(default)

### Worrisome events

These events create unforeseen circumstances 

- Slippage
- Spread

### Caution

- ensure no continuation outside daily session. ☑️

# LongTails Progression

- **General rules**
    1. Progression sequence is predefine by a function, initiated on start. ☑️
    2. *Only one position can be open at a time.* ☑️
    3. *Only two pending order can be present at a time.* ☑️
    4. *All buy stops are to be placed 40points(grid spread) above the supposed price. Two consecutive buy stops will not be placed on the same price.* ☑️
    5. *fatal error = unforeseen event.*
    6. *For all positions and orders, their volume must be called from the progression sequence.*
- **What is a progression cycle?**
    
    *All the trades it takes to hit TP once.*
    
    *Each cycle is independent from predecessors, but references position type and volume only.*
    
- **Assumptions**
    - ***The grid is either progressing or in a range***
- **Likely events within a progression cycle?**
    - Range response: *The grid moves upward in response to a range i.e. the buy stop is placed grid_spread higher than the stop loss of the short position or take profit of a long position* ☑️
    - Range delay:  *Price may be within a range and hit range ceiling but not trigger a buy stop because of our range response, therefore there’s no open position but two pending orders.*☑️
    - Continuation delay:  *price may hit take profit and not trigger a new position because of our range response, leaving us with no open position and two pending orders(tap and reverse response).* ☑️
    - Tap and reverse: *A pending order might be triggered by spread when a position is still open therefore leaving two active positions. Sometimes the older positions reverses and closes a loss, leaving us with two grudges to deal with a creating chaos in the system.* ☑️
    - Misplaced orders: *An order may be left mis-priced as the grid progresses or ranges, due to slippage(all orders needs to be renewed as grid moves).* ☑️
    - Forgotten order: *An order may be forgotten after a daily session ends, leading to unintended outcomes.*☑️
    - Replacement order: *during range delay a continuation order is to be removed and replaced by a recovery order.* ☑️
    - Carry over: *some market days are slow, those days we dont hit daily target. running progression cycles are held running unto the next day.* ☑️

- **Risk management rules**
    - Ensure progression sequence is accurate and relative to account balance. 🏁
    - Ensure lot sizes are pricked properly from the sequence. 🏁
    - Ensure take profit and stop loss is set on all positions.🏁

---

## Requirements

### Daily sessions management(CORE) ☑️☑️
```
if Outside trading time:
    EndSession = True
    delete non recovery orders
    return 
else:
    EndSession = False

    if an order or a position is on the chart:
        #a progression cycle is still running
        return
    else:
        open a short position at market price
        
```
### New position management(logic)☑️☑️
```
saved ticket = 0 #default
def check new position():
    if position is open
        get open positons ticket
        if saved ticket ≠ open positions ticket:
            call set exits
            
            delete all pending orders.
            
            call recovery.
            
            call continuation.
            
            update stored ticket to open ticket
```
### Inadvertent event management(logic)☑️
```
if there are more than one positions

    raise fatal error, close bot. log event.

if there are more that two orders:

    raise fatal error, close bot. log event.
```
### Zero position management(logic) ☑️

*manages all delay*

reasons: outside trading time, a position just closed leaving a delay, fatal error(unforeseen)
```
if there are no open positions:

    # reason : a position just closed within trading time leaving a delay
    if there are two tickets: # theres a delay 

        call range delay management

        return
    # reason: outside trading time
    if use_daily_session and EndSession: 

        # reset relevant params, currently none
        if theres a ticket:
            Delete any order whose comment does not contain 'recovery', log what you deleted
        
            call range delay management
        
        return
    # reason: fatal error,unforeseen event
    else: fatal error log current terminal status #number of open positions etc. for journaling
```

### Range delay management(logic)☑️

→To set up range delay

*When a range delay occurs, there will be two orders; the lagging continuation order and a recovery buy stop, initially. We want to replace the continuation order with a recovery sell stop.*
```
# this function is trusted to run all confirmations before executions
def check range delay():
    if last position was buy: return (not a range delay, its continuation delay)

    if distance between two ticket is greater than internal_grid_size + grid_spread:(range delay is yet to be set up)

        if current price greater than half the the distance(make sure its not a sell side continuation delay):

            delete lagging sell stop
            {should be continuation}

            confirm recovery buy stop with grid size because of delay outside session!!!

            *call recovery on the buy stop(*place sell recovery order)
```
### Exit management(called)☑️☑️
→Sets take profit and stop loss on an open position
```
def set exits(position ticket, grid_size, reward multiplier)
    get ticket details

    determine tp and sl

    modify open position
```

### Recovery management(called) ☑️☑️

→places one order *(opposite of the reference ticket type)*
```
def place recovery order(reference ticket)

    if ticket is open:
        get ticket detail
        check if stop loss present
        
        order lot = next term of the sequence, relative to the reference(currently open) ticket
    
    else if ticket is a buy stop:
    
        order lot = reference ticket lot
    
    else: fatal error(unforeseen), return
    
    place pending order of type opposite to the ticket type
```
---

**buy stop as recovery position:** recovery buy stops are placed grid_spread higher than the short position’s stop loss.

**sell stop as recovery order:** recovery sell stops are placed on the stop loss of a long position or a buy stop (range delay)

### Continuation management(called) ☑️☑️

→*places one order (continuation order) relative to open positions, during trading time*
```
def place continuation order(reference ticket)

    if EndSession: return
    
    if ticket is still open:
        get ticket details
        check if take profit is set

        get lot size as first term of the progression sequence
        
        check if order already exists
        place a stop order similar to the open position’s type
    
    else: fatal error
```
---

**buy stop as continuation position:** continuation buy stops are placed grid_spread higher than the long position’s take profit.

**sell stop as continuation order:** continuation sell stops are placed on the take profit of a short position.

### Sequence builder(called) ☑️☑️
```
def Initialize progression sequence(reward multiplier)

- Ensure lot sizes(lot progression sequence) are accurate
- relative to account balance 🏁 (not yet, we use symbol minimum volume)

return an array with progression sequence.
```
---
## Utility functions

- Rules enforcer utils
- delete all pending orders, if there are orders.
- fatal error(error location, error message). removes bot and reports event.

## Session report logging

report to telegram daily.

Post-daily_session logging. 11:30pm

- log all closed positions(position is closed if ticket cannot be selected)
- Log the total number of progression cycles. (account for running progressions if any)
- log total  trading time.
- Log percentage profit or loss of the day.

### To-Do

- [ ]  Confirm all functions take args and not reference global vars, and are passed by reference when updates are needed
- [ ]  List all utillity funcs
- [ ]  observe live trading for more unaccounted events.
- [ ]  test without continuation range, it might be unnecessary.
- [ ]  Include image description
- [ ] Code for all activities to be logged; position open/close, order open/close, minagements and sessions, etc.
- [ ] Handle failed buys, sells, etc
- [ ] Include docstrings for all functionalities
- Script to detect skippages between two 15m candles, price must fill, 1:2 - camera photo on 12 feb.2025
- confirm short scalps strategy idea - screen shot on 13th feb.2025
