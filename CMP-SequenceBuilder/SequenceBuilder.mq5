//+------------------------------------------------------------------+
//|                                              SequenceBuilder.mq5 |
//|                                      Copyright 2025, Anyim Ossi. |
//|                                          anyimossi.dev@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Anyim Ossi."
#property link      "anyimossi.dev@gmail.com"
#property version   "1.00"
#property  script_show_inputs
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
input int multiplier = 3;
input int sequenceLength = 20;
double min_volume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);

void OnStart()
  {
//---
   double sequence[];
   build_sequence(multiplier, sequenceLength, sequence);
   
   Print(StringFormat("\n%dX sequence, length = %d",multiplier, sequenceLength ));
   ArrayPrint(sequence); 
   
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int build_sequence(int reward_multiplier, int sequence_length, double &progression_sequence[])
  {
   // Initialize variables
   double minimum_stake = min_volume;
   double minimum_profit = minimum_stake * 2;
   double current_stake = minimum_stake;


   // Compute the progression sequence
   for(int i = 0; i < sequence_length; i++)
     {
      double minimum_outcome = ArraySum(progression_sequence) + minimum_profit;
      while(current_stake * reward_multiplier < minimum_outcome)
        {
         current_stake += minimum_stake;
        }
      ArrayResize(progression_sequence, ArraySize(progression_sequence) + 1);
      progression_sequence[ArraySize(progression_sequence) - 1] = current_stake;
     }

   return(0);
  }
//+------------------------------------------------------------------+

// Helper function to sum the elements of an array
double ArraySum(double &array[])
  {
   double sum = 0;
   for(int i = 0; i < ArraySize(array); i++)
     {
      sum += array[i];
     }
   return sum;
  }
//+------------------------------------------------------------------+

void build_lot_sequence(const double &progression_sequence[], double &lot_sequence[])
{
  // optionally take account balance as param
  // normalize double to 5
  double sequence_factor = progression_sequence[0]/minimum_volume;

  lot_sequence = {};
  for (int i=0; i<ArraySize(progression_sequence); i++)
  {
    lot_sequence[i] = progression_sequence[i]/sequence_factor;
  }
  arrayprint(lot_sequence);
}
