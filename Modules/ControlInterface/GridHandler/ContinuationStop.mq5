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
double Sequence[]={0.01, 0.01, 0.02, 0.02, 0.03, 0.04, 0.05, 0.07, 0.09, 0.12, 0.16, 0.22, 0.29, 0.39, 0.52, 0.69, 0.92, 1.23, 1.64, 2.18};
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
