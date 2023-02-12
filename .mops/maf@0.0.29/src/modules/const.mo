import Types "../types/types";

module{
    public let default_config: Types.Config = {                                    
        ATTEMPTS_NEW_MSG = 10;                                              
        ATTEMPTS_ACK_MSG =10;                                                                    
        WAITING_TIME = 330_000_000_000;                             
        NUMBER_SHIPMENTS_ROUND = 10;                              
        PERIOD_DURATION = #nanoseconds 5_000_000_000;                      
    };                                                                         
}