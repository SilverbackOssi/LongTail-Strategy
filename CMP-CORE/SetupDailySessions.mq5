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
datetime session_start = StringToTime("08:30");
datetime session_end = StringToTime("18:30");// test server time = real time +1
bool is_end_session = false; // false if session is active
bool use_daily_session = false;

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
         return;
     }
    else // within trading time
    {
        end_session = false;
        
        if (OrdersTotal() > 0 || PositionSelect(_Symbol))
        {
            //Progression cycle ongoing: Proceeding to manage cycle.
            return;
        }
        else
        {// Start a daily session
           Print("Starting daily session within trading time.");
           double lot_size = 0.01; // Pick lot size from sequence
           double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);

           bool placed = trade.Sell(lot_size, _Symbol, price, 0, 0, "Short Position");
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
