import Blob "mo:base/Blob";
import Types "../types/types";

module{  
    type MessageType = Types.MessageType;

    public type ICanisterReceiver = actor{
        com_asyncFlow_newMessage: (msg: MessageType) -> ();
        com_asyncFlow_fin: (msg: MessageType) -> ();
    };
    
    public type ICanisterSender = actor{
        com_asyncFlow_ack: (msg: MessageType) -> ();
        new_message: (canister_id: Text, msg_val: Blob) -> ();
    };

}