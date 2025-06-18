//+------------------------------------------------------------------+
//|                                            IntegrationV1.0.0.mq5 |
//|                                      Copyright 2025, Anyim Ossi. |
//|                                          anyimossi.dev@gmail.com |
//+------------------------------------------------------------------+

/* NOTES
Sequence length is based on 10% of account balance
*/

#include  <Ossi\LongTails\SessionManager.mqh>

//--- Global Variables ---
CTrade trade;
GridInfo Grid;
GridBase Base;

// --- Input variables ---
double unit = 2.0;
int LTSMultiplier = 3;
bool use_trading_session = false; // trade 24/7
datetime time_start = StringToTime("08:30");
datetime time_end = StringToTime("18:30");// test server time = real time +1


//+------------------------------------------------------------------+
int OnInit(){
    Print("--- Starting LTS EA ---");
    Print("--- Performing Sanity Checks ---");
    if (!PerformSanityChecks())
        return (INIT_FAILED);
    else Print("--- Passed Sanity Checks ---");

    // Warn User To Perform Chart Cleanup
    if (!IsEmptyChart()){
        int pendining_orders = SymbolOrdersTotal(), open_pos = PositionsTotal();
        Print("Unable to initialize LTS Grid"); 
        if (pendining_orders) Print("Found ",pendining_orders," pending orders on chart");
        if (open_pos) Print("Found ", open_pos," positions in Terminal");
        Print("Please clear all orders and close all open positions in the Terminal");
        Print("Init Error: Unable to start LTS Grid");

        return (INIT_FAILED);
      }

    // --- Initialize CTrade ---
    Print("--- Initializing Trade Object ---");
    trade.SetExpertMagicNumber(EA_MAGIC);         // Although LTS EA relies on comment
    trade.SetTypeFillingBySymbol(_Symbol); 
    trade.SetDeviationInPoints(EA_DEVIATION);      // Allow some slippage
    trade.SetAsyncMode(false); 

    // --- Initialize Grid ---
    Print("--- Initializing LTS Grid Objects ---");
    Grid.Init(unit, LTSMultiplier, use_trading_session,
              time_start, time_end);

    // --- Start Grid ---
    if (use_trading_session && !IsWithinTime(time_start, time_end))
      return(INIT_SUCCEEDED); // Handles placing EA on chart outside trading time    
    Print("--- Starting LTS Grid Session ---");

    StartSession(trade, Base, Grid);
    if (PositionSelectByTicket(Base.ticket)) 
      Print("--- Init Succesful. Started Trading Session ---");

    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }

//+------------------------------------------------------------------+
void OnTick()
  {
//---
  }
//+------------------------------------------------------------------+

