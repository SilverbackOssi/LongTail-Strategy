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