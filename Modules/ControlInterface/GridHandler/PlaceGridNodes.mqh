//+------------------------------------------------------------------+
//|                                            PlaceRecoveryStop.mq5 |
//|                                      Copyright 2025, Anyim Ossi. |
//|                                          anyimossi.dev@gmail.com |
//+------------------------------------------------------------------+
#include  <Ossi\LongTails\Utils.mqh>

//+------------------------------------------------------------------+
void OnTest()
  {
//---
   // Test on open position
   ulong ticket = 0;
   if (PositionSelect(_Symbol)){
      ticket = PositionGetInteger(POSITION_TICKET);
      }
   //Test on buy stop
   for (int i = OrdersTotal() - 1; i >= 0; --i)
   {
      ticket = OrderGetTicket(i);
   } 
   
   PlaceRecoveryNode(ticket);  
  }
//+------------------------------------------------------------------+
// Build node structure
//struct...

void PlaceRecoveryNode(ulong reference_ticket, Grid grid)
{
    // Reference ticket type
    ENUM_POSITION_TYPE base_type_position;
    ENUM_ORDER_TYPE base_type_order;

    // Validate reference ticket
    if (PositionSelectByTicket(reference_ticket))
        base_type_position = PositionGetInteger(POSITION_TYPE);
    elseif (OrderSelect(reference_ticket))
        base_type_order = OrderGetInteger(ORDER_TYPE);
        if (base_type_order != ORDER_TYPE_BUY_STOP) // order must be a recovery buy stop
        {
            Print(__FUNCTION__, " - FATAL. Recovery node can only be placed on buy stop"); // Rule 7
            return
        }
    else 
    {
        Print(__FUNCTION__, " - FATAL. Recovery node can only be placed on open position or buy stop"); // Rule 7
      return;
    }

    // Assert Node values
    GridNode node;
    node.name = "Recovery node";
    node = AssertNodeValue(node, reference_ticket, grid);

    // Check if an order already exists at the node price
     ulong ticket_exists = NodeExistsAtPrice(node.price);
     if (ticket_exists!=0)
     {
         Print(__FUNCTION__, " - Recovery node with ticket:",ticket_exists , " already exists at price: ", node.price);
         return;
     }

     // Place a grid node
     string node_comment = EA_TAG +" "+ node.name +" as "+ EnumToString(node.type);
     bool placed = trade.OrderOpen(_Symbol, node.type, node.volume, 0.0, node.price, 0, 0, ORDER_TIME_GTC, 0, node_comment);
     if (!placed)// Potential invalid price,handle stop limit
         Print(__FUNCTION__, " - Failed to place ", node.type, " recovery node on ", EnumToString(((PositionSelectByTicket(reference_ticket))? base_type_position:base_type_order)));
     
}

GridNode AssertNodeValue(GridNode node, ulong ref_ticket, Grid grid)
{
    // If reference ticket is open position
    if (PositionSelectByTicket(ref_ticket))
    {
        // Get ticket details
        long reference_type = PositionGetInteger(POSITION_TYPE);
        double reference_price = PositionGetDouble(POSITION_PRICE_OPEN);
        double stop_loss = PositionGetDouble(POSITION_SL);
        double reference_volume = PositionGetDouble(POSITION_VOLUME);

        // Check if there is a take profit set for the reference position
        if (stop_loss == 0)
            Print(__FUNCTION__, " - WARNING. No stop loss set for open position with ticket: ", ref_ticket);

        // Set order details
        int reference_volume_index = GetValueIndex(reference_volume, grid.progression_sequence); 
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