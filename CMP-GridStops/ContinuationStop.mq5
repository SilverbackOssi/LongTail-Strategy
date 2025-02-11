//+------------------------------------------------------------------+
//|                                        PlaceContinuationStop.mq5 |
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
//bool EndSession = true;
bool EndSession = false;
int Sequence[]={1, 1, 2, 2, 3, 4, 5, 7, 9, 12, 16, 22, 29, 39, 52, 69, 92, 123,164, 218};
double grid_size = 2.00;
double grid_spread = 0.40;
int reward_multiplier = 5;
//double take_profit = open_price + (grid_size * reward_multiplier);


void OnStart()
  {
//---
   ulong ticket = 0;
   if (PositionSelect(_Symbol)){
      ticket = PositionGetInteger(POSITION_TICKET);
      }
   place_continuation_stop(ticket);   
   
  }
//+------------------------------------------------------------------+

/**
 * @brief Places a continuation stop order based on a reference position.
 *
 * This function places a continuation stop order if certain conditions are met.
 * It first checks if the trading session has ended and if the reference position
 * is open. If the reference position has a take profit set, it calculates the 
 * order price and checks if an order already exists at that price. If no order 
 * exists, it places a new stop order.
 *
 * @param reference_ticket The ticket number of the reference position.
 *
 * @note The function will not place an order if the trading session has ended,
 *       if the reference position is not open, or if the reference position 
 *       does not have a take profit set.
 */
void place_continuation_stop(ulong reference_ticket)
{
    
    if (EndSession) return;

    if (PositionSelectByTicket(reference_ticket))
    {
        // Get ticket details
        ulong ticket = PositionGetInteger(POSITION_TICKET);
        long ticket_type = PositionGetInteger(POSITION_TYPE);
        double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
        double take_profit = PositionGetDouble(POSITION_TP);

        // Check if there is a take profit set for the reference position
        if (take_profit == 0)
        {
            Print(__FUNCTION__, " - Failed to place continuation stop order. No take profit set for reference ticket: ", reference_ticket);
            return;
        }

        // Get lot size as the first term of the progression sequence
        double lot_size = Sequence[0];
        ENUM_ORDER_TYPE order_type = (ticket_type == POSITION_TYPE_BUY) ? ORDER_TYPE_BUY_STOP : ORDER_TYPE_SELL_STOP;
        double order_price = (ticket_type == POSITION_TYPE_BUY) 
                      ? take_profit+grid_spread 
                      : take_profit;
         
        // Check if an order already exists at the calculated price
        ulong exists = order_exists_at_price(_Symbol, order_type, order_price);
        if (exists!=0)
        {
            Print(__FUNCTION__, " - Continuation stop order already exists at the calculated price for reference ticket: ",
                  reference_ticket, ", order ticket: ", exists);
            return;
        }

        // Place a stop order similar to the open position’s type
        bool placed = trade.OrderOpen(_Symbol, order_type, lot_size, 0.0, order_price, 0, 0);
        if (placed)
        {
            ulong order_ticket = trade.ResultOrder(); // Get the ticket number of the placed order
            Print(__FUNCTION__, " - Continuation stop order placed, reference ticket: ", reference_ticket, ", order ticket: ", order_ticket);
        }
        else
        {
            Print(__FUNCTION__, " - Failed to place continuation stop order");
        }

    }
    else
    {
        Print(__FUNCTION__, " - Reference position not open");
    } // Fatal error
}

ulong order_exists_at_price(const string symbol, ENUM_ORDER_TYPE order_type, double order_price)
{
    for (int i = OrdersTotal() - 1; i >= 0; --i)
      {
        ulong order_ticket = OrderGetTicket(i);
        if (order_ticket!=0)
            {
            if (OrderGetString(ORDER_SYMBOL) == symbol 
               && OrderGetInteger(ORDER_TYPE) == order_type 
               && OrderGetDouble(ORDER_PRICE_OPEN) == order_price)
               {
                return order_ticket;
               }
            }
      }
    return 0;
}
