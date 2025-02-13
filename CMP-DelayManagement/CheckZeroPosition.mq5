### Zero position management(logic) ☑️

//manages all delay
//reasons: outside trading time, a position just closed leaving a delay, fatal error(unforeseen)
```
if there are no open positions:

    if two tickets, zero open position(delay): 

        call delay management

        return

    if outside daily session: 

        reset relevant params(currently none)

        if pending ticket: delete, log what you deleted

        return (the entire tick)

    else: fatal error log current terminal status[no of open positions etc. for journal]
```