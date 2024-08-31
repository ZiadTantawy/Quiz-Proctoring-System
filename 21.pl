/*pred a*/
assign_proctors(AllTAs,Quizzes, TeachingSchedule, ProctoringSchedule):-
	free_schedule(AllTAs, TeachingSchedule, FreeSchedule),
	assign_quizzes(Quizzes, FreeSchedule,ProctoringSchedule).
	
/*pred b*/
free_schedule(_,[],[]).
free_schedule(ALLTAs,[day(Dayname,Schedule)|RestSchedule],[day(Dayname,NewSchedule)|RestFreeSchedule]):-
	slothelper(ALLTAs,Dayname,Schedule,NewSchedule),
	free_schedule(ALLTAs,RestSchedule,RestFreeSchedule).

slothelper(_,_,[],[]).
slothelper(ALLTAs,Dayname,[S|NS],[Newslot|RNextS]):-
	findTA(ALLTAs,Dayname,S,NextS),
	permutation(NextS,Newslot),
	slothelper(ALLTAs,Dayname,NS,RNextS). 

findTA([],_,_,[]).
findTA([ta(Name,Dayoff)|NTA],Dayname,S,NextS):-
	(Dayname = Dayoff ; member(Name,S)),
	findTA(NTA,Dayname,S,NextS).

findTA([ta(Name,Dayoff)|NTA],Dayname,S,[Name|T]):-
	Dayname \= Dayoff,
	\+member(Name,S),
	findTA(NTA,Dayname,S,T).	
/*pred c*/	
assign_quizzes([],_,[]).
assign_quizzes([Q|RQ], FreeSchedule, [proctors(Q,Proctor)|RP]):-
	assign_quiz(Q,FreeSchedule,Proctor),
	Count3 is 1,
	delTA(Q,FreeSchedule,Count3,Proctor,UpdatedSchedule),
	assign_quizzes(RQ,UpdatedSchedule,RP).


delTA(quiz(_,Dayname,Slot,NumTA),[day(SameDay,DaySchedule)|Nday],Count3,Proctors,[day(Dayname,UpdatedSchedule)|Nday]):-
	Dayname = SameDay,
	findSlot(Slot,Count3,Proctors,DaySchedule,UpdatedSchedule).

delTA(quiz(_,Dayname,Slot,NumTA),[day(AnotherDay,DaySchedule)|Nday],Count3,Proctors,[day(AnotherDay,DaySchedule)|UpdatedDays]):-
	Dayname\=AnotherDay,
	delTA(quiz(_,Dayname,Slot,NumTA),Nday,Count3,Proctors,UpdatedDays).

findSlot(Slot,Slot,Proctors,[H|T],[Hnew|T]):-
	delH(H,Proctors,Hnew).
findSlot(Slot,Count4,Proctors,[H|T],[H|T2]):-
	Count3 is Count4 + 1,
	findSlot(Slot,Count3,Proctors,T,T2).
	
delH(_,[],[]).
delH(Oldslot,[H|T],NewDay):-
	delete(Oldslot,H,Newslot),
	delH(Newslot,T,NewDay).

/*pred d*/	
assign_quiz(Quiz, FreeSchedule, AssignedTAs):-
	Count is 1,
	assign_quizDay(Quiz,FreeSchedule,Count,AssignedTAs).

assign_quizDay(quiz(_,Dayname,Slot,NumTA),[day(SameDay,DaySchedule)|_],Count,AssignedTAs):-
	Dayname = SameDay,
	assign_quizSlot(Slot,Count,DaySchedule,TAtemp),
	permutation(TAtemp,Final),
	trans(Final,NumTA,AssignedTAs).

assign_quizDay(quiz(Cname,Dayname,Slot,NumTA),[day(AnotherDay,_)|Nday],Count,AssignedTAs):-
	Dayname\=AnotherDay,
	assign_quizDay(quiz(Cname,Dayname,Slot,NumTA),Nday,Count,AssignedTAs).
assign_quizSlot(Count,Count,[H|_],H).
assign_quizSlot(Slot,Count2,[_|T],TAtemp):-
	Count is Count2 + 1,
	assign_quizSlot(Slot,Count,T,TAtemp).
trans(_,0,[]).	
trans([H|T],NumTA2,[H|Rest]):-
	NumTA is NumTA2 - 1,
	trans(T,NumTA,Rest).