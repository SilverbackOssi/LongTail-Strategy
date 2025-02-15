

// !confirm its not continuation delay
// !function is trusted to understand why theres are tickets on the chart
// # this function is trusted to run all confirmations before executions

// Goal: To set up range delay
// Description: 
// When a range delay occurs, there will be two orders; 
//  the lagging continuation order and a recovery buy stop, initially.
//  We want to replace the continuation order with a recovery sell stop.

// define a delay range: last trade was sell and we're working on a buy stop
//  - meaning the buy stop should be open but it was delayed

def delay_update_grid():
    if theres an open position: return
    
    get no of tickets
    if no ticket: return

    if last position was buy: return //not a range delay, its continuation delay
    
    if no of ticket ==2
        if distance between two ticket is greater than internal_grid_size + grid_spread://range delay is yet to be set up
            if current price greater than half the the distance(make sure its not a sell side continuation delay):
                delete lagging sell stop //should be continuation}
                confirm recovery buy stop with grid size because of delay outside session!!!
                call recovery on the buy stop //places a sell recovery order
    else if no of ticket ==1 // outside trading session
        confirm
        call recovery on the buy stop //places a sell recovery order
    else call mismanagement

