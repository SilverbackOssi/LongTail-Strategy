//+------------------------------------------------------------------+
//|                                              LIQ Raid Indicator   |
//|                                                                  |
//| Purpose: Identifies liquidity zones based on highs/lows of the    |
//| previous day, week, month, and year. Draws horizontal lines, adds  |
//| labels, triggers alerts on price crosses, and displays a dashboard.|
//| Reference: https://www.mql5.com/en/docs                           |
//+------------------------------------------------------------------+

#property copyright "Your Name"
#property link      "https://www.mql5.com"
#property version   "1.02"
#property strict
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

//--- Input Parameters
input bool ShowDayZones = true;             // Show Previous Day Zones
input color DayHighColor = clrYellow;       // Day High Line Color
input color DayLowColor = clrYellow;        // Day Low Line Color
input ENUM_LINE_STYLE DayLineStyle = STYLE_SOLID; // Day Line Style
input int DayLineWidth = 1;                // Day Line Width
input bool ShowWeekZones = true;            // Show Previous Week Zones
input color WeekHighColor = clrOrange;      // Week High Line Color
input color WeekLowColor = clrOrange;       // Week Low Line Color
input ENUM_LINE_STYLE WeekLineStyle = STYLE_SOLID; // Week Line Style
input int WeekLineWidth = 1;                // Week Line Width
input bool ShowMonthZones = true;           // Show Previous Month Zones
input color MonthHighColor = clrBlue;       // Month High Line Color
input color MonthLowColor = clrBlue;        // Month Low Line Color
input ENUM_LINE_STYLE MonthLineStyle = STYLE_SOLID; // Month Line Style
input int MonthLineWidth = 1;               // Month Line Width
input bool ShowYearZones = true;            // Show Previous Year Zones
input color YearHighColor = clrRed;         // Year High Line Color
input color YearLowColor = clrRed;          // Year Low Line Color
input ENUM_LINE_STYLE YearLineStyle = STYLE_SOLID; // Year Line Style
input int YearLineWidth = 1;               // Year Line Width
input bool ShowLabels = true;               // Show Text Labels
input bool EnableAlerts = true;             // Enable Alerts

//--- Global Variables
double day_high, day_low, week_high, week_low, month_high, month_low, year_high, year_low;
bool day_high_alerted, day_low_alerted, week_high_alerted, week_low_alerted;
bool month_high_alerted, month_low_alerted, year_high_alerted, year_low_alerted;
datetime last_bar_time = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                          |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- Initialize variables
   day_high = 0; day_low = 0; week_high = 0; week_low = 0;
   month_high = 0; month_low = 0; year_high = 0; year_low = 0;
   day_high_alerted = false; day_low_alerted = false;
   week_high_alerted = false; week_low_alerted = false;
   month_high_alerted = false; month_low_alerted = false;
   year_high_alerted = false; year_low_alerted = false;
   last_bar_time = 0;

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, "LIQ_Raid_", 0, -1);
   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Get Previous Day High                                            |
//+------------------------------------------------------------------+
double GetPrevDayHigh()
{
   double highs[];
   if(CopyHigh(_Symbol, PERIOD_D1, 1, 1, highs) <= 0)
      return 0;
   return highs[0];
}

//+------------------------------------------------------------------+
//| Get Previous Day Low                                             |
//+------------------------------------------------------------------+
double GetPrevDayLow()
{
   double lows[];
   if(CopyLow(_Symbol, PERIOD_D1, 1, 1, lows) <= 0)
      return 0;
   return lows[0];
}

//+------------------------------------------------------------------+
//| Get Previous Week High                                           |
//+------------------------------------------------------------------+
double GetPrevWeekHigh()
{
   double highs[];
   if(CopyHigh(_Symbol, PERIOD_W1, 1, 1, highs) <= 0)
      return 0;
   return highs[0];
}

//+------------------------------------------------------------------+
//| Get Previous Week Low                                            |
//+------------------------------------------------------------------+
double GetPrevWeekLow()
{
   double lows[];
   if(CopyLow(_Symbol, PERIOD_W1, 1, 1, lows) <= 0)
      return 0;
   return lows[0];
}

//+------------------------------------------------------------------+
//| Get Previous Month High                                          |
//+------------------------------------------------------------------+
double GetPrevMonthHigh()
{
   double highs[];
   if(CopyHigh(_Symbol, PERIOD_MN1, 1, 1, highs) <= 0)
      return 0;
   return highs[0];
}

//+------------------------------------------------------------------+
//| Get Previous Month Low                                           |
//+------------------------------------------------------------------+
double GetPrevMonthLow()
{
   double lows[];
   if(CopyLow(_Symbol, PERIOD_MN1, 1, 1, lows) <= 0)
      return 0;
   return lows[0];
}

//+------------------------------------------------------------------+
//| Get Previous Year High                                           |
//+------------------------------------------------------------------+
double GetPrevYearHigh()
{
   MqlDateTime current_time;
   if(!TimeToStruct(TimeCurrent(), current_time))
      return 0;
   int prev_year = current_time.year - 1;
   datetime start_time = StringToTime(StringFormat("%d.01.01 00:00:00", prev_year));
   datetime end_time = StringToTime(StringFormat("%d.12.31 23:59:59", prev_year));
   
   int start_bar = iBarShift(_Symbol, PERIOD_D1, start_time, true);
   int end_bar = iBarShift(_Symbol, PERIOD_D1, end_time, true);
   
   if(start_bar <= 0 || end_bar <= 0 || start_bar < end_bar)
      return 0;
   
   int count = start_bar - end_bar + 1;
   double highs[];
   if(CopyHigh(_Symbol, PERIOD_D1, end_bar, count, highs) <= 0)
      return 0;
   
   return highs[ArrayMaximum(highs, 0, count)];
}

//+------------------------------------------------------------------+
//| Get Previous Year Low                                            |
//+------------------------------------------------------------------+
double GetPrevYearLow()
{
   MqlDateTime current_time;
   if(!TimeToStruct(TimeCurrent(), current_time))
      return 0;
   int prev_year = current_time.year - 1;
   datetime start_time = StringToTime(StringFormat("%d.01.01 00:00:00", prev_year));
   datetime end_time = StringToTime(StringFormat("%d.12.31 23:59:59", prev_year));
   
   int start_bar = iBarShift(_Symbol, PERIOD_D1, start_time, true);
   int end_bar = iBarShift(_Symbol, PERIOD_D1, end_time, true);
   
   if(start_bar <= 0 || end_bar <= 0 || start_bar < end_bar)
      return 0;
   
   int count = start_bar - end_bar + 1;
   double lows[];
   if(CopyLow(_Symbol, PERIOD_D1, end_bar, count, lows) <= 0)
      return 0;
   
   return lows[ArrayMinimum(lows, 0, count)];
}

//+------------------------------------------------------------------+
//| Draw Horizontal Line                                             |
//+------------------------------------------------------------------+
void DrawLine(string name, double price, color col, ENUM_LINE_STYLE style, int width)
{
   if(price == 0)
      return;
      
   if(ObjectFind(0, name) < 0)
   {
      if(!ObjectCreate(0, name, OBJ_HLINE, 0, 0, price))
         return;
   }
   else
   {
      ObjectSetDouble(0, name, OBJPROP_PRICE, price);
   }
   
   ObjectSetInteger(0, name, OBJPROP_COLOR, col);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
}

//+------------------------------------------------------------------+
//| Draw Text Label                                                  |
//+------------------------------------------------------------------+
void DrawLabel(string name, string text, double price, color col, datetime time)
{
   if(price == 0)
      return;
      
   if(ObjectFind(0, name) < 0)
   {
      if(!ObjectCreate(0, name, OBJ_TEXT, 0, time, price))
         return;
   }
   else
   {
      ObjectSetDouble(0, name, OBJPROP_PRICE, price);
      ObjectSetInteger(0, name, OBJPROP_TIME, time);
   }
   
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, col);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
}

//+------------------------------------------------------------------+
//| Draw Dashboard Label                                             |
//+------------------------------------------------------------------+
void DrawLabelDashboard(string name, string text, int x, int y)
{
   if(ObjectFind(0, name) < 0)
   {
      if(!ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0))
         return;
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   }
   
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
   ObjectSetString(0, name, OBJPROP_FONT, "Arial");
}

//+------------------------------------------------------------------+
//| Draw Dashboard                                                   |
//+------------------------------------------------------------------+
void DrawDashboard()
{
   int y = 10;
   if(ShowDayZones)
   {
      DrawLabelDashboard("LIQ_Raid_DayHigh", "Prev Day High: " + (day_high > 0 ? DoubleToString(day_high, _Digits) : "N/A"), 10, y);
      y += 15;
      DrawLabelDashboard("LIQ_Raid_DayLow", "Prev Day Low: " + (day_low > 0 ? DoubleToString(day_low, _Digits) : "N/A"), 10, y);
      y += 15;
   }
   if(ShowWeekZones)
   {
      DrawLabelDashboard("LIQ_Raid_WeekHigh", "Prev Week High: " + (week_high > 0 ? DoubleToString(week_high, _Digits) : "N/A"), 10, y);
      y += 15;
      DrawLabelDashboard("LIQ_Raid_WeekLow", "Prev Week Low: " + (week_low > 0 ? DoubleToString(week_low, _Digits) : "N/A"), 10, y);
      y += 15;
   }
   if(ShowMonthZones)
   {
      DrawLabelDashboard("LIQ_Raid_MonthHigh", "Prev Month High: " + (month_high > 0 ? DoubleToString(month_high, _Digits) : "N/A"), 10, y);
      y += 15;
      DrawLabelDashboard("LIQ_Raid_MonthLow", "Prev Month Low: " + (month_low > 0 ? DoubleToString(month_low, _Digits) : "N/A"), 10, y);
      y += 15;
   }
   if(ShowYearZones)
   {
      DrawLabelDashboard("LIQ_Raid_YearHigh", "Prev Year High: " + (year_high > 0 ? DoubleToString(year_high, _Digits) : "N/A"), 10, y);
      y += 15;
      DrawLabelDashboard("LIQ_Raid_YearLow", "Prev Year Low: " + (year_low > 0 ? DoubleToString(year_low, _Digits) : "N/A"), 10, y);
   }
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   //--- Check for sufficient bars
   if(rates_total < 2)
      return(0);
      
   //--- Update levels on new bar
   if(prev_calculated == 0 || time[0] > last_bar_time)
   {
      last_bar_time = time[0];
      
      if(ShowDayZones)
      {
         day_high = GetPrevDayHigh();
         day_low = GetPrevDayLow();
      }
      if(ShowWeekZones)
      {
         week_high = GetPrevWeekHigh();
         week_low = GetPrevWeekLow();
      }
      if(ShowMonthZones)
      {
         month_high = GetPrevMonthHigh();
         month_low = GetPrevMonthLow();
      }
      if(ShowYearZones)
      {
         year_high = GetPrevYearHigh();
         year_low = GetPrevYearLow();
      }
      
      //--- Reset alert flags
      day_high_alerted = false;
      day_low_alerted = false;
      week_high_alerted = false;
      week_low_alerted = false;
      month_high_alerted = false;
      month_low_alerted = false;
      year_high_alerted = false;
      year_low_alerted = false;
   }
   
   //--- Draw lines and labels
   if(ShowDayZones)
   {
      DrawLine("LIQ_Raid_Day_High", day_high, DayHighColor, DayLineStyle, DayLineWidth);
      DrawLine("LIQ_Raid_Day_Low", day_low, DayLowColor, DayLineStyle, DayLineWidth);
      if(ShowLabels)
      {
         DrawLabel("LIQ_Raid_Day_High_Label", "Prev Day High", day_high, DayHighColor, time[0]);
         DrawLabel("LIQ_Raid_Day_Low_Label", "Prev Day Low", day_low, DayLowColor, time[0]);
      }
   }
   if(ShowWeekZones)
   {
      DrawLine("LIQ_Raid_Week_High", week_high, WeekHighColor, WeekLineStyle, WeekLineWidth);
      DrawLine("LIQ_Raid_Week_Low", week_low, WeekLowColor, WeekLineStyle, WeekLineWidth);
      if(ShowLabels)
      {
         DrawLabel("LIQ_Raid_Week_High_Label", "Prev Week High", week_high, WeekHighColor, time[0]);
         DrawLabel("LIQ_Raid_Week_Low_Label", "Prev Week Low", week_low, WeekLowColor, time[0]);
      }
   }
   if(ShowMonthZones)
   {
      DrawLine("LIQ_Raid_Month_High", month_high, MonthHighColor, MonthLineStyle, MonthLineWidth);
      DrawLine("LIQ_Raid_Month_Low", month_low, MonthLowColor, MonthLineStyle, MonthLineWidth);
      if(ShowLabels)
      {
         DrawLabel("LIQ_Raid_Month_High_Label", "Prev Month High", month_high, MonthHighColor, time[0]);
         DrawLabel("LIQ_Raid_Month_Low_Label", "Prev Month Low", month_low, MonthLowColor, time[0]);
      }
   }
   if(ShowYearZones)
   {
      DrawLine("LIQ_Raid_Year_High", year_high, YearHighColor, YearLineStyle, YearLineWidth);
      DrawLine("LIQ_Raid_Year_Low", year_low, YearLowColor, YearLineStyle, YearLineWidth);
      if(ShowLabels)
      {
         DrawLabel("LIQ_Raid_Year_High_Label", "Prev Year High", year_high, YearHighColor, time[0]);
         DrawLabel("LIQ_Raid_Year_Low_Label", "Prev Year Low", year_low, YearLowColor, time[0]);
      }
   }
   
   //--- Draw dashboard
   DrawDashboard();
   
   //--- Check for price crosses and alerts
   double bid;
   if(!SymbolInfoDouble(_Symbol, SYMBOL_BID, bid))
      return(rates_total);
   
   if(EnableAlerts && rates_total > 1)
   {
      if(ShowDayZones)
      {
         if(((close[1] < day_high && bid >= day_high) || (close[1] > day_high && bid <= day_high)) && !day_high_alerted)
         {
            Alert(_Symbol + ": Price crossed Previous Day High at " + DoubleToString(day_high, _Digits));
            day_high_alerted = true;
         }
         if(((close[1] < day_low && bid >= day_low) || (close[1] > day_low && bid <= day_low)) && !day_low_alerted)
         {
            Alert(_Symbol + ": Price crossed Previous Day Low at " + DoubleToString(day_low, _Digits));
            day_low_alerted = true;
         }
      }
      if(ShowWeekZones)
      {
         if(((close[1] < week_high && bid >= week_high) || (close[1] > week_high && bid <= week_high)) && !week_high_alerted)
         {
            Alert(_Symbol + ": Price crossed Previous Week High at " + DoubleToString(week_high, _Digits));
            week_high_alerted = true;
         }
         if(((close[1] < week_low && bid >= week_low) || (close[1] > week_low && bid <= week_low)) && !week_low_alerted)
         {
            Alert(_Symbol + ": Price crossed Previous Week Low at " + DoubleToString(week_low, _Digits));
            week_low_alerted = true;
         }
      }
      if(ShowMonthZones)
      {
         if(((close[1] < month_high && bid >= month_high) || (close[1] > month_high && bid <= month_high)) && !month_high_alerted)
         {
            Alert(_Symbol + ": Price crossed Previous Month High at " + DoubleToString(month_high, _Digits));
            month_high_alerted = true;
         }
         if(((close[1] < month_low && bid >= month_low) || (close[1] > month_low && bid <= month_low)) && !month_low_alerted)
         {
            Alert(_Symbol + ": Price crossed Previous Month Low at " + DoubleToString(month_low, _Digits));
            month_low_alerted = true;
         }
      }
      if(ShowYearZones)
      {
         if(((close[1] < year_high && bid >= year_high) || (close[1] > year_high && bid <= year_high)) && !year_high_alerted)
         {
            Alert(_Symbol + ": Price crossed Previous Year High at " + DoubleToString(year_high, _Digits));
            year_high_alerted = true;
         }
         if(((close[1] < year_low && bid >= year_low) || (close[1] > year_low && bid <= year_low)) && !year_low_alerted)
         {
            Alert(_Symbol + ": Price crossed Previous Year Low at " + DoubleToString(year_low, _Digits));
            year_low_alerted = true;
         }
      }
   }
   
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Usage Instructions                                               |
//+------------------------------------------------------------------+
// To use this indicator:
// 1. Save as "LIQ_Raid_Indicator.mq5" in MQL5/Indicators folder.
// 2. Compile in MetaEditor (F7).
// 3. Attach to a chart in MetaTrader 5 via Navigator or drag-and-drop.
// 4. Customize settings in the Inputs tab (e.g., toggle zones, colors).
// 5. Alerts trigger with default MT5 sound when price crosses a zone.
// 6. Dashboard shows zone values in the top-left corner.
// Note: Ensure sufficient historical data (Tools > Options > Charts) for year zones.