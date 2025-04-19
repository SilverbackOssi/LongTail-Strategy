//+------------------------------------------------------------------+
//|                                                  TestScripts.mq5 |
//|                                      Copyright 2025, Anyim Ossi. |
//|                                          anyimossi.dev@gmail.com |
//+------------------------------------------------------------------+
#include  <Ossi\LongTails\ExitManager.mqh>
CTrade   trade;

string   EA_TAG                           = "LongTailScalperEA";
double   grid_size                        = 2.00;
int      reward_multiplier                = 3;
double   min_volume                       = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);

void OnStart()
  {

   TestExitManagement TestExit;
   TestExit.SetOnForiegnPosition();
   TestExit.SetOnEAPosition();
   //-----------------------------
   
  }
  
//+------------------------------------------------------------------+
class TestExitManagement{

   ulong ticket;
   
public:
   void SetOnForiegnPosition()
      {
      // Test on open position
      // EA does not act on positions or orders not placed by itself
      if (PositionSelect(_Symbol)){
         ticket = PositionGetInteger(POSITION_TICKET);   
         set_exits(trade, ticket,grid_size, reward_multiplier,EA_TAG);
         }
      else Print("No random position open to place SL/TP");
      }
      
   void SetOnEAPosition()
      {
      // Test on EA-opened position
      trade.Buy(0.01,_Symbol,0,0,0,EA_TAG);
      ticket = trade.ResultOrder();
      set_exits(trade, ticket,grid_size, reward_multiplier,EA_TAG);
      }
   };