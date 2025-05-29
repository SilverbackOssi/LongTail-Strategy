
#ifndef GridUnit_MQH
#define GridUnit_MQH

const int GRIDUNITPOINTS_DEFAULT    =  100;
const int GRIDUNITPOINTS_GOLD       =  200;

#endif // GridUnit_MQH
//+------------------------------------------------------------------+

#ifndef SequenceBuilder_MQH
#define SequenceBuilder_MQH
  //XXX: Add functionaity to fetch grid points for symbol
double target_points = GRIDUNITPOINTS_GOLD; // target points = 200 points/20 pips

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
    double min_volume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    double account_bal = AccountInfoDouble(ACCOUNT_BALANCE); Print("DEBUG- account balance: ", account_bal);

    double min_term_cash = 0.001 * AccountInfoDouble(ACCOUNT_BALANCE);// $ = 0.1% of balance
    
    double minimum_term = min_term_cash / target_points; // volume = $/target points
    double min_balance = target_points*10; // $2k for 200points, $1k for 100points

    if ((minimum_term < min_volume) || (account_bal<=min_balance)) return min_volume;
    return NormalizeDouble(minimum_term, 2);

  /*
  const int magic_balance = 2000; //$2000, For XAU/USD
   if (account_bal<magic_balance) return min_volume;
   //get the relationship between account balance and magic balance
   double balance_factor = account_bal/magic_balance;
   
   //return -> multiply minimum volume by that relationship
   return NormalizeDouble(min_volume*balance_factor,2);
   */
   }

//+------------------------------------------------------------------+
void BuildSequence(double reward_multiplier, double &progression_sequence[])
{
   // - Empty the sequence
   ArrayResize(progression_sequence,0);
   
   // Initialize variables
   double minimum_term = GetMinimumTerm(); // represents 0.1% of account balance
   // 0.1% of balance = minimum_term * target_points
   // 100% of balance = 0.1% of balance * 1000

   double minimum_profit = minimum_term * 2;
   double current_term = minimum_term;
   int current_size = 0;
   double account_balance = AccountInfoDouble(ACCOUNT_BALANCE);

   // Compute the progression sequence
   while(True)
   {
      // Calculate minimum required outcome for this iteration
      double minimum_outcome = ArraySum(progression_sequence) + minimum_profit;
      
      // Adjust current term until it meets minimum outcome requirement
      while(current_term * reward_multiplier < minimum_outcome)
      {
         current_term += minimum_term;
      }
      
      // Check if adding current term would exceed account balance
      double potential_sequence_cash = (ArraySum(progression_sequence) + current_term) * target_points;
      if(potential_sequence_cash >= account_balance) 
         break;
      
      // Add current term to sequence
      current_size++;
      ArrayResize(progression_sequence, current_size);
      progression_sequence[current_size - 1] = current_term;
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
#endif // SequenceBuilder_MQH
