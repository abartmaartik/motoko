
import IC "ic";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Hash "mo:base/Hash";
import Result "mo:base/Result";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import bool "mo:base/Bool";
import Principal "mo:base/Principal";
import Error "mo:base/Error";
import Option "mo:base/Option";



actor Verifier {


public type StudentProfile = {
    name : Text;
    team : Text;
    graduate : Bool;
};
// Part
var studentProfileStore=HashMap.HashMap<Principal,StudentProfile>(5,Principal.equal,Principal.hash);  

public shared ({caller})func addMyProfile(profile:StudentProfile):async Result.Result<(),Text>{
 try {
   studentProfileStore.put(caller,profile);
   #ok(());
}catch(err){
  #err("Error in adding profile");
    
};
};

public query func seeAProfile(p:Principal):async Result.Result<StudentProfile,Text>{
   let getprofile:?StudentProfile=(studentProfileStore.get(p));
   switch(getprofile){
     case (?profile){
       #ok(profile);
     };
     case (null){
       #err("No profile found");
     };
   };
};

public shared ({caller}) func updateMyProfile(profile:StudentProfile):async Result.Result<(), Text>{
     

     let result = studentProfileStore.get(caller);

switch(result){
case(null)#err( "An error occured");
case (?result){
let updateProf : StudentProfile = {
name = profile.name;
team = profile.team;
graduate= true;
};

studentProfileStore.put(caller, updateProf);
#ok(());

};

};
};

public shared ({caller}) func deleteMyProfile():async Result.Result<(), Text>{
  let result = studentProfileStore.get(caller);

switch(result){
case(null)#err( "An error occured");
case (?result){
 studentProfileStore.delete(caller);
#ok(());

};

};
};

// Part 2

public type TestResult = Result.Result<(), TestError>;
public type TestError = {
    #UnexpectedValue : Text;
    #UnexpectedError : Text;
};



public func test(canisterId : Principal) : async TestResult {
    let calculator : actor { 
       reset : () -> async Int;
    add : (Int) -> async Int;
    sub : (Int) -> async Int;
     }= actor (Principal.toText(canisterId));

    try {  
      let addTest = await calculator.add(1);
      if (addTest !=1){
         return #err(#UnexpectedValue("Expected value of add does not match"));
      };
      
      let subTest = await calculator.sub(2);
      if (subTest !=-1){
         return #err(#UnexpectedValue("Expected value of sub does not match"));
      };
      
        let resetTest = await calculator.reset() ;
      if (resetTest != 0) {
        return #err(#UnexpectedValue("Expected value of reset does not match"));
      };

      return #ok();
    }
    catch(Error){
      return #err(#UnexpectedError("Error occured"));
    };

    
  };


// Part 3


type ManagementCanister=IC.ManagementCanister;


func parseControllersFromCanisterStatusErrorIfCallerNotController(errorMessage : Text) : [Principal] {
    let lines = Iter.toArray(Text.split(errorMessage, #text("\n")));
    let words = Iter.toArray(Text.split(lines[1], #text(" ")));
    var i = 2;
    let controllers = Buffer.Buffer<Principal>(0);
    while (i < words.size()) {
      controllers.add(Principal.fromText(words[i]));
      i += 1;
    };
    Buffer.toArray<Principal>(controllers);
  };

public func verifyOwnership(canisterId:Principal,principalId:Principal):async Bool{
    let ManagementCanister : ManagementCanister = actor("aaaaa-aa");

    try {
      let status = await ManagementCanister.canister_status({canister_id = canisterId});
      return true;

      
    }
    catch(e){
      let errorMessage = Error.message(e);
      let controllers = parseControllersFromCanisterStatusErrorIfCallerNotController(errorMessage);
      for (i in controllers.vals()){
        if (i == principalId){
          return true;
        };
      };
 return false;
      }
    };


// Part 4
public func verifyWork(canisterId:Principal,principalId:Principal):async Result.Result<(),Text>{
  

  var  hvname:Text="";
  var hvteam:Text="";

  switch(studentProfileStore.get(principalId)){
    case (null){return #err("No profile found");};
    case (?profile){hvname:=profile.name;hvteam:=profile.team;};
  };

  let testresult=await test(canisterId);
  let isowner=await verifyOwnership(canisterId,principalId);

  if(isowner){
    
    if(testresult==#ok()){
      let updateProf : StudentProfile = {
name = hvname;
team = hvteam;
graduate= true;
};
      studentProfileStore.put(principalId,updateProf);

    #ok(());


  }
else {
  #err("Test failed");
};
}
else {
  #err("Not owner");
};

};







};
