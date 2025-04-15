
#include <LTSControl.mqh>
#include <Trade\Trade.mqh>
LTSControl Control;
CTrade trade;

input int multiplier = 3;
input int sequenceLength = 50;
double min_volume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
double sequence[];

datetime session_start = StringToTime("08:30");
datetime session_end = StringToTime("18:30");// test server time = real time +1
bool is_end_session = false; // false if session is active(default)
bool use_daily_session = false; // trade 24/7
double grid_size = 2.00;
double grid_spread = 0.40;
ulong last_saved_ticket = 0 ; // default
ENUM_POSITION_TYPE last_saved_type = POSITION_TYPE_SELL; // default

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+


int OnInit()
  {

   // define progression sequence
   Control.Start(multiplier;)

   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
    Control.Stop();
   // Log stuff
   // profit or loss
  }

void OnTick()
  {
    Control.Manage()
  }