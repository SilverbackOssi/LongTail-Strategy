
#include  <Ossi\LongTails\Utils.mqh>
/*
Sequence length is based on 10% of account balance
*/

//--- Global Variables ---
CTrade trade;
GridInfo Grid;

// --- Input variables ---
//

int OnInit()
{
    Print("--- Starting Utils.mqh Tests ---");
    if (!PerformSanityChecks())
        return (INIT_FAILED);

    // --- Initialize CTrade ---
    trade.SetExpertMagicNumber(EA_MAGIC); // Set a specific magic number for tests if needed, though ExitManager relies on comment
    trade.SetTypeFillingBySymbol(_Symbol); 
    trade.SetDeviationInPoints(EA_DEVIATION);      // Allow some slippage
    trade.SetAsyncMode(false); 

    // --- Initialize Grid ---

    // --- Start Grid ---
    if use session & not within session. return(INIT_SUCCEEDED); 

    return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
  {
//---
   
  }

void OnTick()
  {
//---
  }
//+------------------------------------------------------------------+

