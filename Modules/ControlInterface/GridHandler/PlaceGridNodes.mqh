
#include  <Ossi\LongTails\Utils.mqh>
//+------------------------------------------------------------------+

void PlaceContinuationNode(ulong reference_ticket, const int session_status, const Grid &grid)
{
    if (session_status == SESSION_OVER) return;

    if (PositionSelectByTicket(reference_ticket))
    {
        GridNode node;
        node.name = "Continuation node";
        // Get ticket details
        long reference_type = PositionGetInteger(POSITION_TYPE);
        double reference_price = PositionGetDouble(POSITION_PRICE_OPEN);
        double take_profit = PositionGetDouble(POSITION_TP);

        // Check if there is a take profit set for the reference position
        if (take_profit == 0)
            Print(__FUNCTION__, " - WARNING. No take profit set for open position with ticket: ", reference_ticket);

        // Assert Continuation Node
        node.volume = grid.progression_sequence[0];
        node.type = (reference_type == POSITION_TYPE_BUY) ? ORDER_TYPE_BUY_STOP : ORDER_TYPE_SELL_STOP;
        node.price = reference_price + (reference_type == POSITION_TYPE_BUY) ? (grid.target+grid.spread) : -grid.target;
         
        // Check if an order already exists at the node price
        ulong ticket_exists = NodeExistsAtPrice(node.price);
        if (ticket_exists!=0)
        {
            Print(__FUNCTION__, " - Continuation node with ticket:",ticket_exists , " already exists at price: ", node.price);
            return;
        }

        // Place a grid node
        node.comment = EA_TAG +" "+ node.name +" as "+ EnumToString(node.type);
        bool placed = trade.OrderOpen(_Symbol, node.type, node.volume, 0.0, node.price, 0, 0, ORDER_TIME_GTC, 0, node.comment);
        if (!placed)// Potential invalid price,handle stop limit
            Print(__FUNCTION__, " - Failed to place ", node.type, " continuation node on ", reference_type);
    }
    else 
    {
        Print(__FUNCTION__, " - FATAL. Continuation node can only be placed on open position. Reference ticket could not be selected"); // Rule 9
        return;
    }
}

void PlaceRecoveryNode(ulong reference_ticket, const Grid &grid, const GridBase *base=NULL)
{
    // Reference ticket type
    ENUM_POSITION_TYPE reference_type_position;
    ENUM_ORDER_TYPE reference_type_order;

    // Validate reference ticket
    if (PositionSelectByTicket(reference_ticket))
        reference_type_position = PositionGetInteger(POSITION_TYPE);
    else if (OrderSelect(reference_ticket))
        reference_type_order = OrderGetInteger(ORDER_TYPE);
        if (reference_type_order != ORDER_TYPE_BUY_STOP) // order must be a recovery buy stop
        {
            Print(__FUNCTION__, " - FATAL. Recovery node can only be placed on buy stop"); // Rule 7
            return;
        }
    else 
    {
        Print(__FUNCTION__, " - FATAL. Recovery node can only be placed on open position or buy stop. Reference ticket could not be selected"); // Rule 7
        return;
    }

    // Assert Node values
    GridNode node;
    node.name = "Recovery node";
    node = AssertRecoveryNode(node, reference_ticket, grid, base);

    // Check if an order already exists at the node price
     ulong ticket_exists = NodeExistsAtPrice(node.price);
     if (ticket_exists!=0)
     {
         Print(__FUNCTION__, " - Recovery node with ticket:",ticket_exists , " already exists at price: ", node.price);
         return;
     }

     // Place a grid node
     node.comment = EA_TAG +" "+ node.name +" as "+ EnumToString(node.type);
     bool placed = trade.OrderOpen(_Symbol, node.type, node.volume, 0.0, node.price, 0, 0, ORDER_TIME_GTC, 0, node.comment);
     if (!placed)// Potential invalid price,handle stop limit
         Print(__FUNCTION__, " - Failed to place ", node.type, " recovery node on ", EnumToString(((PositionSelectByTicket(reference_ticket))? reference_type_position:reference_type_order)));    
}

GridNode AssertRecoveryNode(GridNode node, ulong ref_ticket, const Grid &grid, const GridBase *base)
{
    // If reference ticket is open position
    if (PositionSelectByTicket(ref_ticket))
    {
        if (base == NULL)
        {
            Print(__FUNCTION__," unable to assess grid base, volume index. Please pass the Base data.");
            return node; // as it came
        }
        // Get ticket details
        long reference_type = PositionGetInteger(POSITION_TYPE);
        double reference_price = PositionGetDouble(POSITION_PRICE_OPEN);
        double stop_loss = PositionGetDouble(POSITION_SL);
        double reference_volume = PositionGetDouble(POSITION_VOLUME);

        // Check if there is a take profit set for the reference position
        if (stop_loss == 0)
            Print(__FUNCTION__, " - WARNING. No stop loss set for open position with ticket: ", ref_ticket);

        // Set order details
        int reference_volume_index = base->volume_index; 
        node.volume = grid.progression_sequence[reference_volume_index+1];
        node.type = (reference_type == POSITION_TYPE_SELL) ? ORDER_TYPE_BUY_STOP : ORDER_TYPE_SELL_STOP;
        node.price = reference_price +( (reference_type == POSITION_TYPE_SELL) ? (grid.unit+grid.spread) : -grid.unit);
    }

    // If reference ticket is pending order
    else if (OrderSelect(ref_ticket))
    {
        // Get ticket details
        long reference_type = OrderGetInteger(ORDER_TYPE);
        double reference_price = OrderGetDouble(ORDER_PRICE_OPEN);
        double reference_volume = OrderGetDouble(ORDER_VOLUME_CURRENT);
        string reference_comment = OrderGetString(ORDER_COMMENT);
        
        // Set order details 
        node.volume = reference_volume;
        node.type = ORDER_TYPE_SELL_STOP;
        node.price = reference_price - (grid.unit + grid.spread);
    }
    return node;
}