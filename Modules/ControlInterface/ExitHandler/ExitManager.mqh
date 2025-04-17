//+------------------------------------------------------------------+
//|                                               ExitManagement.mqh |
//|                                      Copyright 2025, Anyim Ossi. |
//|                                          anyimossi.dev@gmail.com |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+

void set_exits(CTrade &trader, ulong reference_ticket, double stop_size, int target_multiplier,const string ea_tag)
{
    if (PositionSelectByTicket(reference_ticket))
    {
        // Check if the position's comment matches the EA's comment
        string position_comment = PositionGetString(POSITION_COMMENT);
        if (StringFind(position_comment, ea_tag) == -1)
        {
            Print(__FUNCTION__, " - Position was not placed by ",ea_tag,". Skipping ticket: ", reference_ticket);
            return;
        }

        // Retrieve position details
        double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
        long position_type = PositionGetInteger(POSITION_TYPE);

        // Calculate take profit and stop loss
        double target = stop_size * target_multiplier;
        double risk = stop_size;
        double take_profit = (position_type == POSITION_TYPE_BUY) ? open_price + target : open_price - target;
        double stop_loss = (position_type == POSITION_TYPE_BUY) ? open_price - risk : open_price + risk;

        // Modify the position with the new TP and SL values
        bool modified = trader.PositionModify(reference_ticket, stop_loss, take_profit);
        if (modified)
        {
            Print(__FUNCTION__, " - Take profit and stop loss set for ticket: ", reference_ticket, " TP: ", take_profit, " SL: ", stop_loss);
        }
        else
        {
            Print(__FUNCTION__, " - Failed to set take profit and stop loss for ticket: ", reference_ticket);
        }
    }
    else
    {
        Print(__FUNCTION__, " - Reference position not open or invalid ticket: ", reference_ticket);
    }
}
