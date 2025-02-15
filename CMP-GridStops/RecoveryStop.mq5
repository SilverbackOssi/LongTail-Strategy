//+------------------------------------------------------------------+
//|                                            PlaceRecoveryStop.mq5 |
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

bool EndSession = false;
double Sequence[]={0.01, 0.01, 0.02, 0.02, 0.03, 0.04, 0.05, 0.07, 0.09, 0.12, 0.16, 0.22, 0.29, 0.39, 0.52, 0.69, 0.92, 1.23, 1.64, 2.18};
double grid_size = 5.00;
double grid_spread = 0.40;
int reward_multiplier = 3;
//double stop_loss = open_price + (grid_size * reward_multiplier);


void OnStart()
  {
//---
   // Test on open position
   ulong ticket = 0;
   if (PositionSelect(_Symbol)){
      ticket = PositionGetInteger(POSITION_TICKET);
      }
   //Test on buy stop
   for (int i = OrdersTotal() - 1; i >= 0; --i)
   {
      ticket = OrderGetTicket(i);
   } 
   
   place_recovery_stop(ticket);  
  }
//+------------------------------------------------------------------+

void place_recovery_stop(ulong reference_ticket)
{
    ENUM_ORDER_TYPE order_type=0;
    double order_price=0;
    double order_volume=0;
    
    if (PositionSelectByTicket(reference_ticket))
    {
        // Get ticket details
        long ticket_type = PositionGetInteger(POSITION_TYPE);
        double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
        double stop_loss = PositionGetDouble(POSITION_SL);
        double open_volume = PositionGetDouble(POSITION_VOLUME);

        // Check if there is a take profit set for the reference position
        if (stop_loss == 0)
        {
            Print(__FUNCTION__, " - Failed to place recovery stop order. No stop loss set for reference ticket: ", reference_ticket);
            return;
        }

        // Set order details
        int open_volume_index = get_volume_index(open_volume,Sequence); 
        order_volume = Sequence[open_volume_index+1];
        order_type = (ticket_type == POSITION_TYPE_SELL) ? ORDER_TYPE_BUY_STOP : ORDER_TYPE_SELL_STOP;
        order_price = (ticket_type == POSITION_TYPE_SELL) ? stop_loss+grid_spread : stop_loss;     
    }
    else if (OrderSelect(reference_ticket)) // order must be a recovery buy stop
    {       
        // Get ticket details
        long ticket_type = OrderGetInteger(ORDER_TYPE);
        double open_price = OrderGetDouble(ORDER_PRICE_OPEN);
        double open_volume = OrderGetDouble(ORDER_VOLUME_CURRENT);
        string comment = OrderGetString(ORDER_COMMENT);
        
        // Check if the reference order is a recovery buy stop
        if (ticket_type != ORDER_TYPE_BUY_STOP || (StringFind(comment, "recovery") == -1))
        {
            Print(__FUNCTION__, " - Failed to place replacement recovery sell stop order. Reference order: ", reference_ticket, " is not a recovery buy stop");
            return;
        }
        
        // Set order details 
        order_volume = open_volume;
        order_type = ORDER_TYPE_SELL_STOP;
        order_price = open_price - grid_size; 
    }
    else // Fatal error
    {
      Print(__FUNCTION__, " - FATAL. Recovery order can only be placed on open position or buy stop");
      return;
    } 

    // Check if an order already exists at the calculated price
     ulong ticket_exists = order_exists_at_price(_Symbol, order_type, order_price);
     if (ticket_exists!=0)
     {
         Print(__FUNCTION__, " - Recovery stop order already exists at the calculated price for reference ticket: ",
               reference_ticket, ", order ticket: ", ticket_exists);
         return;
     }

     // Place a stop order opposite to the open/pending position’s type
     string comment = "recovery " + EnumToString(order_type);
     bool placed = trade.OrderOpen(_Symbol, order_type, order_volume, 0.0, order_price, 0, 0, ORDER_TIME_GTC, 0, comment);
     if (placed)
     {
         ulong order_ticket = trade.ResultOrder(); // Get the ticket number of the placed order
         Print(__FUNCTION__, " - Recovery stop order placed on reference ticket: ", reference_ticket, ", order ticket: ", order_ticket, ", comment: ", comment);
     }
     else
     {
         Print(__FUNCTION__, " - Failed to place recovery stop order");// Potential invalid price, need to handle
     }
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
int get_volume_index(double volume,const double &sequence[])
{
   for (int i=0;i<ArraySize(sequence);i++)
   {
      if (volume==sequence[i])
      {
         return i;
      }
   }
   return -1;
}
