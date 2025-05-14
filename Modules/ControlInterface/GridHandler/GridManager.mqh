//+------------------------------------------------------------------+
//|                                               SessionManager.mqh |
//|                                      Copyright 2025, Anyim Ossi. |
//|                                          anyimossi.dev@gmail.com |
//+------------------------------------------------------------------+
#include  <Ossi\LongTails\Utils.mqh>
#include  <Ossi\LongTails\PlaceGridNodes.mqh>
//+------------------------------------------------------------------+
void HandleNewPosition(GridBase &base, const Grid &grid)
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
    SetExits(trade, ticket, Grid.unit, Grid.multiplier);
    
    // Update grid nodes
    DeleteAllPending(trade, _Symbol);
    PlaceRecoveryNode(ticket, grid, &base);
    PlaceContinuationNode(ticket, grid.status, grid);
}
//+------------------------------------------------------------------+
HandleGridGap(Grid grid, GridBase base, CTrade trader)
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
    if (!IsRecoveryGap(grid)) return;

    // clear continuation orders
    ClearContinuationNodes(trader);
    
    if (SymbolOrdersTotal() > 1) return; // Shift recovery node already placed
    
    // place RecoveryNode node on recovery node
    ulong stop_ticket = OrderGetTicket(0);
    PlaceRecoveryNode(stop_ticket, grid);
}
//+------------------------------------------------------------------+
bool IsRecoveryGap(Grid &grid)
{
    // confirm the distance between current price and the recovery node
    // price is within grid.unit range.

    ulong buy_stop_price = 0;
    for (int i = OrdersTotal() - 1; i >= 0; i--)
        {
            ulong order_ticket = OrderGetTicket(i);
            if (order_ticket == 0) continue;
            if (OrderGetString(ORDER_SYMBOL) != _Symbol) continue;

            ENUM_ORDER_TYPE order_type = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
            if (order_type == ORDER_TYPE_BUY_STOP)
                buy_stop_price = OrderGetDouble(ORDER_PRICE_OPEN);
        }
    if (!buy_stop_price) return false;
    double price_current = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    ulong recovery_treshhold = buy_stop_price - grid.unit;

    if (price_current > recovery_treshhold) return true;
    return false;
}
//+------------------------------------------------------------------+