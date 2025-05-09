//+------------------------------------------------------------------+
//|                                              SequenceBuilder.mqh |
//|                                      Copyright 2025, Anyim Ossi. |
//|                                          anyimossi.dev@gmail.com |
//+------------------------------------------------------------------+

#include  <Ossi\LongTails\Utils.mqh>

// -- To-Do --
// All functions should operate on any symbol(across modules).
// - ensure set deviation, order filling policy
// - check symbol specifics; min-volume, tick size, tick value.

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void build_sequence(int reward_multiplier, double &progression_sequence[])
  {
   // Initialize variables
   double minimum_term = GetMinimumTerm();
   double minimum_profit = minimum_term * 2;
   double current_term = minimum_term;
   int sequence_length = 50;

   // Compute the progression sequence
   for(int i = 0; i < sequence_length; i++)
     {
      double minimum_outcome = ArraySum(progression_sequence) + minimum_profit;
      while(current_term * reward_multiplier < minimum_outcome)
        {
         current_term += minimum_term;
        }
      ArrayResize(progression_sequence, ArraySize(progression_sequence) + 1);
      progression_sequence[ArraySize(progression_sequence) - 1] = current_term;
     }
  }
//+------------------------------------------------------------------+

double GetMinimumTerm()
   {
   //get minimum volume: assuming the minimum volume is minimum term for a $2000 account
   double min_volume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);

   //get account balance
   double account_bal = AccountInfoDouble(ACCOUNT_BALANCE); Print("account balance: ", account_bal);
   if (account_bal<2000) return min_volume;

   //get the relationship between account balance and $2000
   double balance_factor = account_bal/2000;
   
   //return -> multiply minimum volume by that relationship
   return NormalizeDouble(min_volume*balance_factor,2);
   
   }
//+------------------------------------------------------------------+
void RebuildSequence()
{
  // Updates the progression sequence based on accound balance increase.
  // Update every 10% increase or decrease
}