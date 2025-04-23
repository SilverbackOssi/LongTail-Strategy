//+------------------------------------------------------------------+
//|                                              CheckRangeDelay.mq5 |
//|                                      Copyright 2025, Anyim Ossi. |
//|                                          anyimossi.dev@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Anyim Ossi."
#property link      "anyimossi.dev@gmail.com"
#property version   "1.00"
#include <Trade\Trade.mqh>
CTrade trade;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
double grid_size = 2.00;
double grid_spread = 0.40;
ENUM_POSITION_TYPE last_saved_type = POSITION_TYPE_SELL;
bool is_end_session = false; // false if session is active(default)
bool use_daily_session = false; // trade 24/7 if false

void OnStart()
  {
//---
   check_zero_position();
  }
//+------------------------------------------------------------------+

void check_zero_position()
{
    // reason1: a position just closed within trading time leaving a delay
    // reason2: outside trading time
    // reason3: fatal error, unforeseen event, log status

    if (PositionSelect(_Symbol)) return;

    if (use_daily_session) post_session_clean_up();

    check_range_delay();
}

void check_range_delay()
{
    int orders_total = OrdersTotal();

    // If there is an open position or no pending orders, return (not a delay)
    if (PositionSelect(_Symbol) || orders_total == 0) return;
    
    // If the last position was a buy, return (not a range delay)
    if (last_saved_type == POSITION_TYPE_BUY) return;
    
    // Variables to store order prices and tickets
    double price1 = 0.0, price2 = 0.0;
    ulong buy_stop_ticket = 0, sell_stop_ticket = 0;

    if (orders_total == 2) // Continuation stop is present
    {
        // get pending orders details
        for (int i = orders_total - 1; i >= 0; i--)
        {
            ulong order_ticket = OrderGetTicket(i);
            if (order_ticket != 0)
            {
                if (OrderGetString(ORDER_SYMBOL) != _Symbol)
                    continue;

                ENUM_ORDER_TYPE order_type = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
                double price = OrderGetDouble(ORDER_PRICE_OPEN);

                // Store order prices
                if (price1 == 0.0)
                    price1 = price;
                else
                    price2 = price;

                // Store tickets based on order type
                if (order_type == ORDER_TYPE_BUY_STOP)
                {
                    buy_stop_ticket = order_ticket;
                }
                else if (order_type == ORDER_TYPE_SELL_STOP)
                {
                    sell_stop_ticket = order_ticket; // not relevant
                }
            }
        }
        
        double current_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        double distance = MathAbs(price1 - price2);
        double half_distance = (price1 + price2) / 2.0;
        // If the distance is less than or equal to grid_size plus twice the range spread, return
        if (distance <= (grid_size + grid_spread * 2)) return;// Range delay is already set

        // If the price is closer to the higher ticket
        if (current_price > half_distance)
        {
            // Delete the continuation sell stop order
            //delete_non_recovery_orders();
            Print(__FUNCTION__, " - Replacing sell stop: ", sell_stop_ticket," with recovery sell stop");

            // Check if the buy stop ticket is valid
            if (buy_stop_ticket != 0) 
            {
               //place_recovery_stop(buy_stop_ticket);
               PlaceRecoveryNode(ulong reference_ticket, const Grid &grid, const GridBase *base=NULL)
            }               
            else
            {
                Print(__FUNCTION__, " - Buy stop ticket not found. Unable to place replacement stop");
            }
        }
    }
    else if (orders_total == 1) // Outside trading session
    {
        //post_session_clean_up();

        // Attempt to get the buy stop's ticket
        for (int i = orders_total - 1; i >= 0; i--)
        {
            ulong order_ticket = OrderGetTicket(i);
            if (order_ticket != 0)
            {
                if (OrderGetString(ORDER_SYMBOL) != _Symbol)
                    continue;

                ENUM_ORDER_TYPE order_type = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);

                if (order_type == ORDER_TYPE_BUY_STOP)
                {
                    buy_stop_ticket = order_ticket;
                    break;
                }
            }
        }

        // If no buy stop ticket is found, return
        if (buy_stop_ticket == 0) return;

        //place_recovery_order(buy_stop_ticket);
    }
    else // Mismanagement error
    {
        Print(__FUNCTION__, " - FATAL. Unseen. ", orders_total," orders exist.");
        //check_strategy_rules();
    }
}

void post_session_clean_up()
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
                bool deleted = trade.OrderDelete(order_ticket);
                if (deleted)
                {
                    Print(__FUNCTION__, " - Deleted order with ticket: ", order_ticket, " and comment: ", order_comment, " as forgotten order cleanup ");
                }
                else
                {
                    Print(__FUNCTION__, " - Failed to delete order with ticket: ", order_ticket, " and comment: ", order_comment, " as forgotten order cleanup ");
                }
            }
        }
    }
}

