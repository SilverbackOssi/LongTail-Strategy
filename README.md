
LongTails is modified version of the Remora strategy, designed to capitalize on trends and last through ranges.
Parent versions were based on a 1:1 reward system, but this is a 1:R; where R is greater that 1.

### Strength and weaknesses (why it works and why it doesn't)

Like every other MarketCrusher, LongTails thrives in a trending market and dies in a ranging market. This model seems to outlive other models in ranging markets although we’re yet to discover the maximum range it survives.

### Dependencies and Market analysis

- none

### **Scope**

- Study was performed on XAU/USD pair, hence **grid spreading** = 40*points*

### Entry rules

- set trading time(daily session)
    - Start time = 7:30am
    - End time = 7:30pm
    - EndSession = False

### Exit rules

- end of trading day, no new cycle.
    - EndSession = True

# LongTails Progression

- **General rules**
    1. *The progression manager sets pending positions.* 
    2. *Only one position can be open at a time.*
    3. *Only two pending order can be present at a time.*
    4. *All buy stops are to be spread 40points above the supposed price. Two consecutive buy stops cannot be placed on the same price.*
- **What is a progression cycle?**
    
    *All the trades it takes to hit TP.*
    
- **Likely events within a progression cycle?**
    - ***The grid is either progressing or in a range***
    - Consecutive losses and Range response: *The grid moves upward in response to a range i.e. the buy stop is placed 40points higher than the previous buy stop.*
    - Range delay:  *Price may be within a range and hit range ceiling but not trigger a buy stop because of our range response, therefore there’s no open position.*
    - Tap and reverse: *A pending order might be triggered by spread when a position is still open therefore leaving two active positions. Sometimes the older positions reverses and closes a loss, leaving us with two grudges to deal with a creating chaos in the system.*
    - Misplaced orders: *An order may be left mis-priced as the grid progresses or ranges, due to slippage.*
    - Forgotten order: *An order may be forgotten after a daily session ends, leading to unforeseen outcomes.*
    - ***Grid orders should be updated on every new grid event (position open or close)***

---

## Progression manager

### Daily sessions management
```
if EndSession == False:
  if Outside trading time:
    def session stoper (run if EndSession == False and Outside trading time)
      EndSession = True

else if Within trading time:
  def session starter (run if 1. EndSession == True and 2. Within trading time)
    EndSession = False
    if a progression cycle is currently running (carried over from previous day)
      return
    (check if to buy or sell) open the position
```

### place pending positions accordingly (ensure to pick the accurate volume from sequence)

(recovery order) (continuation order)

on new cycle (win)

on fail

during end session

### delete pending position accordingly

### manage range response and delay

move buy stop in response, replace sell stop in delay.

## Risk management rules

- I ensure my lot sizes are accurate
- set progression sequence relative to account balance
- update progression sequence relative to account balance
- 

## Session report rules

how i log my activities within each trading day
