/#####################################################
/##########Whatsapp analytics script##################
/#			  Author:Angus Wilson				     #
/#####################################################
/# Open a whatsapp convo, click : in top right.	     #
/# more > email chat. Send without media to yourself #
/# drop the file in q directory next to this script  #
/# edit chat name below, and run script.			 #
/#													 #
/#####################################################
/#													 #
/#	chatTable is the variable with full parsed log	 #
/#													 #
/#	use qStudio to plot tables to see volumes etc	 #
/#													 #
/#####################################################

//load in the chat 	######INSERT CHAT NAME HERE###############
chat:1_read0 `$":","WhatsApp Chat with Curlew S%27 Men 2017-18.txt" 
/#############################################################

//###Parse the file###
//handling newlines in messages - joining them up
msgStart:{all "/"~/:x[2 5]} each chat
newlines : not msgStart
wrapMessages:-1+a where 1<>deltas a:where not {all "/"~/:x[2 5]} each chat
longMsgs:(where 1<>deltas a) cut a
joinedLongMsgs:" " sv/: chat wrapMessages,'longMsgs
{@[`chat;x;:;y]} ./: wrapMessages,'enlist each joinedLongMsgs
chat:chat (til count chat) except raze longMsgs

/parse timestamps
time:trim each last each tSplit:"," vs/: first each split:"-" vs/: chat
date:"D"$ "." sv/: reverse each "/" vs/: first each tSplit

/handle 12hr clock and
twelves:"12"~/:time[;0 1]
pms:"pm"~/:-2#/:time
time:@["T"$first each " " vs/: time;where pms and not twelves;+;12*60*60*1000]

/get the person and message
person:`$1_/:first each ":" vs/: split[;1]
message:1_/:raze each 1_/:":" vs/: raze each 1_/:split

/create table
chatTable:([]date:date;time:time;person:person;message:message)

/handle whatsapp internal messages
chatTable:select from chatTable where not person like "*created group*",not person like "*changed the subject*",not person like "*changed this group's icon*",not person=`$"You were added",not person like "* added *",not person like "* removed *",not person like "* left"


/###################
/###Data analysis###
/###################
/sent message percentages
msgRatio:select percentage:100*(count i)%count chatTable by person from chatTable

/daily volume of messages - plot for time series graph
dailyVol:select vol:count i by date from chatTable

/Average message volume through the day - plot for daily volume profiles
dailyAvgMsgVol:select vol:count i by 60 xbar time.minute from chatTable
smoothDaily:select minute,20 mavg vol from ([]minute:00:01*til 60*24) lj select vol:count i by 5 xbar time.minute from chatTable

/Average message length per person
avgMsgLength:select length:avg count each message by person from chatTable

/max message length per person
maxMsgLength:select length:max count each message by person from chatTable

/adding in day of week
dayVol:select percentage:100*(count i)%count chatTable by day from update day:`Saturday`Sunday`Monday`Tuesday`Wednesday`Thursday`Friday date mod 7 from chatTable
dayVol:1!(0!dayVol) 1 5 6 4 0 2 3



//#### Print out key stats
show "Percentage of messages sent per person"
show msgRatio






