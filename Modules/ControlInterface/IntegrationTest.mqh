//+------------------------------------------------------------------+
//|                                            IntegrationV1.0.0.mq5 |
//|                                      Copyright 2025, Anyim Ossi. |
//|                                          anyimossi.dev@gmail.com |
//+------------------------------------------------------------------+

/* NOTES
Sequence length is based on 10% of account balance
*/

#include  <Ossi\LongTails\SessionManager.mqh>
#include  <Ossi\LongTails\StrictRuleManager.mqh>

//--- Global Grid Variables ---
CTrade trade;
GridInfo Grid;
GridBase Base;

// --- Input variables ---
input int risk_reward_ratio = 3;            // Risk To Reward Ratio
input group "=== Session Management ==="
input bool use_start_stop = true;    // Use Timed Entry?
input group "Time To Start"
input int time_to_start_hour = 8;    // Hour to start (0-23)
input int time_to_start_min  = 30;   // Minute to start (0-59)
input group "Time To End"
input int time_to_end_hour   = 18;   // Hour to end (0-23)
input int time_to_end_min    = 30;   // Minute to end (0-59)

double unit = 2.0;
int LTSMultiplier = risk_reward_ratio;
bool use_trading_session = use_start_stop;

string start = StringFormat("%02d:%02d", time_to_start_hour, time_to_start_min);
string end   = StringFormat("%02d:%02d", time_to_end_hour, time_to_end_min);

datetime time_to_start = StringToTime(start);
datetime time_to_end   = StringToTime(end);         // test server time = real time +1
    

//+------------------------------------------------------------------+
int OnInit(){
    Print("--- Starting LTS EA ---\n");

    Print("--- Performing Sanity Checks ---\n");
    if (!PerformSanityChecks())
        return (INIT_FAILED);
    else Print("--- Passed Sanity Checks ---\n");

    // Warn Perform Chart Cleanup
    if (!IsEmptyChart()){
        int pending_orders = SymbolOrdersTotal(), open_pos = PositionsTotal();
        Print("Unable to initialize LTS Grid"); 
        if (pending_orders) Print("Found ",pending_orders," pending orders on chart");
        if (open_pos) Print("Found ", open_pos," positions in Terminal");
        Print("Please clear all orders and close all open positions in the Terminal");
        Print("Init Error: Unable to start LTS Grid");

        return (INIT_FAILED);
      }

    // --- Initialize CTrade Object---
    Print("--- Initializing Trade Object ---");
    trade.SetExpertMagicNumber(EA_MAGIC);         // Although LTS EA relies on comment
    trade.SetTypeFillingBySymbol(_Symbol); 
    trade.SetDeviationInPoints(EA_DEVIATION);      // Allow some slippage
    trade.SetAsyncMode(false); 

    // --- Initialize Grid ---
    Print("--- Initializing LTS Grid Object ---");
    Grid.Init(unit, LTSMultiplier, use_trading_session, time_to_start, time_to_end);


    // --- Start Grid ---
    if (Grid.use_session && !IsWithinTime(Grid.session_time_start, Grid.session_time_end))
      return(INIT_SUCCEEDED);                     // Handles placing EA on chart outside trading time    
    
    Print("--- Starting LTS Grid Session ---");
    StartSession(trade, Base, Grid);
    if (PositionSelectByTicket(Base.ticket)) 
      Print("--- Init Successful. Started Trading Session ---");
    else {
      Print("--- Init Failed. Unable to find session ticket ---");
      return (INIT_FAILED);
    }

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
    // Skip Irrelevant Tick
    if ( IsEmptyChart() && Grid.use_session && Grid.session_status == SESSION_OVER) return;
    if (Grid.use_session==false) AntiMidnightSlip(trade, Grid);

    // Ensure Behavior
    //EnforceCoreRules(trade, Grid, Base);

    // Track grid motion
    if (IsNewPosition(Base.ticket)) 
        HandleNewPosition(trade, Base, Grid);   
    HandleGridGap(trade, Grid, Base);

    // Track Trading Session
    if (Grid.use_session){
        UpdateSesionStatus(Grid);
        if (Grid.session_status == SESSION_OVER) 
            HandleSessionEnd(trade, Grid);
        else StartSession(trade, Base, Grid);
  
    }
//---
  }
//+------------------------------------------------------------------+

