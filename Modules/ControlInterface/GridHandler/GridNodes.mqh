
#include  <Ossi\LongTails\Utils.mqh>
//+------------------------------------------------------------------+

void PlaceContinuationNode(CTrade &trader, ulong reference_ticket, const GridInfo &grid){
    const int session_status = grid.session_status;
    if (session_status == SESSION_OVER) return;

    if (PositionSelectByTicket(reference_ticket)){
        // XXX: call core rules
        GridNode node;
        node.name = EA_CONTINUATION_TAG + " node";
        
        // Get ticket details
        long reference_type = PositionGetInteger(POSITION_TYPE);
        double reference_price = PositionGetDouble(POSITION_PRICE_OPEN);
        double take_profit = PositionGetDouble(POSITION_TP);

        // Assert Continuation Node
        node.volume = grid.progression_sequence[0];
        node.type = (reference_type == POSITION_TYPE_BUY) ? ORDER_TYPE_BUY_STOP : ORDER_TYPE_SELL_STOP;
        node.price = reference_price + ((reference_type == POSITION_TYPE_BUY) ? (grid.target+grid.spread) : -grid.target);
         
        // Check if an order already exists at the node price
        ulong ticket_exists = NodeExistsAtPrice(node.price);
        if (ticket_exists!=0){
            Print(__FUNCTION__, " - Continuation node with ticket:",ticket_exists , " already exists at price: ", node.price);
            return;
        }

        // Place a grid node
        node.comment = EA_TAG +" "+ node.name +" as "+ EnumToString(node.type);
        bool placed = trader.OrderOpen(_Symbol, node.type, node.volume, 0.0, node.price, 0, 0, ORDER_TIME_GTC, 0, node.comment);
        if (!placed)// Potential invalid price,handle stop limit
            Print(__FUNCTION__, " - Failed to place ", node.type, " continuation node on ", reference_type);
    }
    else {
        Print(__FUNCTION__, " - FATAL. Continuation node can only be placed on open position. Reference ticket could not be selected"); // Rule 9
        return;
    }
}

void PlaceRecoveryNode(CTrade &trader, const GridInfo &grid, const GridBase &base){ // Cannot pass pointer to type struct
    // Reference ticket type
    ulong reference_ticket = base.ticket;
    string reference_type = "";

    // Validate reference ticket
    if (PositionSelectByTicket(reference_ticket))
        reference_type = EnumToString((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE));
    else if (OrderSelect(reference_ticket))
        reference_type = EnumToString((ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE)); 
    else {
        Print(__FUNCTION__, " - FATAL. Recovery node can only be placed on open position or pending order. Reference ticket could not be selected");
        return;
    }

    // Assert Node values
    GridNode node;
    node.name = EA_RECOVERY_TAG + " node";
    node = AssertRecoveryNode(node, grid, base);
    if (node.price == -1.0) return; // unable to assert node values

    // Check if an order already exists at the node price
     ulong ticket_exists = NodeExistsAtPrice(node.price);
     if (ticket_exists!=0){
         Print(__FUNCTION__, " - Recovery node with ticket:",ticket_exists , " already exists at price: ", node.price);
         return;
     }

     // Place a grid node
     node.comment = EA_TAG +" "+ node.name +" as "+ EnumToString(node.type);
     bool placed = trader.OrderOpen(_Symbol, node.type, node.volume, 0.0, node.price, 0, 0, ORDER_TIME_GTC, 0, node.comment);
     if (!placed)// Potential invalid price,handle stop limit
         Print(__FUNCTION__, " - Failed to place ", node.type, " recovery node on ", reference_type);    
}

GridNode AssertRecoveryNode(GridNode &node, const GridInfo &grid, const GridBase &base){
    ulong ref_ticket = base.ticket;
    if (PositionSelectByTicket(ref_ticket)){ // ticket is open position
        if (base.name == NULL_BASE_NAME){
            Print(__FUNCTION__," unable to assert recovery node on grid base. Please pass valid Base data not null.");
            node.price = -1.0;
            return node;
        }
        // Get ticket details
        long reference_type = PositionGetInteger(POSITION_TYPE);
        double reference_price = PositionGetDouble(POSITION_PRICE_OPEN);
        double reference_volume = PositionGetDouble(POSITION_VOLUME);
        double stop_loss = PositionGetDouble(POSITION_SL);

        // Set order details
        int reference_volume_index = base.volume_index;
        if (reference_volume_index + 1 < ArraySize(grid.progression_sequence)) {
            node.volume = grid.progression_sequence[reference_volume_index + 1];
        } else { // Reset progression Cycle 
            node.volume = grid.progression_sequence[0]; 
        }

        node.type = (reference_type == POSITION_TYPE_SELL) ? ORDER_TYPE_BUY_STOP : ORDER_TYPE_SELL_STOP;
        node.price = reference_price +( (reference_type == POSITION_TYPE_SELL) ? (grid.unit+grid.spread) : -grid.unit);
    }
    else if (OrderSelect(ref_ticket)){ // ticket is pending order
        // Get ticket details
        long reference_type = OrderGetInteger(ORDER_TYPE);
        double reference_price = OrderGetDouble(ORDER_PRICE_OPEN);
        double reference_volume = OrderGetDouble(ORDER_VOLUME_CURRENT);
        string reference_comment = OrderGetString(ORDER_COMMENT);
        
        // Set order details 
        node.volume = reference_volume;
        // node type must be opposite the reference type
        node.type = (reference_type==ORDER_TYPE_BUY_STOP)?  ORDER_TYPE_SELL_STOP : ORDER_TYPE_BUY_STOP;
        node.price = reference_price + ((reference_type==ORDER_TYPE_BUY_STOP)? -(grid.unit + grid.spread):(grid.unit + grid.spread));
    }
    return node;
}

ulong IsRecoveryGap(const GridInfo &grid, CTrade &trade_obj){
    if (PositionSelect(_Symbol) || SymbolOrdersTotal() == 0) return 0; // must be a gap

    // Get recovery node
    ulong recovery_node_ticket = 0;
    double recovery_node_price = 0;
    long recovery_node_type = 0;
    for (int i = OrdersTotal() - 1; i >= 0; i--){
        ulong order_ticket = OrderGetTicket(i);
        if (!OrderSelect(order_ticket)) continue;
        if ((OrderGetString(ORDER_SYMBOL) == _Symbol) &&
            //((ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_BUY_STOP) &&
            (StringFind(OrderGetString(ORDER_COMMENT), EA_RECOVERY_TAG) != -1)){
                recovery_node_ticket = order_ticket;
                recovery_node_price = OrderGetDouble(ORDER_PRICE_OPEN);
                recovery_node_type = OrderGetInteger(ORDER_TYPE);
                break;
            }
        }
    if (!recovery_node_price) return 0;

    // Validate that current price is between the recovery node and grid unit
    double price_current = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    double threshold = recovery_node_price + ((recovery_node_type == ORDER_TYPE_BUY_STOP)? -grid.unit : grid.unit);
    if ((recovery_node_type == ORDER_TYPE_BUY_STOP &&
        (price_current > threshold && price_current < recovery_node_price)) ||
        (recovery_node_type == ORDER_TYPE_SELL_STOP &&
        (price_current < threshold && price_current > recovery_node_price)))
        return recovery_node_ticket;
    return 0;
}

//+------------------------------------------------------------------+
ulong IsContinuationGap(const GridInfo &grid, CTrade &trade_obj){
    if (PositionSelect(_Symbol) || SymbolOrdersTotal() == 0) return 0;

    // Get continuation node
    ulong continuation_node_ticket = 0;
    double continuation_node_price = 0;
    long continuation_node_type = 0;
    for (int i = OrdersTotal() - 1; i >= 0; i--){
        ulong order_ticket = OrderGetTicket(i);
        if (!OrderSelect(order_ticket)) continue;
        if ((OrderGetString(ORDER_SYMBOL) == _Symbol) &&
            (StringFind(OrderGetString(ORDER_COMMENT), EA_CONTINUATION_TAG) != -1)){
                continuation_node_ticket = order_ticket;
                continuation_node_price = OrderGetDouble(ORDER_PRICE_OPEN);
                continuation_node_type = OrderGetInteger(ORDER_TYPE);
                break;
            }
        }
    if (!continuation_node_price) return 0;

    // Validate that current price is between the continuation node and grid unit
    double price_current = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    double threshold = continuation_node_price + ((continuation_node_type == ORDER_TYPE_BUY_STOP)? -grid.unit : grid.unit);
    if ((continuation_node_type == ORDER_TYPE_BUY_STOP &&
        (price_current > threshold && price_current < continuation_node_price)) ||
        (continuation_node_type == ORDER_TYPE_SELL_STOP &&
        (price_current < threshold && price_current > continuation_node_price)))
        return continuation_node_ticket;
    return 0;
}

//+------------------------------------------------------------------+