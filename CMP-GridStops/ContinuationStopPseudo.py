'''places one order (continuation order) relative to open positions, during trading time

buy stop as continuation position: continuation buy stops are placed grid_spread higher than the long position’s take profit.

sell stop as continuation order: continuation sell stops are placed on the take profit of a short position.
'''

EndSession = True
def place_continuation_stop(reference_ticket):
    if EndSession:
        return
    
    '''if ticket is still open:
    
        #get ticket details
        
        #get lot size as first term of the progression sequence
        
        #place a stop order similar to the open position’s type
    '''
    #else: 
    print(__name__," - reference position not open")#fatal error

