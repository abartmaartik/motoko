import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Order "mo:base/Order";
import Int "mo:base/Int";



actor StudentWall {

public type Content = {
    #Text: Text;
    #Image: Blob;
    #Video: Blob;
};


type Message = {
vote : Int;
content : Content;
creator : Principal,
};

var messageId : Nat = 0;
var wall= HashMap.HashMap<Nat,Message>(1,Nat.equal, Hash.hash);

public shared ({ caller }) func writeMessage(c : Content) : async Nat {

    let current : Nat = messageId;
    messageId+=1;
    let newMessage : Message = {
      content = d;
      vote = 0;
      creator = caller;
    };
    wall.put(current, newMessage);

    return current;
  };

 public query func getMessage(messageId : Nat) : async Result.Result<Message, Text> {

        let message : ?Message = wall.get(messageId);

        switch(message) {
            case(null){
                #err("No message found");
            };
            case(?message){
                #ok(message);
            };
        };
    };



 public shared ({caller})func updateMessage(messageId : Nat, c : Content) :async Result.Result<(),Text>{
 
    let message : ?Message = wall.get(messageId);
    
        switch(message) {
            case(null){
                #err("No message found");
            };

            case(?message){
                if(message.creator != caller){
        #err("You are not the creator of this message");
    } else{

                let newMessage : Message = {
                    content = c;
                    vote = message.vote;
                    creator = message,creator;
                };
                wall.put(messageId, newMessage);
                #ok(());
            };
            };
 
 };

};

public func deleteMessage(messageId:Nat):async Result.Result<(),Text>{

let message:?Message=wall.get(messageId);
 
 switch(message){
    case(null)
    {#err("No message found");};
    case(?message){
            wall.delete(messageId);
            #ok(());
        };
    };
    };



public func upVote(messageId:Nat):async Result.Result<(),Text>{
   let message:?Message=wall.get(messageId);

   switch(message){
   case(null){
    #err("No message found");
};
   case(?message){
    let newMessage:Message={
        content=message.content;
        vote=message.vote+1;
        creator=message.creator;
    };
    wall.put(messageId,newMessage);
    #ok(());
};
};
};

public func downVote(messageId:Nat):async Result.Result<(),Text>{
  let message:?Message=wall.get(messageId);

   switch(message){
   case(null){
    #err("No message found");
};
   case(?message){
    let newMessage:Message={
        content=message.content;
        vote=message.vote-1;
        creator=message.creator;
    };
    wall.put(messageId,newMessage);
    #ok(());
};
};
};



public query func getAllMessages():async [Message]{
    let buffer=Buffer.Buffer<Message>(0);
    for (i in wall.vals()){
        buffer.add(i);
    };
    return Buffer.toArray(buffer);
};

func sortingfunc(x : Message, y : Message) : Order.Order {
    if (x.vote < y.vote) { #less } else if (x.vote== y.vote) { #equal } else {
            #greater;
    };
};

public query func getAllMessagesRanked() : async [Message] {
    let messages = Iter.toArray(wall.vals());
    var rankedmessages=Array.sort(messages,sortingfunc);
    return rankedmessages;
   
  };

}








