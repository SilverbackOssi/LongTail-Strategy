
#include <Trade\Trade.mqh>
CTrade trade;

datetime session_start = StringToTime("08:30");
datetime session_end = StringToTime("18:30");// test server time = real time +1
bool is_end_session = false; // false if session is active(default)
bool use_daily_session = false; // trade 24/7
double grid_size = 2.00;
double grid_spread = 0.40;
ulong last_saved_ticket = 0 ; // default
ENUM_POSITION_TYPE last_saved_type = POSITION_TYPE_SELL; // default
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
    // call daily sessions ☑️
    track_daily_session(is_end_session);
    if (use_daily_session && is_end_session && is_empty_chart())
        return;
    // manage mismanagement ☑️
    check_strategy_rules();

    // call new position ☑️
    check_new_position(last_saved_ticket, last_saved_type);
   
    // manage delay ☑️
    check_zero_position();
  }
//+------------------------------------------------------------------+
