
void OnStart()
  {
//--- 
    last_saved_ticket = 0 //default
    check_new_position(last_saved_ticket);
   
  }
//+------------------------------------------------------------------+


void check_new_position(ulong &last_saved)
{
    if (PositionSelect(_Symbol))PositionSelect(_Symbol)
    {
        get open positons ticket;
        ulong open_ticket = ;
        if (last_saved != open positions ticket):
            call set exits
            
            delete all pending orders.
            
            call recovery.
            
            call continuation.
            
            update stored ticket to open ticket
    }
}

void delete_all_pending_orders()
{
    // Loop through all open orders
    for (int i = OrdersTotal() - 1; i >= 0; --i)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            ulong order_ticket = OrderGetInteger(ORDER_TICKET);
            bool deleted = OrderDelete(order_ticket);
            
            if (deleted)
            {
                Print("Deleted order with ticket: ", order_ticket, " and comment: ", OrderGetString(ORDER_COMMENT));
            }
            else
            {
                Print("Failed to delete order with ticket: ", order_ticket, " and comment: ", OrderGetString(ORDER_COMMENT));
            }
        }
    }
}
