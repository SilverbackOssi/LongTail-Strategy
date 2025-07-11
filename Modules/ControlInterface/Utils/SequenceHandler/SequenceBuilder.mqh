
#ifndef GridUnit_MQH
#define GridUnit_MQH

const string SINGLE_UNIT_PAIRS[]    = {"EURUSD", "GBPUSD",
                                      "AUDUSD", "USDJPY",
                                      "CADJPY", "USDCAD",
                                      "NZDUSD", "USDCHF"};
const int GRIDUNITPOINTS_DEFAULT    =  100;
const int GRIDUNITPOINTS_GOLD       =  200;

#endif // GridUnit_MQH
//+------------------------------------------------------------------+



#ifndef SequenceBuilder_MQH
#define SequenceBuilder_MQH
  //XXX: Add functionaity to fetch grid points for symbol
  // target points = 200 points/20 pips for gold, 100 points/10 pips for others
double target_points = (_Symbol == "XAUUSD") ? GRIDUNITPOINTS_GOLD : GRIDUNITPOINTS_DEFAULT; 

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
    // Minimum term represents 1% of the account balance as per grid size
    double symbol_min_volume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    double account_bal = AccountInfoDouble(ACCOUNT_BALANCE);

    double min_term_cash = 0.001 * AccountInfoDouble(ACCOUNT_BALANCE);// $ = 0.1% of balance
    
    double minimum_term = min_term_cash / target_points; // volume = $/target points
    double min_balance = target_points*10; // $2k for 200points, $1k for 100points

    if ((minimum_term < symbol_min_volume) || (account_bal<=min_balance)) return symbol_min_volume;
    return NormalizeDouble(minimum_term, 2);

  /*
  const int magic_balance = 2000; //$2000, For XAU/USD
   if (account_bal<magic_balance) return symbol_min_volume;
   //get the relationship between account balance and magic balance
   double balance_factor = account_bal/magic_balance;
   
   //return -> multiply minimum volume by that relationship
   return NormalizeDouble(symbol_min_volume*balance_factor,2);
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
   while(true)
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
      if(potential_sequence_cash > (0.1 * account_balance)) // risk 10% 
            break;
         
      
      // Add current term to sequence
      current_size++;
      ArrayResize(progression_sequence, current_size);
      progression_sequence[current_size - 1] = current_term;
   }
}
  
//+------------------------------------------------------------------+
void RebuildSequence(double reward_multiplier, double &progression_sequence[], double &tracked_bal, int percent_target)
{
   // For now we manually add or remove the bot. Each time bot is added it rebuilds the sequence.
   
   double percentage_increase = 1 + (percent_target / 100); //x% increase
   double target = tracked_bal*percentage_increase;
   
   if (AccountInfoDouble(ACCOUNT_BALANCE)>=target)
      {
         // Initiate a 20% withdrawal before sequence rebuild(for 50% increas)
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
