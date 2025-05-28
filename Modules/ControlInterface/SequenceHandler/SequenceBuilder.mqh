
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
double GetMinimumTerm()
   {
   //get minimum volume: assuming the minimum volume is minimum term for a $2000 account
   double min_volume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);

   //get account balance
   double account_bal = AccountInfoDouble(ACCOUNT_BALANCE);
   Print("account balance: ", account_bal);
   
   if (account_bal<2000) return min_volume;

   //get the relationship between account balance and $2000
   double balance_factor = account_bal/2000;
   
   //return -> multiply minimum volume by that relationship
   return NormalizeDouble(min_volume*balance_factor,2);
   
   }

//+------------------------------------------------------------------+
void BuildSequence(double reward_multiplier, double &progression_sequence[])
  {
   // - Empty the sequence
   ArrayResize(progression_sequence,0);
   
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
     
   Print("DEBUG- Current progression: ");
   ArrayPrint(progression_sequence);
  }
  
//+------------------------------------------------------------------+
void RebuildSequence(double reward_multiplier, double &progression_sequence[], double &tracked_bal, int percent_target)
{
   double percentage_increase = 1 + (percent_target / 100); //x% increase
   double target = tracked_bal*percentage_increase;
   
   if (AccountInfoDouble(ACCOUNT_BALANCE)>=target)
      {
         // Initiate a 20% withdrawal before sequence rebuild
         BuildSequence(reward_multiplier,progression_sequence);
         tracked_bal = AccountInfoDouble(ACCOUNT_BALANCE);
      }
   /*
   compare tracked balance with current balance
   if x% increase
      call build sequence on current progression sequence
      update tracked balance
   */
}  
  
//+------------------------------------------------------------------+

