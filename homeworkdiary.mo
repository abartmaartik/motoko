
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Array "mo:base/Array";


actor HomeworkDiary  {

type Homework {
title: Text;
description: Text;
dueDate: Time.Time;
completed: Bool;
};

var homeworkDiary=Buffer.Buffer<Homework>(1);

public func addHomework (homework:Homework):async Nat{
    homeworkDiary.add(homework);
    return homeworkDiary.size()+1;
};

public query func getHomework (index:Nat):async Result.Result<Homework,Text>{
     let result:?Homework=homeworkDiary.getOpt(index);
     switch(result) {
        case(null) { #err("Error on Index" )};  
        case(?content) { #ok(content); };
     };
    
};

public func updateHomework (id:Nat,homework:Homework):async Result.Result<(),Text>{
    let result:?Homework=homeworkDiary.getOpt(id);
    switch(result) {
        case(null) { #err("Error on Index" )};  
        case(?content) { homeworkDiary.put(id,homework); ok() };
     };
};


public func markAsCompleted (id:Nat):async Result.Result<(),Text> {
    let result:Homework=homeworkDiary.getOpt(id);
    switch(result) {
        case(null) { #err("Error on Index" )};  
        case(?content) { homeworkDiary.put(id,{content with completed=true}); #ok() };
     };
};

public func deleteHomework (id:Nat):async Result.Result<(),Text> {
    let result:?Homework=homeworkDiary.getOpt(id);
    switch(result) {
        case(null) { #err("Error on Index" )};  
        case(?content) { let x=homeworkDiary.remove(id); #ok() };
     };
};


public query func getAllHomework(): async [Homework] {
    return Buffer.toArray(homeworkDiary);
};

public query func getPendingHomework(): async [Homework] {
  let pending = Buffer.clone(homeworkDiary);
pending.filterEntries(func(_, x) = x.completed == false);
return Buffer.toArray(pending);
};

public query func searchHomework(searchTerm: Text): async [Homework] {
  let searchTitle = Buffer.clone(homeworkDiary);
  let searchDescription = Buffer.clone(homeworkDiary);
searchTitle.filterEntries(func(_, x) = (x.title==searchTerm ));
searchDescription.filterEntries(func(_, x) = (x.description==searchTerm ));
searchTitle.append(searchDescription);

return Buffer.toArray(searchTitle);
};
}

