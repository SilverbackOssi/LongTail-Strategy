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
double grid_size = 1.0;
int reward_multiplier = 3;


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

void place_continuation_stop(ulong reference_ticket)
   {
    if (EndSession) return;

    if (PositionSelectByTicket(reference_ticket))
      {
      //get ticket details
      ulong ticket = PositionGetInteger(POSITION_TICKET);
      long ticket_type = PositionGetInteger(POSITION_TYPE);
      double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
      
      //get lot size as first term of the progression sequence
      double lot_size = Sequence[0];
      long order_type = (ticket_type==POSITION_TYPE_BUY) ? ORDER_TYPE_BUY_STOP: ORDER_TYPE_SELL_STOP;
      double order_price = open_price+grid_size*reward_multiplier;

      //place a stop order similar to the open position’s type      
      bool palced = trade.OrderOpen(_Symbol,order_type,lot_size,0.0,order_price,0,0);
      
      }
    else 
      {
      Print(__FUNCTION__," - reference position not open");
      } //fatal error
         
   }
   