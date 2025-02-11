

void check_mismanagement()
{
    // Check if there is more than one position
    if (PositionsTotal() > 1)
    {
        Print(__FUNCTION__, " - Fatal error: More than one position open. Removing expert");
        ExpertRemove(); // Close the bot
        return;
    }

    // Check if there are more than two orders
    if (OrdersTotal() > 2)
    {
        Print(__FUNCTION__, " - Fatal error: More than two orders open. Removing expert");
        ExpertRemove(); // Close the bot
        return;
    }
}


void check_strategy_rules(){
-> raises warning  
check that sequence is corresponding to account balance
call check_mismanagement
check that buy stops are place grid_spread higher than stop losses, take profits, and sell stops
check that all positions and orders have their volume from the defined sequence 
}