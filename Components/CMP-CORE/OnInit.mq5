
input int multiplier = 3;
input int sequenceLength = 50;
double min_volume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
double sequence[];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   // define progression sequence
   build_sequence(multiplier, sequenceLength, sequence);
//---
   return(INIT_SUCCEEDED);
  }