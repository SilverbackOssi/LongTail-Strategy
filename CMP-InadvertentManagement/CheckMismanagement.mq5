

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
Progression sequence is predefine by a function, initiated on start. ☑️
Only one position can be open at a time. ☑️
Only two pending order can be present at a time. ☑️
All buy stops are to be placed 40points(grid spread) above the supposed price. Two consecutive buy stops will not be placed on the same price. ☑️
fatal error = unforeseen event.
For all positions and orders, their volume must be called from the progression sequence.