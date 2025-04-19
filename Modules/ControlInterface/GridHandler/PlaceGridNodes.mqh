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
struct GridNode{
    string node_name;
    ENUM_ORDER_TYPE node_type;
    double node_price;
    double node_volume;
};
void PlaceRecoveryNode(ulong reference_ticket)
{
    // validate ticket
    // Build node structure
    // instantiate node
    // declare node.name as "Recovery"
    // assert node value(), return node
    // place node


    // Assert Node values
    ENUM_ORDER_TYPE order_type=0;
    double order_price=0;
    double order_volume=0;
    
    //Affected by open or pending
    // - Price, volume, selecting entitiy

    // If reference ticket is open position
    if (PositionSelectByTicket(reference_ticket))
    {
        // Get ticket details
        long ticket_type = PositionGetInteger(POSITION_TYPE);
        double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
        double stop_loss = PositionGetDouble(POSITION_SL);
        double open_volume = PositionGetDouble(POSITION_VOLUME);

        // Check if there is a take profit set for the reference position
        if (stop_loss == 0)
        {
            Print(__FUNCTION__, " - Failed to place recovery stop order. No stop loss set for reference ticket: ", reference_ticket);
            return;
        }

        // Set order details
        int open_volume_index = GetValueIndex(open_volume,Sequence); 
        order_volume = Sequence[open_volume_index+1];
        order_type = (ticket_type == POSITION_TYPE_SELL) ? ORDER_TYPE_BUY_STOP : ORDER_TYPE_SELL_STOP;
        order_price = (ticket_type == POSITION_TYPE_SELL) ? stop_loss+grid_spread : stop_loss; //XXX: Place on grid_unit
    }

    // If reference ticket is pending order
    else if (OrderSelect(reference_ticket)) // order must be a recovery buy stop
    {       
        // Get ticket details
        long ticket_type = OrderGetInteger(ORDER_TYPE);
        double open_price = OrderGetDouble(ORDER_PRICE_OPEN);
        double open_volume = OrderGetDouble(ORDER_VOLUME_CURRENT);
        string comment = OrderGetString(ORDER_COMMENT);
        
        // Check if the reference order is a recovery buy stop
        if (ticket_type != ORDER_TYPE_BUY_STOP || (StringFind(comment, "recovery") == -1))
        {
            Print(__FUNCTION__, " - Failed to place replacement recovery sell stop order. Reference order: ", reference_ticket, " is not a recovery buy stop");
            return;
        }
        
        // Set order details 
        order_volume = open_volume;
        order_type = ORDER_TYPE_SELL_STOP;
        order_price = open_price - grid_size; 
    }
    else // Reference ticket is  neither open nor pending, it does not exist.
    {
      Print(__FUNCTION__, " - FATAL. Recovery node can only be placed on open position or buy stop");
      return;
    } 

    // Check if an order already exists at the calculated price
     ulong ticket_exists = NodeExistsAtPrice(order_price);
     if (ticket_exists!=0)
     {
         Print(__FUNCTION__, " - Recovery stop order already exists at the calculated price for reference ticket: ",
               reference_ticket, ", order ticket: ", ticket_exists);
         return;
     }

     // Place a stop order opposite to the open/pending position’s type
     string comment = "recovery " + EnumToString(order_type);
     bool placed = trade.OrderOpen(_Symbol, order_type, order_volume, 0.0, order_price, 0, 0, ORDER_TIME_GTC, 0, comment);
     if (placed)
     {
         ulong order_ticket = trade.ResultOrder(); // Get the ticket number of the placed order
         Print(__FUNCTION__, " - Recovery stop order placed on reference ticket: ", reference_ticket, ", order ticket: ", order_ticket, ", comment: ", comment);
     }
     else
     {
         Print(__FUNCTION__, " - Failed to place recovery stop order");// Potential invalid price, need to handle
     }
}

