
//manages all delay

void check_zero_position()
{
if there are no open positions:
    # reason : a position just closed within trading time leaving a delay
    if there are two tickets: # theres a delay 
        call range delay management
        return
    
    # reason: outside trading time
    if use_daily_session and EndSession: 

        
        # reset relevant params, currently none
        if theres any ticket:
            Delete any order whose comment does not contain 'recovery', log what you deleted
            call range delay management
            // clean up after complete progression cycle
        return
    # reason: fatal error,unforeseen event
    else: fatal error log current terminal status #number of open positions etc. for journaling
}

void post_session_clean_up()
{
    if end_session == false or theres open position: return

    if there is one orders:
        get the pending order details
        if price is far from the order(relative to grid_size + grid_spread * 2), delete the order, log

}