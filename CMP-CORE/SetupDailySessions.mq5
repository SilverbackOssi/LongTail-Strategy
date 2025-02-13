//+------------------------------------------------------------------+
//|                                           SetupDailySessions.mq5 |
//|                                      Copyright 2025, Anyim Ossi. |
//|                                          anyimossi.dev@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Anyim Ossi."
#property link      "anyimossi.dev@gmail.com"
#property version   "1.00"
#property  strict
#include <Trade\Trade.mqh>
CTrade trade;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
double Sequence[]={0.01, 0.01, 0.02, 0.02, 0.03, 0.04, 0.05, 0.07, 0.09, 0.12, 0.16, 0.22, 0.29, 0.39, 0.52, 0.69, 0.92, 1.23, 1.64, 2.18};
datetime session_start = StringToTime("08:30");
datetime session_end = StringToTime("18:30");// test server time = real time +1
bool is_end_session = false; // false if session is active(default)
bool use_daily_session = false; // trade 24/7

void OnStart()
  {
//--- 
   update_daily_session(is_end_session);
   
  }
//+------------------------------------------------------------------+


void update_daily_session(bool &end_session)
{ 
     if (!is_within_trading_time(session_start, session_end)) // outside trading time
     {
         // End a daily session
         end_session = true;
         Print("Ending daily session: Outside trading time.");
         // delete continuaiton orders
         delete_non_recovery_orders();
         return;
     }
    else // within trading time
    {
      // Start a daily session
        end_session = false;
        
        if (OrdersTotal() > 0 || PositionSelect(_Symbol))
        {
            //Progression cycle ongoing: Proceeding to manage cycle.
            return;
        }
        else
        {
           Print("Starting daily session within trading time.");
           double order_volume = Sequence[0];
           double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);

           bool placed = trade.Sell(order_volume, _Symbol, price, 0, 0, "short position");
           if (placed)
           {
              Print("Started new cycle with short position opened at market price: ", price);
           }
           else
           {
               Print("Failed to start new cycle with short position at market price.", price);
           }
         }  
    }
}

bool is_within_trading_time(datetime start_time, datetime end_time)
{
    if (!use_daily_session) return true;// always trading time if we dont use daily sessions
    
    if (start_time>end_time)
    {
      datetime temp = start_time;
      start_time = end_time;
      end_time = temp; 
    }
    datetime current_time = TimeCurrent();
    
    return (current_time >= start_time && current_time <= end_time);
}

void delete_non_recovery_orders()
{
  /*
  Deletes any order whose comment does not contain 'recovery'
  */  
    // Loop through all open orders
    for (int i = OrdersTotal() - 1; i >= 0; --i)
    {
        ulong order_ticket = OrderGetTicket(i);
        if (order_ticket != 0)
        {
            string comment = OrderGetString(ORDER_COMMENT);
            
            // Check if the comment does not contain "recovery"
            if (StringFind(comment, "recovery") == -1)
            {
                
                bool deleted = trade.OrderDelete(order_ticket);
                if (deleted)
                {
                    Print("Deleted order with ticket: ", order_ticket, " and comment: ", comment);
                }
                else
                {
                    Print("Failed to delete order with ticket: ", order_ticket, " and comment: ", comment);
                }
            }
        }
    }
}

