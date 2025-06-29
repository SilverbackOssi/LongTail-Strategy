//+------------------------------------------------------------------+
//|                                               SessionManager.mqh |
//|                                      Copyright 2025, Anyim Ossi. |
//|                                          anyimossi.dev@gmail.com |
//+------------------------------------------------------------------+
#include  "Utils.mqh"

//+------------------------------------------------------------------+
void UpdateSessionStatus(GridInfo &grid){
	// XXX: possible logic to also update session based on account balance increament target alongside current logic 
  if (IsWithinTime(grid.session_time_start, grid.session_time_end))
    grid.session_status = SESSION_RUNNING;
  else grid.session_status = SESSION_OVER;
}
//+------------------------------------------------------------------+
void HandleSessionEnd(CTrade &trader, GridInfo &grid){
  if (IsEmptyChart()) return;

  // clear continuation orders
  ClearNodeExceptRecovery(trader);

  // clear post-session recovery lag
  ClearPostSessionRecoveryNode(trader, grid);
}
//+------------------------------------------------------------------+
/* 
Starts a trading session
*/
void StartSession(CTrade &trader,GridBase &base, GridInfo &grid){ 
  if (!IsEmptyChart())
    return; // Progression cycle ongoing: Proceed to manage cycle.
  else{
      Print("Starting Trading session within trading time. Current time: ", TimeCurrent());
      
      double order_volume = grid.progression_sequence[0];
      ulong ticket = OpenShort(order_volume, trader);
      if (ticket){
        base.UpdateGridBase(ticket, grid);
        Print(__FUNCTION__, ": Started trading session with short at market price.");
      }else
          Print(__FUNCTION__, ": Failed to start new session with short position at market price.");
    }  
}
//+------------------------------------------------------------------+
void ClearPostSessionRecoveryNode(CTrade &trader, GridInfo &grid){
    UpdateSessionStatus(grid);
    // One recovery node lags after session ends and cycle ends
    printf("DEBUG - ENTERED");
    if (!grid.use_session || grid.session_status != SESSION_OVER)  return; // user must allow use session and session is over
    if (PositionSelect(_Symbol) || OrdersTotal()!=1) return; // must be a gap
    
    printf("DEBUG - passed entry condition");
    ulong order_ticket = OrderGetTicket(0);
    if (order_ticket != 0){
      double order_price = OrderGetDouble(ORDER_PRICE_OPEN);
      ulong order_ticket = OrderGetInteger(ORDER_TICKET);
      string order_comment = OrderGetString(ORDER_COMMENT);

      // Confirm node lag(gap)
      double threshold = grid.unit;
      double current_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double distance = MathAbs(current_price - order_price);
      if (distance > threshold)
      {
          bool deleted = trader.OrderDelete(order_ticket);
          if (deleted)
              Print(__FUNCTION__, " - Deleted order with ticket: ", order_ticket, " and comment: ", order_comment, " as forgotten order cleanup ");
          else
              Print(__FUNCTION__, " - Failed to delete order with ticket: ", order_ticket, " and comment: ", order_comment, " as forgotten order cleanup ");
      }
     }
    
}
//+------------------------------------------------------------------+
void AntiMidnightSlip(CTrade &trader, GridInfo &grid){
  if (grid.use_session == false){
    if (IsWithinTime(StringToTime("21:00"), StringToTime("23:59")) ||
         IsWithinTime(StringToTime("00:00"), StringToTime("01:00")) ){
      grid.session_status = SESSION_OVER;
      HandleSessionEnd(trader, grid);
    } else {
      grid.session_status = SESSION_RUNNING;
    }
  }
}
//+------------------------------------------------------------------+