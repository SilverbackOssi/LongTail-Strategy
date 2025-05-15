
#include  <Ossi\LongTails\Utils.mqh>
#include  <Ossi\LongTails\PlaceGridNodes.mqh>
//+------------------------------------------------------------------+
void HandleNewPosition(GridBase &base, const GridInfo &grid, CTrade &trader)
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
    SetExits(trader, ticket, grid);
    
    // Update grid nodes
    DeleteAllPending(trader, _Symbol);
    PlaceRecoveryNode(trader, ticket, grid, &base);
    PlaceContinuationNode(trader, ticket, grid);
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
        Print("Unable to replace grid nodes\nEnforcing strategy rules");
        //EnforceCoreRules(trader);
    }
    if (base.type == POSITION_TYPE_BUY) return;// grid shifts on a short position
    
    // if price is not within range
    if (!IsRecoveryGap(grid, trader)) return;

    ClearContinuationNodes(trader);

    // After clearing continuation nodes, we expect at most one "Recovery" node to remain,
    // or zero if no recovery node was present or if it was (unintentionally) cleared.
    ulong recovery_node_ticket = 0;
    int remaining_orders = SymbolOrdersTotal();

    if (remaining_orders == 1)
    {
        ulong current_ticket = OrderGetTicket(0);
        if (OrderSelect(current_ticket)) // Ensure the order can be selected
        {
            // Verify that the remaining order is indeed the expected recovery node
            if (OrderGetString(ORDER_SYMBOL) == _Symbol &&
                (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_BUY_STOP && // Assuming recovery node is a BUY_STOP based on IsRecoveryGap
                StringFind(OrderGetString(ORDER_COMMENT), "Recovery") != -1)
            {
                recovery_node_ticket = current_ticket;
            }
            else
            {
                PrintFormat("%s: Warning - The single remaining order (Ticket: %lu, Symbol: %s, Type: %s, Comment: '%s') is not the expected recovery buy stop. Grid not shifted.",
                            __FUNCTION__, current_ticket, OrderGetString(ORDER_SYMBOL),
                            EnumToString((ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE)), OrderGetString(ORDER_COMMENT));
                return; // Avoid proceeding with an incorrect node
            }
        }
        else
        {
            PrintFormat("%s: Error - Failed to select order with ticket %lu. Grid not shifted.", __FUNCTION__, current_ticket);
            return; // Critical error, cannot verify order properties
        }
    }
    else if (remaining_orders > 1)
    {
        // This case should ideally be rare if the initial orders_total > 2 check is effective
        // and ClearContinuationNodes works as expected.
        PrintFormat("%s: Warning - %d orders found after attempting to clear continuation nodes. Expected 0 or 1. Grid not shifted.", __FUNCTION__, remaining_orders);
        return;
    }

    if (recovery_node_ticket == 0) {Print(__FUNCTION__," FATAL. Unable to handle grid gap"); return;}
    PlaceRecoveryNode(trader, recovery_node_ticket, grid); // Recovery_node_ticket should never be 0.
}
//+------------------------------------------------------------------+
bool IsRecoveryGap(const GridInfo &grid, CTrade &trader)
{
    // confirm the current price is between the recovery node and grid unit

    //XXX: EnforceCoreRules(trader); -> complete and test rules Enforcing first

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
    double recovery_threshold = buy_stop_price - grid.unit;

    if (price_current > recovery_threshold && price_current < buy_stop_price) return true;

    return false;
}
//+------------------------------------------------------------------+