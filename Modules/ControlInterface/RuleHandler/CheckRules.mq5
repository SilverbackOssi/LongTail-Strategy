//+------------------------------------------------------------------+
//|                                                   CheckRules.mq5 |
//|                                      Copyright 2025, Anyim Ossi. |
//|                                          anyimossi.dev@gmail.com |
//+------------------------------------------------------------------+
#include  <Ossi\LongTails\Utils.mqh>

void OnTest()
  {

   EnforceStrategyRules();
  }

//+------------------------------------------------------------------+
// Controler funtion checks all rules.
void EnforceStrategyRules()
{
    // Call enforecers
    // Call Checkers 
    
    // consider unseen edge cases
}
//+------------------------------------------------------------------+

void EnforceNoInterference()
{
    // Handle human interference on Position, orrder, and exits.
}

void EnforceCoreRules()
{
    // Check positions excess
    if (PositionsTotal() > 1)
    {
        Print(__FUNCTION__, " - Fatal: More than one position open. Closing older");
        // Close all position except the most recent. access by index
    }

    // Check orders excess
    if (OrdersTotal() > 2)
    {
        Print(__FUNCTION__, " - Fatal error: More than two orders open. Closing older");
        // close all orders except the last two. access by index.
    }

    CheckRules

    // Check postsession lag
    ClearRecoveryLag(CTrade &trader, const Grid &grid);
}

// Check Stop loss and Take profit
void CheckSLTP()
{
    //Loop all open pos on symbol
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        string symbol = PositionGetSymbol(i);
        if (symbol == _Symbol)
        {
            double tp = PositionGetDouble(POSITION_TP);
            double sl = PositionGetDouble(POSITION_SL);
            // Check if TP and SL are set
            if (tp == 0 || sl == 0)
            {
                Print(__FUNCTION__, " - Warning: TP/SL not set for position with ticket: ", PositionGetInteger(POSITION_TICKET));
            }
}
void EnforceGridAccuracy()
{
    //// check if orders are misplaced and properly spread relative to open position
}

// check volume of open position from sequence
void CheckVolumeAccuracy(const Grid &grid)
{
    // Check grid base volume accuracy
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        string symbol=PositionGetSymbol(i);
        if (symbol == _Symbol)
        {
            double volume = PositionGetDouble(POSITION_VOLUME);
            int sequence[] = grid.progression_sequence;
            bool volume_ok = false;

            for (int j = 0; j < ArraySize(sequence); j++)
            {
                if (volume == sequence[j])
                {
                    volume_ok = true;
                    break;
                }
            }

            if (!volume_ok)
            {
                Print(__FUNCTION__, " - Warning: Volume for position with ticket: ", PositionGetInteger(POSITION_TICKET), " does not match any value in the progression sequence array.");
            }
        }
    }
    // Check volume accuracy across all nodes

}
// check that sequence is init accurate to account balance XXX
void CheckSequenceAccuracy(const Grid &grid)
{
    //
}
