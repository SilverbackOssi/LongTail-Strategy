//+------------------------------------------------------------------+
//|                                               SessionManager.mqh |
//|                                      Copyright 2025, Anyim Ossi. |
//|                                          anyimossi.dev@gmail.com |
//+------------------------------------------------------------------+
#include  <Ossi\LongTails\Utils.mqh>

//+------------------------------------------------------------------+
void UpdateSesionStatus(int &session_state, const int &session_on, const int &session_over, datetime start_time, datetime end_time)
{
  if (IsWithinTradingTime(start_time, end_time))
    session_state = session_on;
  else session_state = session_over;
}
//+------------------------------------------------------------------+
void HandlePostSession(CTrade &trader)
{
  if (IsEmptyChart()) return;

  // clear continuation orders
  for (int i = OrdersTotal() - 1; i >= 0; --i)
  {
    ulong order_ticket = OrderGetTicket(i);
    string order_symbol = OrderGetString(ORDER_SYMBOL);
    if (order_symbol != _Symbol) continue;
    string comment = OrderGetString(ORDER_COMMENT);

    if (order_ticket != 0)
    {
      // Check if the comment does not contain "recovery"
      if (StringFind(comment, "recovery") != -1) continue;

      if (trader.OrderDelete(order_ticket))
        Print(__FUNCTION__, ": Deleted order with ticket: ", order_ticket, " and comment: ", comment);
      else
        Print(__FUNCTION__, ": Failed to delete order with ticket: ", order_ticket, " and comment: ", comment);
    }
  }
}
//+------------------------------------------------------------------+
void StartSession(const double &progression_sequence[], const string ea_tag)
{ /* Starts a trading session*/
  if (!IsEmptyChart())
    return; // Progression cycle ongoing: Proceeding to manage cycle.
  else
  {
      Print("Starting Trading session within trading time. Current time: ", TimeCurrent());
      
      double order_volume = progression_sequence[0];
      if (OpenShort(order_volume, ea_tag))
        Print(__FUNCTION__, ": Started trading session with short at market price.");
      else
          Print(__FUNCTION__, ": Failed to start new session with short position at market price.");
    }  
}
//+------------------------------------------------------------------+
void DeleteContinuationOrders()
{ /*Deletes any order whose comment does not contain 'recovery' */
  
}
//+------------------------------------------------------------------+