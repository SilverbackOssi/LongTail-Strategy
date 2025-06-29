//+------------------------------------------------------------------+
//|                                                  GridManager.mqh |
//|                                      Copyright 2025, Anyim Ossi. |
//|                                          anyimossi.dev@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Anyim Ossi."
#property link      "anyimossi.dev@gmail.com"

#include  "GridNodes.mqh"

//+------------------------------------------------------------------+
void HandleNewPosition(CTrade &trade_obj, GridBase &base, GridInfo &grid){
    // Validate
    if (!PositionSelect(_Symbol)) return;
    if (!IsNewPosition(base.ticket)) return;
    
    // Update GridBase
    ulong ticket = PositionGetInteger(POSITION_TICKET);
    base.UpdateGridBase(ticket, grid);

    // Replace grid nodes
    DeleteAllPending(trade_obj, _Symbol);
    PlaceRecoveryNode(trade_obj, grid, base);
    PlaceContinuationNode(trade_obj, ticket, grid);
}

//+------------------------------------------------------------------+
// place recovery node ON ORDERS ONLY
void HandleGridGap(CTrade &trade_obj, GridInfo &grid, GridBase &base) {
    // XXX: Should handle both continuation(long&short) and recovery(long&short) gaps
    // Validate gap (confirm its gap)
    int orders_total = SymbolOrdersTotal();
    if (PositionSelect(_Symbol) || orders_total == 0) return; // must be a gap
    if (orders_total == 2) { // Check if gap has been handled
        ulong first_ticket = OrderGetTicket(0), second_ticket = OrderGetTicket(1);
        if((GetDistanceBetweenOrders(first_ticket, second_ticket)) <= grid.unit * 2)
            return;
    }
    
    if (IsRecoveryGap(grid, trade_obj)){
        ClearNodeExceptRecovery(trade_obj); //clear cont nodes
        
        // re-validate
        if (SymbolOrdersTotal() == 0) {
            Print(__FUNCTION__," FATAL. Unable to handle recovery gap, no recovery node found.");
            return;
            }
        ulong recovery_node_ticket = IsRecoveryGap(grid, trade_obj);
        if (!recovery_node_ticket) return;
         
        //place recovery node
        GridBase null_base; null_base.UpdateOrderAsBase(recovery_node_ticket);
        PlaceRecoveryNode(trade_obj, grid, null_base);
    }else if (IsContinuationGap(grid, trade_obj)){
        ClearRecoveryNodes(trade_obj); //clear recovery nodes
        
        // re-validate
        if (SymbolOrdersTotal() == 0){
                Print(__FUNCTION__," FATAL. Unable to handle continuation gap, no continuation node found.");
                return;
            }
        ulong continuation_node_ticket = IsContinuationGap(grid, trade_obj);
        if (!continuation_node_ticket) return;
        
        //place recovery node
        GridBase null_base; null_base.UpdateOrderAsBase(continuation_node_ticket);
        PlaceRecoveryNode(trade_obj, grid, null_base);
    }else {
      Print(__FUNCTION__, " FATAL- Unexpected gap encountered, clearing all nodes");
      DeleteAllPending(trade_obj,_Symbol);
    }
}

//+------------------------------------------------------------------+
double GetDistanceBetweenOrders(ulong order1ticket, ulong order2ticket) {
    double price1 = 0.0, price2 = 0.0;
    
    // Get price for first order
    if(OrderSelect(order1ticket)) {
        price1 = OrderGetDouble(ORDER_PRICE_OPEN);
    } else {
        Print(__FUNCTION__, " Error: Could not select order ticket ", order1ticket);
        return -1;
    }
    
    // Get price for second order
    if(OrderSelect(order2ticket)) {
        price2 = OrderGetDouble(ORDER_PRICE_OPEN);
    } else {
        Print(__FUNCTION__, " Error: Could not select order ticket ", order2ticket);
        return -1;
    }
    
    // Return absolute distance between orders
    return MathAbs(price1 - price2);
}
