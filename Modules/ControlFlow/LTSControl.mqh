
class LTSControl(){

    //private sequence
    //predefined sequenceLength

    void start(multiplier){
        // define progression sequence
        build_sequence(multiplier, sequenceLength, sequence);
    }

    void Manage(){       
        // call daily sessions ☑️
        track_daily_session(is_end_session);
        if (use_daily_session && is_end_session && is_empty_chart())
            return;
        // manage mismanagement ☑️
        check_strategy_rules();

        // call new position ☑️
        check_new_position(last_saved_ticket, last_saved_type);
    
        // manage delay ☑️
        check_zero_position();
    }

    void Stop(){
        Print("Logging off...");
        // Log stuff
        // profit or loss
    }
};