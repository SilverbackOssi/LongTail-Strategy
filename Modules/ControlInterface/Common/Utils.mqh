#ifndef Utils_MQH
#define Utils_MQH

//+------------------------------------------------------------------+
//| Constants and Structures                                         |
//+------------------------------------------------------------------+

#include <Trade\Trade.mqh>
//+------------------------------------------------------------------+

const string EA_TAG = "LongTailsScalper";
const int SESSION_RUNNING = 100;
const int SESSION_OVER = 101;
//+------------------------------------------------------------------+

struct Grid{
    double unit;
    double spread;
    double multiplier;
    double target;
    double progression_sequence[];
    int session_status;
    datetime session_time_start;
    datetime session_time_end;

    // Function to initialize values
    void Init(double grid_unit, double grid_spread, double grid_multiplier) {
        unit = grid_unit;
        spread = grid_spread;
        multiplier = grid_multiplier;
        target = unit * multiplier;
    }
};
struct GridNode{
    string name;
    ENUM_ORDER_TYPE type;
    double price;
    double volume;
    string comment;
};
struct GridBase{
  string name;
  ulong ticket;
  ENUM_POSITION_TYPE type;
  double open_price;
  double volume;
  int volume_index;

  void UpdateGridBase(const ulong pos_ticket) {
    if (PositionSelectByTicket(pos_ticket)) {
        name = PositionGetString(POSITION_COMMENT);
        ticket = pos_ticket;
        type = ENUM_POSITION_TYPE(PositionGetInteger(POSITION_TYPE));
        open_price = PositionGetDouble(POSITION_PRICE_OPEN);
        volume = PositionGetDouble(POSITION_VOLUME);
    } else {
        Print("Failed to update base, could not find position with ticket: ", ticket);
    }
   }
};


//+------------------------------------------------------------------+
//| Assertion Helpers                                                |
//+------------------------------------------------------------------+
bool IsEmptyChart() //PASSED
{/* Checks if there are no open positions or pending orders on the current chart*/

  if (PositionSelect(_Symbol) || SymbolOrdersTotal()>0) return false;
  return true;
}

//+------------------------------------------------------------------+
bool IsWithinTradingTime(datetime start_time, datetime end_time)
{   
    if (start_time>end_time)
    {
      datetime temp = start_time;
      start_time = end_time;
      end_time = temp; 
    }
    datetime current_time = TimeCurrent();
    
    return (current_time >= start_time && current_time <= end_time);
}

//+------------------------------------------------------------------+
bool IsNewPosition(ulong &saved_ticket)
{
// assumes there's one position open on the chart (Rule 3).
    if (PositionSelect(_Symbol))
    {
        ulong open_ticket = PositionGetInteger(POSITION_TICKET);
        if (saved_ticket != open_ticket) return true; // New position open on chart
    }
    return false;
}

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Array Related                                                    |
//+------------------------------------------------------------------+
int GetValueIndex(double value,const double &arr[])
{
   for (int i=0; i<ArraySize(arr); i++)
   {
      if (value==arr[i]) return i;
   }
   return -1;
}

//+------------------------------------------------------------------+
double ArraySum(const double &array[])
  {
   double sum = 0;
   for(int i = 0; i < ArraySize(array); i++)
     {
      sum += array[i];
     }
   return sum;
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Order Related                                                    |
//+------------------------------------------------------------------+
int SymbolOrdersTotal() // PASSED
{
    // returns the total number of orders on the current chart.
    // Do not use for iteration to avoid inaccurate indexing.
    int symbol_total = 0;
    for (int i = OrdersTotal() - 1; i >= 0; --i)
    {
        ulong order_ticket = OrderGetTicket(i);
        if (order_ticket == 0) continue;
        if (OrderGetString(ORDER_SYMBOL) == _Symbol) symbol_total++;
    }
    return symbol_total;
}

//+------------------------------------------------------------------+
void DeleteAllPending(CTrade &trader, const string symbol)
{
    for (int i = OrdersTotal() - 1; i >= 0; --i)
    {
        ulong order_ticket = OrderGetTicket(i);
        string order_symbol = OrderGetString(ORDER_SYMBOL);
        if (order_ticket != 0 && order_symbol == symbol)
        {
            bool deleted = trader.OrderDelete(order_ticket);
            if (deleted)
            {
                Print(__FUNCTION__ ,": Deleted order with ticket: ", order_ticket, " and comment: ", OrderGetString(ORDER_COMMENT));
            }
            else
            {
                Print(__FUNCTION__ ,": Failed to delete order with ticket: ", order_ticket, " and comment: ", OrderGetString(ORDER_COMMENT));
            }
        }
    }
}

//+------------------------------------------------------------------+

void ClearContinuationNodes(CTrade &trader)
{
  for (int i = OrdersTotal() - 1; i >= 0; --i)
  {
    ulong order_ticket = OrderGetTicket(i);
    if (order_ticket == 0) continue;
    if (OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
    string comment = OrderGetString(ORDER_COMMENT);

    // Skip recovery nodes
    if (StringFind(comment, "Recovery") != -1) continue;

    if (trader.OrderDelete(order_ticket))
      Print(__FUNCTION__, ": Deleted order with ticket: ", order_ticket, " and comment: ", comment);
    else
      Print(__FUNCTION__, ": Failed to delete order with ticket: ", order_ticket, " and comment: ", comment);
  }
}

//+------------------------------------------------------------------+
ulong NodeExistsAtPrice(double order_price)
{
    for (int i = OrdersTotal() - 1; i >= 0; --i)
      {
        ulong order_ticket = OrderGetTicket(i);
        if (order_ticket!=0)
            {
            if (OrderGetString(ORDER_SYMBOL) == _Symbol  
               && OrderGetDouble(ORDER_PRICE_OPEN) == order_price)
               {
                return order_ticket;
               }
            }
      }
    return 0;
}

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Position Related                                                 |
//+------------------------------------------------------------------+
ulong OpenShort(double deal_volume, CTrade &trader) {
    // Define trade parameters
    string comment = EA_TAG + " Session Start";

    // Attempt to execute a sell order
    if (trader.Sell(deal_volume, _Symbol, 0, 0, 0, comment)) {
        ulong ticket = trader.ResultOrder();
        Print("Sell order placed successfully. Ticket: ", ticket);
        return ticket; // Trade executed successfully
    } else {
        ResetLastError();
        Print("Failed to place sell order. Error: ", GetLastError());
        return 0; // Trade execution failed
    }
}
//+------------------------------------------------------------------+
ulong OpenLong(double deal_volume, CTrade &trader) {
    // Define trade parameters
    string comment = EA_TAG + " Session Start";

    // Attempt to execute a buy order
    if (trader.Buy(deal_volume, _Symbol, 0, 0, 0, comment)) {
        ulong ticket = trader.ResultOrder();
        Print("Buy order placed successfully. Ticket: ", ticket);
        return ticket; // Trade executed successfully
    }else {
        ResetLastError();
        Print("Failed to place sell order. Error: ", GetLastError());
        return 0; // Trade execution failed
    }
}

//+------------------------------------------------------------------+
#endif // Utils_MQH