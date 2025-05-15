//+------------------------------------------------------------------+
//|                                               SessionManager.mqh |
//|                                      Copyright 2025, Anyim Ossi. |
//|                                          anyimossi.dev@gmail.com |
//+------------------------------------------------------------------+
#include  <Ossi\LongTails\Utils.mqh>
#include  <Ossi\LongTails\PlaceGridNodes.mqh>
//+------------------------------------------------------------------+
void HandleNewPosition(GridBase &base, const GridInfo &grid)
{
    if (!PositionSelect(_Symbol)) return;
    ulong ticket = PositionGetInteger(POSITION_TICKET);

    // update GridBase
    base.UpdateGridBase(ticket);
    if (StringFind(base.name, "Recovery") != -1)
        base.volume_index ++;
    else 
      base.volume_index = 0;
    
    // set TP/SL
    SetExits(trade, ticket, grid);
    
    // Update grid nodes
    DeleteAllPending(trade, _Symbol);
    PlaceRecoveryNode(ticket, grid, &base);
    PlaceContinuationNode(ticket, grid.status, grid);
}
//+------------------------------------------------------------------+
void HandleGridGap(GridInfo &grid, GridBase &base, CTrade &trader)
{
    // Context validation
    int orders_total = SymbolOrdersTotal();
    if (PositionSelect(_Symbol) || orders_total == 0) return;
    if (orders_total>2)
    {
        Print(__FUNCTION__, "- WARNING. ", orders_total," nodes found on the chart.");
        Print("Unable to replace grid nodes");
        return;
    }
    if (base.type == POSITION_TYPE_BUY) return;// grid shifts on a short position
    
    // if price is not within range
    if (!IsRecoveryGap(grid, trader)) return;

    // clear continuation orders
    ClearContinuationNodes(trader);
    
    if (SymbolOrdersTotal() > 1) return; // Shift recovery node already placed
    
    // place RecoveryNode node on recovery node
    ulong stop_ticket = OrderGetTicket(0);
    PlaceRecoveryNode(stop_ticket, grid);
}
//+------------------------------------------------------------------+
bool IsRecoveryGap(const GridInfo &grid, CTrade &trader)
{
    // confirm the current price is between the recovery node and grid unit

    // EnforceCoreRules(trader);

    double buy_stop_price = 0;
    for (int i = OrdersTotal() - 1; i >= 0; i--)
        {
            ulong order_ticket = OrderGetTicket(i);
            if (order_ticket == 0) continue;
            if (OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
            string comment = OrderGetString(ORDER_COMMENT);
            if (StringFind(comment, "Recovery") == -1) continue;

            ENUM_ORDER_TYPE order_type = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
            if (order_type == ORDER_TYPE_BUY_STOP)
                buy_stop_price = OrderGetDouble(ORDER_PRICE_OPEN);
        }
    if (!buy_stop_price) return false;

    double price_current = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    double recovery_treshhold = buy_stop_price - grid.unit;

    if (buy_stop_price > price_current > recovery_treshhold) return true;

    return false;
}
//+------------------------------------------------------------------+