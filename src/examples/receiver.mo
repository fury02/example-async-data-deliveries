import Blob "mo:base/Blob";
import Time "mo:base/Time";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Iter "mo:base/Iter";
import Text "mo:base/Text";

import { cancelTimer; setTimer } = "mo:⛔";
import Timer "mo:base/Timer";

import Maf "mo:maf";
import Util "util";  

import Debug "mo:base/Debug";

                                        //***CONFIG***//

//                                            ***                                           //
//                      let default_config: Config = {                                      //
//                              ATTEMPTS_NEW_MSG = 10;                                      //
//                              ATTEMPTS_ACK_MSG =10;                                       //
//                              WAITING_TIME = 330_000_000_000;                             // Do not change the IC in the network!!!
//                              NUMBER_SHIPMENTS_ROUND = 10;                                //
//                              PERIOD_DURATION = #nanoseconds 5_000_000_000;               //
//                      };                                                                  //
//                                            ***                                           //

// - Number of attempts by the sender:
// ATTEMPTS_NEW_MSG > 1
// - Number of attempts by the receiver:
// ATTEMPTS_ACK_MSG > 1
// - System time!!!:
// WAITING_TIME = 330_000_000_000;
// Scan interval for queue detection:
// PERIOD_DURATION >= 500_000_000
// -Number of requests to resend 
// NUMBER_SHIPMENTS_ROUND > 0
                                        //**Sample handler**//
                                        
// public shared({caller}) func handler(
//         payload: Blob): async Blob {
//             //A far-fetched example where the hash of a blob 
//             //message is calculated and converted back to a blob
//             let hash: Nat32 = Blob.hash(payload);
//             let text: Text = Nat32.toText(hash);
//             let blob: Blob = Text.encodeUtf8(text);
//             return blob;
// };
                                //***Optional utilities***///
// -Stop monitoring and sending messages if necessary                                        
// public func stop_scaner() {lib.stop_scaner();};
// -Start monitoring and sending messages if necessary   
// public func start_scaner() {lib.start_scaner();};
// public func restart_scaner() {lib.restart_scaner();};
// -Check the status of the scanner
// public func status_scaner(): async Scaner{ return lib.status_scaner();};
// -Number of messages in the queue in case of sending problems
// public func count(): async Nat{ return lib.count();};
// -Get any message
// public func message_default(): async ?MessageStatus { return lib.message_default();};
// -Get the first list to resend
// public func collection_by_time() : async [?MessageStatus] { return lib.collection_by_time();};
// public func clear() {states.clear();};
                                    //***Types***//
// public type MsgId = Maf.MsgId;
// public type Time = Maf.Time;
// public type MessageType = Maf.MessageType;
// public type MessageStatus = Maf.MessageStatus;
// public type Scaner = Maf.Scaner; 
// public type Config = Maf.Config;
                                //***Override config (sample)***//
// type Config = Maf.Config;
//     private var CONFIG : Config = Maf.DEFAULT_CONFIG;
//     //override config
// CONFIG := {
//  ATTEMPTS_NEW_MSG = 3;
//  ATTEMPTS_ACK_MSG = 3;
//  QUEUE_TIME = 300_000_000_000;
//  WAITING_TIME = 1_000_000_000; //for local test
//  NUMBER_SHIPMENTS_ROUND = 3;
//  ERIOD_DURATION = #nanoseconds 500_000_000;

actor Receiver{
    type MessageType = Maf.MessageType;//#NEW;#ACK;#FIN 
    type MessageStatus = Maf.MessageStatus;
    type Scaner = Maf.Scaner; //#OFF;#ON
    type Config = Maf.Config;
    private var CONFIG : Config = Maf.DEFAULT_CONFIG;
    //override config
    CONFIG := {
        ATTEMPTS_NEW_MSG = 0;
        ATTEMPTS_ACK_MSG = 5;
        WAITING_TIME = 1_000_000_000; //for local test
        NUMBER_SHIPMENTS_ROUND = 5;
        PERIOD_DURATION = #nanoseconds 500_000_000;
    };
    private func handler(
        payload: Blob): async* Blob {
            var result = Util.factorial(18000);//test
            //**Your any code**//
            return Text.encodeUtf8("");//plug
    };
    var lib = Maf.Receiver(CONFIG, handler);
    //messages
    public shared({caller}) func com_asyncFlow_newMessage(
        msg: MessageType){   
        await* lib.com_asyncFlow_newMessage(msg, caller);
    };
    public shared({caller}) func com_asyncFlow_fin(
        msg: MessageType){
        lib.com_asyncFlow_fin(msg);
    };
    //Optional utilities
    public func stop_scaner() {lib.stop_scaner();};
    public func start_scaner() {lib.start_scaner();};
    public func restart_scaner() {lib.restart_scaner();};
    public func status_scaner(): async Scaner{ return lib.status_scaner();};
    public func clear() {lib.clear();};
    public func count(): async Nat{ return lib.count();};
    public func message_default(): async ?MessageStatus { return lib.message_default();};
    public func collection_by_time() : async [?MessageStatus] { return lib.collection_by_time();};
}