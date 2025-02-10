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

void OnStart()
  {
//---
   int sequence[];
   build_sequence(multiplier, sequenceLength, sequence);
   
   Print(StringFormat("\n%dX sequence, length = %d",multiplier, sequenceLength ));
   ArrayPrint(sequence); 
   
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int build_sequence(int reward_multiplier, int sequence_length, int &progression_sequence[])
  {
   // Initialize variables
   int minimum_stake = 1;
   int minimum_profit = minimum_stake * 2;
   int current_stake = minimum_stake;


   // Compute the progression sequence
   for(int i = 0; i < sequence_length; i++)
     {
      int minimum_outcome = ArraySum(progression_sequence) + minimum_profit;
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
int ArraySum(int &array[])
  {
   int sum = 0;
   for(int i = 0; i < ArraySize(array); i++)
     {
      sum += array[i];
     }
   return sum;
  }
//+------------------------------------------------------------------+
