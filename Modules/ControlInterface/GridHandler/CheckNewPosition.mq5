//+------------------------------------------------------------------+
//|                                             CheckNewPosition.mq5 |
//|                                      Copyright 2025, Anyim Ossi. |
//|                                          anyimossi.dev@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Anyim Ossi."
#property link      "anyimossi.dev@gmail.com"
#property version   "1.00"
#include <Trade\Trade.mqh>
#include "utils.mqh"
CTrade trade;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- 
    ulong last_saved_ticket = 0 ;//default
    ENUM_POSITION_TYPE last_saved_type = -1;
    check_new_position(last_saved_ticket, last_saved_type);
   
  }
//+------------------------------------------------------------------+




void HandleNewPosition(, ENUM_POSITION_TYPE &last_type)
{ // Sets grid
    
    // update GridBase
    long ticket_type = PositionGetInteger(POSITION_TYPE);
    
    // call set exits()
    
    DeletePendingOrders();
    
    // call recovery.
    
    // call continuation.
    
    //update stored ticket to open ticket
    last_saved = open_ticket;
    last_type = (ENUM_POSITION_TYPE)ticket_type;
}
