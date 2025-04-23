//+------------------------------------------------------------------+
//|                                               SessionManager.mqh |
//|                                      Copyright 2025, Anyim Ossi. |
//|                                          anyimossi.dev@gmail.com |
//+------------------------------------------------------------------+
#include  <Ossi\LongTails\Utils.mqh>

void HandleNewPosition(GridBase &base, const Grid &grid)
{
    if (!PositionSelect(_Symbol)) return;
    ulong ticket = PositionGetInteger(POSITION_TICKET);

    // update GridBase
    base.UpdateGridBase(ticket);
    if (StringFind(base.name, "Recovery") != -1)
        base.volume_index = 0;
    else 
      base.volume_index ++;
    
    // set TP/SL
    SetExits(trade, ticket, Grid.unit, Grid.multiplier);
    
    // Clean lagging orders
    DeleteAllPending(trade, _Symbol)
    
    // call recovery.
    PlaceRecoveryNode(ticket, grid, base)
    
    // call continuation.
    PlaceContinuationNode(ticket, grid.status, grid)
    
}