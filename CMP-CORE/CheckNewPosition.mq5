//+------------------------------------------------------------------+
//|                                             CheckNewPosition.mq5 |
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
void OnStart()
  {
//--- 
    ulong last_saved_ticket = 0 ;//default
    check_new_position(last_saved_ticket);
   
  }
//+------------------------------------------------------------------+


void check_new_position(ulong &last_saved)
{
    if (PositionSelect(_Symbol))
    {
        //get open positons ticket
        ulong open_ticket = PositionGetInteger(POSITION_TICKET);
        
        if (last_saved != open_ticket) // New position open on chart
        {
            Print("New position opened, proceeding to manage.");
            // call set exits()
            
            delete_all_pending_orders();
            
            // call recovery.
            
            // call continuation if not endsession.
            
            //update stored ticket to open ticket
            last_saved = open_ticket;
         }   
    }
}

void delete_all_pending_orders()
{
    // Loop through all open orders
    for (int i = OrdersTotal() - 1; i >= 0; --i)
    {
        ulong order_ticket = OrderGetTicket(i);
        if (order_ticket != 0)
        {
            bool deleted = trade.OrderDelete(order_ticket);
            if (deleted)
            {
                Print("Deleted order with ticket: ", order_ticket, " and comment: ", OrderGetString(ORDER_COMMENT));
            }
            else
            {
                Print("Failed to delete order with ticket: ", order_ticket, " and comment: ", OrderGetString(ORDER_COMMENT));
            }
        }
    }
}
