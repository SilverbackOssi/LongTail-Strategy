
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
    double []progression_sequence;

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
};
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
void DeletePendingOrders(CTrade &trader, const string symbol)
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
bool IsEmptyChart()
{/* Checks if there are no open positions or pending orders on the current chart*/

  if (!PositionSelect(_Symbol)) return true;
  if (OrdersTotal()==0) return true;
  for (int i = OrdersTotal() - 1; i >= 0; --i)
  {
    ulong order_ticket = OrderGetTicket(i);
    string order_symbol = OrderGetString(ORDER_SYMBOL);
    if (order_symbol == _Symbol) return false;

  }
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
bool OpenShort(double deal_volume, string ea_tag)
{
  // a function that opens a sell position at the current market price
  // with ea comment and position type
  Print("Started trading session with short at market price.");
  // returns if placed or not
  return false;
}
//+------------------------------------------------------------------+
bool IsNewPosition(ulong &saved_ticket)
{
// assumes there's one position open on the chart (Rule 3).
//XXX: Maybe call check rules here
    if (PositionSelect(_Symbol))
    {
        ulong open_ticket = PositionGetInteger(POSITION_TICKET);
        if (saved_ticket != open_ticket) return true; // New position open on chart
    }
    return false;
}
//+------------------------------------------------------------------+