//+------------------------------------------------------------------+
//|                                                   CheckRules.mq5 |
//|                                      Copyright 2025, Anyim Ossi. |
//|                                          anyimossi.dev@gmail.com |
//+------------------------------------------------------------------+
#include  <Ossi\LongTails\Utils.mqh>

string EA_TAG = "LongTailsScalper";


void OnTest()
  {

   EnforceStrategyRules();
  }

//+------------------------------------------------------------------+
// Controler funtion checks all rules.
void EnforceStrategyRules(CTrade &trader)
{
    // Call enforecers
    EnforceCoreRules(trader);
    //EnforceNoInterference(trader);
    //EnforceGridPlacementAccuracy(trader);

    // Call Checkers 
    CheckSLTP();
    //CheckVolumeAccuracy();
    //CheckSequenceAccuracy();
    
    // consider unseen edge cases
}
//+------------------------------------------------------------------+
void EnforceGridPlacementAccuracy(CTrade &trader)
{
    // check if orders are priced correctly, relative to open position
    // grid.target + grid.spread
}

void EnforceNoInterference(Grid &grid, CTrade &trader)
{
    // Handle human interference on Positions.
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        string symbol = PositionGetSymbol(i);
        if (symbol == _Symbol)
        {
            string comment = PositionGetString(POSITION_COMMENT);
            ulong ticket = PositionGetInteger(POSITION_TICKET);
            if (StringFind(comment, EA_TAG) == -1) // EA_TAG not found in comment
            {
                if (!trader.PositionClose(ticket))
                    Print(__FUNCTION__, " - Error: Failed to close foreign position with ticket: ", ticket);
                else
                    Print(__FUNCTION__, " - Closed foreign position with ticket: ", ticket);
            }
        }
    }

    // Handle human interference on Orders
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        ulong order_ticket = OrderGetTicket(i);
        if (order_ticket == 0) continue;
        if (OrderGetString(ORDER_SYMBOL) != _Symbol) continue;

        string comment = OrderGetString(ORDER_COMMENT);
        ulong ticket = OrderGetInteger(ORDER_TICKET);
        if (StringFind(comment, EA_TAG) == -1) // EA_TAG not found in comment
        {
            if (!trader.OrderDelete(ticket))
                Print(__FUNCTION__, " - Error: Failed to delete foreign order with ticket: ", ticket);
            else
                Print(__FUNCTION__, " - Deleted foreign order with ticket: ", ticket);
        }
    }

    // Enforce no interference on exits
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        string symbol = PositionGetSymbol(i);
        if (symbol == _Symbol)
        {
            ulong ticket = PositionGetInteger(POSITION_TICKET);
            double tp = PositionGetDouble(POSITION_TP);
            double sl = PositionGetDouble(POSITION_SL);
            double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
            double current_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            ENUM_POSITION_TYPE type = PositionGetInteger(POSITION_TYPE);

            // Supposed exits
            double corr_sl = NormalizeDouble(open_price - (type == POSITION_TYPE_BUY ? grid.unit : -grid.unit), _Digits);
            double corr_tp = NormalizeDouble(open_price + (type == POSITION_TYPE_BUY ? grid.target : -grid.target), _Digits);

            // Ensure SL and TP are within symbol limits
            double min_distance = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;
            if (MathAbs(corr_tp - current_price) < min_distance || MathAbs(current_price - corr_sl) < min_distance)
            {
                Print(__FUNCTION__, " - Warning: Corrected SL/TP for position with ticket ", ticket, " violates symbol stop limits. Skipping modification.");
                continue;
            }

            // Correct tampered exits
            if (tp != corr_tp || sl != corr_sl)
            {
                if (!trader.PositionModify(ticket, corr_sl, corr_tp))
                    Print(__FUNCTION__, " - Error: Failed to modify tampered position with ticket ", ticket);
                else
                    Print(__FUNCTION__, " - Modified tampered position with ticket ", ticket);
            }
        }
    }
}

void EnforceCoreRules(CTrade &trader)
{
    // Check positions excess
    if (PositionsTotal() > 1)
    {
        Print(__FUNCTION__, " - Fatal: More than one position open. Closing older");

        // Close all positions except the most recent one. Access by index.
        for (int i = PositionsTotal() - 1; i > 0; i--)
        {
            if (PositionSelectByIndex(i - 1))
            {
                ulong ticket = PositionGetInteger(POSITION_TICKET);
                if (!trader.PositionClose(ticket))
                    Print(__FUNCTION__, " - Error: Failed to close excess position with ticket: ", ticket);
                else
                    Print(__FUNCTION__, " - Closed excess position with ticket: ", ticket);
            }
        }
    }

    // Check orders excess
    if (OrdersTotal() > 2)
    {
        Print(__FUNCTION__, " - Fatal error: More than two orders open. Closing older");

        // Close all orders except the last two. Access by index.
        for (int i = OrdersTotal() - 1; i > 1; i--)
        {
            if (OrderSelect(i - 2, SELECT_BY_POS))
            OrderGetTicket(i-2)
            {
                ulong ticket = OrderGetInteger(ORDER_TICKET);
                if (!trader.OrderDelete(ticket))
                    Print(__FUNCTION__, " - Error: Failed to delete excess order with ticket: ", ticket);
                else
                    Print(__FUNCTION__, " - Deleted excess order with ticket: ", ticket);
            }
        }
    }

    // Check post-session lag, handled by session manager.
}
//+------------------------------------------------------------------+
// Check Stop loss and Take profit
void CheckSLTP()
{
    //Loop all open pos on symbol
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        string symbol = PositionGetSymbol(i);
        if (symbol == _Symbol)
        {
            double tp = PositionGetDouble(POSITION_TP);
            double sl = PositionGetDouble(POSITION_SL);
            
            // Check if TP and SL are set
            if (tp == 0 || sl == 0)
            {
                for (int j = 2; j >= 0; j-- )
                {Print(__FUNCTION__, " - Warning: TP/SL not set for position with ticket: ", PositionGetInteger(POSITION_TICKET));}
            }
        }
    }
}

// check volume of open position from sequence
void CheckVolumeAccuracy(const Grid &grid, const GridBase &base)
{
    // Check mathematical accuracy across all nodes

    // Check grid-base volume accuracy
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        string symbol=PositionGetSymbol(i);
        if (symbol == _Symbol)
        {
            double volume = PositionGetDouble(POSITION_VOLUME);
            int sequence[] = grid.progression_sequence;
            bool volume_ok = false;

            for (int j = 0; j < ArraySize(sequence); j++)
            {
                if (volume == sequence[j])
                {
                    volume_ok = true;
                    break;
                }
            }

            if (!volume_ok)
            {
                Print(__FUNCTION__, " - Warning: Volume for position with ticket: ", PositionGetInteger(POSITION_TICKET), " does not match any value in the progression sequence array.");
            }
        }
    }
    // check node volume accuracy
    
    // Check grid sequence accuracy

    // get recovery volume index
    // base volume should be -1
    // compare first term of sequence with continuation volume
}
// check that sequence is init accurate to account balance XXX
void CheckSequenceAccuracy(const Grid &grid)
{
    // calculate minimum term
    // compare minimum term with first term of progression sequence
}
