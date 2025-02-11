

void check_mismanagement()
{
    // Check if there is more than one position
    if (PositionsTotal() > 1)
    {
        Print(__FUNCTION__, " - Fatal error: More than one position open.");
        ExpertRemove(); // Close the bot
        return;
    }

    // Check if there are more than two orders
    if (OrdersTotal() > 2)
    {
        Print(__FUNCTION__, " - Fatal error: More than two orders open.");
        ExpertRemove(); // Close the bot
        return;
    }
}


void check_strategy_rules()
-> raises warning  
check that sequence is corresponding to account balance
call check_mismanagement
All buy stops are to be placed 40points(grid spread) above the supposed price. Two consecutive buy stops will not be placed on the same price. ☑️
check that buy stops are place grid_spread higher than stop losses, 
check that all positions and orders have their volume from the defined sequence 