//+------------------------------------------------------------------+
//|                                            StrictRuleManager.mqh |
//|                                      Copyright 2025, Anyim Ossi. |
//|                                          anyimossi.dev@gmail.com |
//+------------------------------------------------------------------+
#ifndef RuleManager_MQH
#define RuleManager_MQH

#property copyright "Copyright 2025, Anyim Ossi."
#property link      "anyimossi.dev@gmail.com"

#include  "GridManager.mqh" // COMMING SOON

//+------------------------------------------------------------------+
// CONTROLLER FUNCTION, CHECKS ALL RULES
void EnforceCoreRules(CTrade &trader, GridInfo &grid, GridBase &base)
{
    int max_allowed_positions = MAX_POSITIONS;
    int max_allowed_orders = MAX_ORDERS;

    NoInterferenceOnPos(trader);
    NoInterferenceOnOrders(trader);
    EnforceExits(grid, trader);

    EnforceMaxOrders(trader,max_allowed_orders);
    EnforeMaxPosition(trader,max_allowed_positions);
    //CheckGridPlacementAccuracy(blah);
}
//+------------------------------------------------------------------+

/*
Closes any position not placed by the EA.
Does not replace closed positions.
*/
void NoInterferenceOnPos(CTrade &trader){
    for (int i = PositionsTotal() - 1; i >= 0; i--){
        string symbol = PositionGetSymbol(i);
        if (symbol == _Symbol){
            string comment = PositionGetString(POSITION_COMMENT);
            ulong ticket = PositionGetInteger(POSITION_TICKET);
            if (StringFind(comment, EA_TAG) == -1){
                // EA_TAG not found in comment
                if (!trader.PositionClose(ticket))
                    Print(__FUNCTION__, " - Error: Failed to close foreign position with ticket: ", ticket);
                else
                    Print(__FUNCTION__, " - Closed foreign position with ticket: ", ticket);
                int retries = 10; // Retry up to 10 times (10* 100ms = 1s)
                while (PositionSelectByTicket(ticket) && retries > 0){
                    retries--; Sleep(100); // Check every 100ms
                }
            }
        }
    }
}
//+------------------------------------------------------------------+

/*
Deletes any order not placed by the EA.
Does not replace deleted orders.
*/
void NoInterferenceOnOrders(CTrade &trader){
    for (int i = OrdersTotal() - 1; i >= 0; i--){
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
            int retries = 10; // Retry up to 10 times (10* 100ms = 1s)
            while (OrderSelect(ticket) && retries > 0){
                retries--; Sleep(100); // Check every 100ms
            }
        }
    }
}
//+------------------------------------------------------------------+

/* 
This module ensures appropriate risk management as per the LTS strategy.
Sets Stoploss and Takeprofits on all positions on the current symbol.
*/
void EnforceExits(GridInfo &grid, CTrade &trader){
    // Enforce no interference on exits(SL/TP) on all open positions
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if (PositionGetSymbol(i) == _Symbol)
        {
            ulong ticket = PositionGetInteger(POSITION_TICKET);
            if (!ticket) continue;
            double tp = PositionGetDouble(POSITION_TP);
            double sl = PositionGetDouble(POSITION_SL);
            double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
            double current_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

            // Supposed exits
            double corr_sl = NormalizeDouble(open_price - (type == POSITION_TYPE_BUY ? grid.unit : -grid.unit), _Digits);
            double corr_tp = NormalizeDouble(open_price + (type == POSITION_TYPE_BUY ? grid.target : -grid.target), _Digits);

            // Ensure SL and TP are within symbol limits
            double min_distance = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;
            if (MathAbs(corr_tp - current_price) < min_distance || MathAbs(current_price - corr_sl) < min_distance)
            {
                Print(__FUNCTION__, " - Warning: Corrected SL/TP for position with ticket ", ticket, " violates symbol stop limits. Skipping modification.");
                continue;
            }

            // Modify with correct exits
            if (tp != corr_tp || sl != corr_sl)
            {
                if (!trader.PositionModify(ticket, corr_sl, corr_tp))
                    Print(__FUNCTION__, " - Error: Failed to modify inaccurate exits on position with ticket ", ticket);
                else
                    Print(__FUNCTION__, " - Modified inaccurate exits on position with ticket ", ticket);
            }
        }
        else Print("LTSGold does not support multiple symbols yet.");
        // Ideally, close the position.
    }
}
//+------------------------------------------------------------------+

/*
Ensures there is only required no of open position in the chart.
Closes all, except the last opened position(s).
*/
void EnforeMaxPosition(CTrade &trader, int max_pos){
    if (PositionsTotal() > max_pos){
        Print(__FUNCTION__, " - Fatal: More than ", max_pos, " position open. Closing older");

        // Close all positions except the most recent one. Accessed by index.
        for (int i = PositionsTotal() - 1; i > (max_pos-1); i--){
            if (PositionGetTicket(i-max_pos)){
                ulong ticket = PositionGetInteger(POSITION_TICKET);
                if (!trader.PositionClose(ticket))
                    Print(__FUNCTION__, " - Error: Failed to close excess position with ticket: ", ticket);
                else
                    Print(__FUNCTION__, " - Closed excess position with ticket: ", ticket);
                int retries = 10; // Retry up to 10 times (10* 100ms = 1s)
                while (PositionSelectByTicket(ticket) && retries > 0){
                    retries--; Sleep(100); // Check every 100ms
                }
            }
        }
    }
}
//+------------------------------------------------------------------+

/*
Ensures there is only required no of pending orders in the chart.
Closes all, except the last opened pending order(s).
*/
void EnforceMaxOrders(CTrade &trader, int max_pending){
    // Check orders excess
    if (OrdersTotal() > max_pending){
        Print(__FUNCTION__, " - Fatal error: More than ", max_pending, " orders open. Closing older orders..");

        // Close all orders except the last two. Access by index.
        for (int i = OrdersTotal() - 1; i > (max_pending-1); i--){
            if (OrderGetTicket(i-max_pending)){
                ulong ticket = OrderGetInteger(ORDER_TICKET);
                if (!trader.OrderDelete(ticket))
                    Print(__FUNCTION__, " - Error: Failed to delete excess order with ticket: ", ticket);
                else
                    Print(__FUNCTION__, " - Deleted excess order with ticket: ", ticket);
                int retries = 10; // Retry up to 10 times (10* 100ms = 1s)
                while (OrderSelect(ticket) && retries > 0){
                    retries--; Sleep(100); // Check every 100ms
                }
            }
        }
    }
}
//+------------------------------------------------------------------+

/*
Check if orders are priced correctly(or deleted), relative to an open position.
Alert, if otherwise.
Handles only position based nodes.
Assumes other rules have been called.
*/
void CheckGridPlacementAccuracy(GridInfo &grid, CTrade &trader){
    if (PositionSelect(_Symbol)){
        // get the base details by selecting open position
        ulong base_ticket = PositionGetTicket(0);
        double base_open = PositionGetDouble(POSITION_PRICE_OPEN);
        long base_type = PositionGetInteger(POSITION_TYPE);

        // calculate correct recovery node// open_price - grid.unit for buy position
        // calculate correct continuation node// open_price + grid.target + grid.spread for buy position

        // if not NodeExistsAtPrice, clear corresponding node and call place corresponding
    }
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//XXX: Implement remote stopping of the bot; use strange order like buystoplimit, moving on, open communication via telegram
//XXX: Check if request to stop bot first.
//--- check for strange order like buystoplimit
//--- set USE_SESSION to true and set SESSION_OVER.
//--- use endsession() to clear continuation orders, allow progression cycle to end.
// Later use http through tel or whatsapp
//+------------------------------------------------------------------+

#endif // RuleManager_MQH
