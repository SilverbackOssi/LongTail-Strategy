// ALL THE CODE THAT ENSURES STRATEGY GUIDELINES ARE ADHERED

void check_strategy_rules()
{
    //-> raises warning  
    check_core_rules();
    check_risk_rules();
    // check forgotten position
    // - outside trading session - progression cycle just closed - a recovery order is still pending
}

void check_core_rules()
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

    // check if orders are misplaced and properly spread relative to open position

    

    // comment order has been replaced in the appropriate func.
}

void check_risk_rules()
{
    // check that sequence was init accurately
    // check tp/sl is set
    // check volume of open position from sequence
}
