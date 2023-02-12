## Example Maf library

### 1. Check system requirements
- [Node.js](https://nodejs.org/)
- [DFX](https://internetcomputer.org/docs/current/developer-docs/quickstart/local-quickstart) >= 0.10.0
- [Moc](https://github.com/dfinity/motoko/releases) >= 0.8.1

## Source lib maf:
### https://github.com/fury02/async-data-deliveries

## Discussion:
### https://forum.dfinity.org/t/assigned-icdevs-org-bounty-39-async-flow-one-shot-motoko-6-000/17901

## Solving the problem

Description
The IC implements an asynchronous messaging system where requests are made to canisters and a transaction id is returned. The canister then queries the state of this transaction and returns the result when it detects that the function is complete. The Rust CDK and Motoko abstract this away from the user in a way that depends on the IC reliably fulfilling the request with certain guarantees.

Sometimes a canister developer may want to do away with this abstraction and implement their own async flow when the results of the called function are not important to the continuation of their code. This is more event based programming and it is especially useful while the IC still requires functions to return before upgrades can be performed. Future functionality will fix this upgrade issue, but async and event based programming is still a useful pattern when services are interacting. It removes dependencies and allows the developer to slip into an actor based frame of mind that more closely mirrors how the IC is actually working under the covers. Specifically it can keep the developer from making “await” assumptions that open the canister to reentrance attacks.


When a user initiates an async one-shot call they likely do want to handle some kind of response so that they can confirm that the call was received. In turn, the acknowledger needs to know that the acknowledgment was received. You end up with something that looks a lot like a TCP/IP flow.

### Sample Sender
```motoko
import Text "mo:base/Text";
import Maf "../lib";
actor Sender{ 
    type MessageType = Maf.MessageType;//#NEW;#ACK;#FIN 
    type MessageStatus = Maf.MessageStatus;
    type Scaner = Maf.Scaner; //#OFF;#ON
    type Config = Maf.Config;
    private var CONFIG : Config = Maf.DEFAULT_CONFIG;
    //override config
    CONFIG := {
        ATTEMPTS_NEW_MSG = 5;
        ATTEMPTS_ACK_MSG = 0;
        WAITING_TIME = 1_000_000_000; //for local test
        NUMBER_SHIPMENTS_ROUND = 2;
        PERIOD_DURATION = #nanoseconds 500_000_000;
    };
    var lib = Maf.Sender(CONFIG);
    //result from the receiver
    private func HANDLER(
        msg: MessageType){
        switch(msg){
            case(#NEW(new)){ };
            case(#ACK(ack)){ 
                //**Your any code**//
            };
            case(#FIN(fin)){};
        };
    };
    //messages
    public func new_message(
        canister_id: Text, 
        payload: Blob){
        await* lib.new_message(canister_id, payload);
    };
    public shared({caller}) func com_asyncFlow_ack(
        msg: MessageType){ 
            HANDLER(msg);
        await* lib.com_asyncFlow_ack(msg, caller);
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

```
### Sample Receiver
```motoko
import Text "mo:base/Text";
import Maf "../lib";
actor Receiver{
    type MessageType = Maf.MessageType;//#NEW;#ACK;#FIN 
    type MessageStatus = Maf.MessageStatus;
    type Scaner = Maf.Scaner; //#OFF;#ON
    type Config = Maf.Config;
    private var CONFIG : Config = Maf.DEFAULT_CONFIG;
    //override config
    CONFIG := {
        ATTEMPTS_NEW_MSG = 0;
        ATTEMPTS_ACK_MSG = 10;
        WAITING_TIME = 1_000_000_000; //for local test
        NUMBER_SHIPMENTS_ROUND = 20;
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

```

## Version
- 0.0.29
