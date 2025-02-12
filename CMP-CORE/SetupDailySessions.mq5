

void manage_daily_sessions()
{
    if (EndSession == false)
    {
        // End a daily session
        if (!is_within_trading_time())
        {
            EndSession = true;
            Print("Ending daily session: Outside trading time.");
            return;
        }
    }
    else if (is_within_trading_time())
    {
        // Start a daily session
        {
            EndSession = false;
            Print("Starting daily session: Within trading time.");
        }

        // Check if an order is on the chart (progression cycle carried over from the previous day)
        if (OrdersTotal() > 0)
        {
            Print("Progression cycle carried over: Proceeding to manage cycle.");
            return;
        }

        // Open a short position at market price if no order is on the chart
        double lot_size = 1.0; // Define your lot size
        double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        bool placed = trade.Sell(lot_size, _Symbol, price, 0, 0, "Short Position");
        if (placed)
        {
            Print("Started new cycle with short position opened at market price: ", price);
        }
        else
        {
            Print("Failed to start new cycle with short position at market price.", price);
        }
    }
}


bool is_within_trading_time()
{
    // Define start and end trading times
    datetime start_time = StringToTime("07:30");
    datetime end_time = StringToTime("17:30");

    // Get the current time adjusted to the same date format
    datetime current_time = TimeCurrent();
    datetime current_time_adjusted = StringToTime(TimeToString(current_time, TIME_MINUTES));

    return (current_time_adjusted >= start_time && current_time_adjusted <= end_time);
}
