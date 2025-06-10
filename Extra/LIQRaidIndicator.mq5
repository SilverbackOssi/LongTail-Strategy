//+------------------------------------------------------------------+
//|                                              LIQ Raid Indicator  |
//|                                                                  |
//| This indicator identifies liquidity zones based on the highs and |
//| lows of the previous day, week, month, and year. It draws lines, |
//| adds labels, uses the built-in Alert function for notifications, |
//| and shows a dashboard.                                          |
//+------------------------------------------------------------------+

#property copyright "Anyim Ossi."
#property link      "anyimossi.dev@gmail.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

//--- Input Parameters
input bool ShowDayZones = true;             // Show Previous Day Zones
input color DayHighColor = clrYellow;       // Day High Line Color
input color DayLowColor = clrYellow;        // Day Low Line Color
input ENUM_LINE_STYLE DayLineStyle = STYLE_SOLID; // Day Line Style
input int DayLineWidth = 1;                 // Day Line Width
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
input int YearLineWidth = 1;                // Year Line Width
input bool ShowLabels = true;               // Show Text Labels
input bool EnableAlerts = true;             // Enable Sound Alerts
//input string AlertSoundFile = "alert.wav";  // Alert Sound File (place in MT5/Sounds folder)

//--- Global Variables
double day_high, day_low, week_high, week_low, month_high, month_low, year_high, year_low;
bool day_high_alerted, day_low_alerted, week_high_alerted, week_low_alerted;
bool month_high_alerted, month_low_alerted, year_high_alerted, year_low_alerted;
datetime last_bar_time = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, "LIQ_Raid_", -1, -1);
}

//+------------------------------------------------------------------+
//| Get Previous Day High                                            |
//+------------------------------------------------------------------+
double GetPrevDayHigh()
{
   double high = iHigh(NULL, PERIOD_D1, 1);
   if(high == 0) return 0;
   return high;
}

//+------------------------------------------------------------------+
//| Get Previous Day Low                                             |
//+------------------------------------------------------------------+
double GetPrevDayLow()
{
   double low = iLow(NULL, PERIOD_D1, 1);
   if(low == 0) return 0;
   return low;
}

//+------------------------------------------------------------------+
//| Get Previous Week High                                           |
//+------------------------------------------------------------------+
double GetPrevWeekHigh()
{
   double high = iHigh(NULL, PERIOD_W1, 1);
   if(high == 0) return 0;
   return high;
}

//+------------------------------------------------------------------+
//| Get Previous Week Low                                            |
//+------------------------------------------------------------------+
double GetPrevWeekLow()
{
   double low = iLow(NULL, PERIOD_W1, 1);
   if(low == 0) return 0;
   return low;
}

//+------------------------------------------------------------------+
//| Get Previous Month High                                          |
//+------------------------------------------------------------------+
double GetPrevMonthHigh()
{
   double high = iHigh(NULL, PERIOD_MN1, 1);
   if(high == 0) return 0;
   return high;
}

//+------------------------------------------------------------------+
//| Get Previous Month Low                                           |
//+------------------------------------------------------------------+
double GetPrevMonthLow()
{
   double low = iLow(NULL, PERIOD_MN1, 1);
   if(low == 0) return 0;
   return low;
}

//+------------------------------------------------------------------+
//| Get Previous Year High                                           |
//+------------------------------------------------------------------+
double GetPrevYearHigh()
{
   int prev_year = TimeYear(TimeCurrent()) - 1;
   string start_str = StringFormat("%d.01.01 00:00:00", prev_year);
   string end_str = StringFormat("%d.12.31 23:59:59", prev_year);
   datetime start_time = StringToTime(start_str);
   datetime end_time = StringToTime(end_str);
   
   int start_bar = iBarShift(NULL, PERIOD_D1, start_time);
   int end_bar = iBarShift(NULL, PERIOD_D1, end_time);
   
   if(start_bar < 0 || end_bar < 0 || start_bar < end_bar) return 0;
   
   int count = start_bar - end_bar + 1;
   double highs[];
   int copied = CopyHigh(NULL, PERIOD_D1, end_bar, count, highs);
   if(copied <= 0) return 0;
   
   int max_idx = ArrayMaximum(highs);
   return highs[max_idx];
}

//+------------------------------------------------------------------+
//| Get Previous Year Low                                            |
//+------------------------------------------------------------------+
double GetPrevYearLow()
{
   int prev_year = TimeYear(TimeCurrent()) - 1;
   string start_str = StringFormat("%d.01.01 00:00:00", prev_year);
   string end_str = StringFormat("%d.12.31 23:59:59", prev_year);
   datetime start_time = StringToTime(start_str);
   datetime end_time = StringToTime(end_str);
   
   int start_bar = iBarShift(NULL, PERIOD_D1, start_time);
   int end_bar = iBarShift(NULL, PERIOD_D1, end_time);
   
   if(start_bar < 0 || end_bar < 0 || start_bar < end_bar) return 0;
   
   int count = start_bar - end_bar + 1;
   double lows[];
   int copied = CopyLow(NULL, PERIOD_D1, end_bar, count, lows);
   if(copied <= 0) return 0;
   
   int min_idx = ArrayMinimum(lows);
   return lows[min_idx];
}

//+------------------------------------------------------------------+
//| Draw Horizontal Line                                             |
//+------------------------------------------------------------------+
void DrawLine(string name, double price, color col, ENUM_LINE_STYLE style, int width)
{
   if(price == 0) return;
   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_HLINE, 0, 0, price);
   }
   else
   {
      ObjectSetDouble(0, name, OBJPROP_PRICE, price);
   }
   ObjectSetInteger(0, name, OBJPROP_COLOR, col);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
}

//+------------------------------------------------------------------+
//| Draw Text Label                                                  |
//+------------------------------------------------------------------+
void DrawLabel(string name, string text, double price, color col, datetime time)
{
   if(price == 0) return;
   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_TEXT, 0, time, price);
   }
   else
   {
      ObjectSetDouble(0, name, OBJPROP_PRICE, price);
      ObjectSetInteger(0, name, OBJPROP_TIME, time);
   }
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, col);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT);
}

//+------------------------------------------------------------------+
//| Draw Dashboard Label                                             |
//+------------------------------------------------------------------+
void DrawLabelDashboard(string name, string text, int x, int y)
{
   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   }
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
}

//+------------------------------------------------------------------+
//| Draw Dashboard                                                   |
//+------------------------------------------------------------------+
void DrawDashboard()
{
   int y = 10;
   if(ShowDayZones)
   {
      DrawLabelDashboard("LIQ_Raid_Dashboard_DayHigh", "Prev Day High: " + DoubleToString(day_high, _Digits), 10, y);
      y += 15;
      DrawLabelDashboard("LIQ_Raid_Dashboard_DayLow", "Prev Day Low: " + DoubleToString(day_low, _Digits), 10, y);
      y += 15;
   }
   if(ShowWeekZones)
   {
      DrawLabelDashboard("LIQ_Raid_Dashboard_WeekHigh", "Prev Week High: " + DoubleToString(week_high, _Digits), 10, y);
      y += 15;
      DrawLabelDashboard("LIQ_Raid_Dashboard_WeekLow", "Prev Week Low: " + DoubleToString(week_low, _Digits), 10, y);
      y += 15;
   }
   if(ShowMonthZones)
   {
      DrawLabelDashboard("LIQ_Raid_Dashboard_MonthHigh", "Prev Month High: " + DoubleToString(month_high, _Digits), 10, y);
      y += 15;
      DrawLabelDashboard("LIQ_Raid_Dashboard_MonthLow", "Prev Month Low: " + DoubleToString(month_low, _Digits), 10, y);
      y += 15;
   }
   if(ShowYearZones)
   {
      DrawLabelDashboard("LIQ_Raid_Dashboard_YearHigh", "Prev Year High: " + DoubleToString(year_high, _Digits), 10, y);
      y += 15;
      DrawLabelDashboard("LIQ_Raid_Dashboard_YearLow", "Prev Year Low: " + DoubleToString(year_low, _Digits), 10, y);
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
   //--- Update levels on new bar
   if(prev_calculated == 0 || time[0] != last_bar_time)
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
      
      //--- Reset alerted flags
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
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(EnableAlerts)
   {
      if(ShowDayZones)
      {
         if(((close[1] < day_high && bid > day_high) || (close[1] > day_high && bid < day_high)) && !day_high_alerted)
         {
            Alert("Price crossed Previous Day High");
            day_high_alerted = true;
         }
         if(((close[1] < day_low && bid > day_low) || (close[1] > day_low && bid < day_low)) && !day_low_alerted)
         {
            Alert("Price crossed Previous Day Low");
            day_low_alerted = true;
         }
      }
      if(ShowWeekZones)
      {
         if(((close[1] < week_high && bid > week_high) || (close[1] > week_high && bid < week_high)) && !week_high_alerted)
         {
            Alert("Price crossed Previous Week High");
            week_high_alerted = true;
         }
         if(((close[1] < week_low && bid > week_low) || (close[1] > week_low && bid < week_low)) && !week_low_alerted)
         {
            Alert("Price crossed Previous Week Low");
            week_low_alerted = true;
         }
      }
      if(ShowMonthZones)
      {
         if(((close[1] < month_high && bid > month_high) || (close[1] > month_high && bid < month_high)) && !month_high_alerted)
         {
            Alert("Price crossed Previous Month High");
            month_high_alerted = true;
         }
         if(((close[1] < month_low && bid > month_low) || (close[1] > month_low && bid < month_low)) && !month_low_alerted)
         {
            Alert("Price crossed Previous Month Low");
            month_low_alerted = true;
         }
      }
      if(ShowYearZones)
      {
         if(((close[1] < year_high && bid > year_high) || (close[1] > year_high && bid < year_high)) && !year_high_alerted)
         {
            Alert("Price crossed Previous Year High");
            year_high_alerted = true;
         }
         if(((close[1] < year_low && bid > year_low) || (close[1] > year_low && bid < year_low)) && !year_low_alerted)
         {
            Alert("Price crossed Previous Year Low");
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
// 1. Save this file as "LIQ_Raid_Indicator.mq5" in the MQL5/Indicators folder.
// 2. Compile the indicator in MetaEditor.
// 3. Attach the indicator to any chart in MetaTrader 5.
// 4. Customize settings via the Inputs tab (e.g., toggle zones, change colors).
// 5. The built-in Alert function will trigger a sound and message when price crosses a zone.
// 6. The dashboard displays zone values in the top-left corner of the chart.
// Note: Ensure sufficient historical data is loaded for accurate year zone calculations.