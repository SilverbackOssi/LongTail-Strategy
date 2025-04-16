//+------------------------------------------------------------------+
//|                                                  TestScripts.mq5 |
//|                                      Copyright 2025, Anyim Ossi. |
//|                                          anyimossi.dev@gmail.com |
//+------------------------------------------------------------------+
#include  <Ossi\LongTails\ExitManager.mqh>

CTrade   trade;
double   grid_size = 2.00;
int      reward_multiplier = 3;

void OnStart()
  {

   TestExitManagement TestExit;
   TestExit.SetOnRandomPosition();
   //-----------------------------
   
  }
  
//+------------------------------------------------------------------+
class TestExitManagement{
public:
   void SetOnRandomPosition()
      {
      // Test on open position
      ulong ticket = 0;
      if (PositionSelect(_Symbol)){
         ticket = PositionGetInteger(POSITION_TICKET);
         }
      set_exits(trade, ticket,grid_size, reward_multiplier);
      
      // XXX: Test on EA-opened position
      }
   };