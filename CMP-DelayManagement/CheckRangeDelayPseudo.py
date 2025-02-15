
'''
// !function is trusted to understand why theres are tickets on the chart

// Goal: To set up range delay
// Description: 
//  When a range delay occurs, there will be two orders(or one outside daily session); 
//  the lagging continuation order and a recovery buy stop, initially.
//  We want to replace the continuation order with a recovery sell stop.
//  The last trade was sell and we're working on a buy stop;
//  the buy stop should have been opened but it was delayed.

def delay_update_grid():
    get no of tickets
    if theres an open position or no ticket: return //not a delay

    if last position was buy: return // to confirm its not a buy side continuation delay
    
    if no of ticket ==2 // continuation stop is present
        if distance between two ticket is <= than grid_size + grid_spread*2: return//range delay is already set

        if current price greater than half the the distance:// confirm its not a sell side continuation delay
            delete continuation sell stop
            get buy stop ticket
            call recovery on the buy stop //places a sell recovery order
    else if no of ticket ==1 // outside trading session
        call post_session_clean_up
        get buy stop ticket else return
        call recovery on the buy stop //places a sell recovery order
    else call mismanagement

'''
