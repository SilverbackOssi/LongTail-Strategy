
double Sequence[]={0.01, 0.01, 0.02, 0.02, 0.03, 0.04, 0.05, 0.07, 0.09, 0.12, 0.16, 0.22, 0.29, 0.39, 0.52, 0.69, 0.92, 1.23, 1.64, 2.18};
bool use_trading_session = false; // trade 24/7
datetime session_start = StringToTime("08:30");
datetime session_end = StringToTime("18:30");// test server time = real time +1
int session_status;
const int SESSION_RUNNING = 100;
const int SESSION_OVER = 101;
//+------------------------------------------------------------------+

class LTSControl(){
public:// XXX: Dont encapsulate, allow full scope for this project
    //private sequence
    //predefined sequenceLength

    void start(multiplier){
        // define progression sequence
        build_sequence(multiplier, sequenceLength, sequence);
        
        // start Grid
        if (use_trading_session && !IsWithinTradingTime()) return init succesful; // Handles placing EA on chart, outside trading time

        if (!PositionSelect(_Symbol)) 
            { //XXX: handle cases of positions already opened on the chart.
            if (OpenShort(order_volume, EA_TAG)) 
                Print(__FUNCTION__, ": Started trading session with short at market price");
            else return init error, error message "unable to start grid short";
            }
    }

    void Manage(){  
        // manage mismanagement ☑️
        check_strategy_rules();

        // Track new position (a new position is the one the EA has not tracked before)
        // On EA start, last_saved_ticket should be Zero and Type should be buy(Rule 1).
        if (IsNewPosition(last_saved_ticket)) 
            HandleNewPosition();   

        // Track Trading Session
        if (use_trading_session)
        {
            UpdateSesionStatus(session_status, SESSION_RUNNING, SESSION_OVER, session_start, session_end);
            if (session_status == SESSION_OVER) { EndSession();}
            else StartSession(sequence, EA_TAG);
        }
    
        // manage delay ☑️
        check_zero_position();
    }

    void Stop(){
        Print("Logging off...");
        // Log stuff
        // profit or loss
    }
};