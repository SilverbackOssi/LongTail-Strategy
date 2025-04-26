//+------------------------------------------------------------------+
//|                                                   CheckRules.mq5 |
//|                                      Copyright 2025, Anyim Ossi. |
//|                                          anyimossi.dev@gmail.com |
//+------------------------------------------------------------------+
// ALL THE CODE THAT ENSURES STRATEGY GUIDELINES ARE ADHERED

void OnTest()
  {

   check_strategy_rules();
  }
//+------------------------------------------------------------------+


void check_strategy_rules()
{
    //-> raises warning  
    check_core_rules();
    check_risk_rules();
    check_forgotten_order();
    
    // consider unseen edge cases
}

void check_core_rules() //mFATAL
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

}

void check_risk_rules()
{
    // check that sequence is init accurate to account balance XXX
    // check tp/sl is set
    // check volume of open position from sequence

    // Loop through all open positions
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        string symbol=PositionGetSymbol(i);
        if(symbol!="")
        {
            double tp = PositionGetDouble(POSITION_TP);
            double sl = PositionGetDouble(POSITION_SL);
            double volume = PositionGetDouble(POSITION_VOLUME);

            // Check if TP and SL are set
            if (tp == 0 || sl == 0)
            {
                Print(__FUNCTION__, " - Warning: TP/SL not set for position with ticket: ", PositionGetInteger(POSITION_TICKET));
            }

            // Check that the volume matches one of the values in the Sequence array
            bool volume_ok = false;
            for (int j = 0; j < ArraySize(Sequence); j++)
            {
                if (volume == Sequence[j])
                {
                    volume_ok = true;
                    break;
                }
            }

            if (!volume_ok)
            {
                Print(__FUNCTION__, " - Warning: Volume for position with ticket: ", PositionGetInteger(POSITION_TICKET), " does not match any value in the Progression sequence array.");
            }
        }
    }

}

void check_forgotten_order()
{
    // Ensure that the session has ended and there are no open positions
    if (is_end_session == false || PositionSelect(_Symbol)) return;
    
    // Check if there is only one pending order
    if (OrdersTotal() == 1)
    {   
        ulong order_ticket = OrderGetTicket(0);
        if (order_ticket != 0)
        {
            double order_price = OrderGetDouble(ORDER_PRICE_OPEN);
            ulong order_ticket = OrderGetInteger(ORDER_TICKET);
            string order_comment = OrderGetString(ORDER_COMMENT);

            // Get the current market price
            double current_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);

            // Calculate the distance relative to grid_size and grid_spread
            double threshold = grid_size + grid_spread * 2;
            double distance = MathAbs(current_price - order_price);

            // If the price is far from the order
            if (distance > threshold)
            {
                {
                Print(__FUNCTION__, " - Warning: Found 1 forgotten order: ",order_ticket,"with comment: ",order_comment);
                }
            }
        }
    }
}
