{$B+,D-,G-,I-,L-,P-,Q-,R+,S-,T-,V-,X+,Z-}
{$M 32768}

PROGRAM Calndr (input,output);

uses
  Dos,
  StrSubs,
  OProcs,
  Cal,
  Event,
  DateTime,
  Logger;

(* AUTHOR  : P Slegg
   DATE    : 17th May 2020 Version 0
   PURPOSE : To extract iCal files
*)

{$I D:\DEVELOP\PASCAL\strsubs.pas}

CONST
  version = '0.01ž';
  dated   = '17.05.2020';

TYPE
  eventIndexT = RECORD
                 eventNumber : Integer;
                 dateTime    : String[100];
               END;

VAR

  logger      : PLogger;

  inFileName,
  directory,
  calName     : String;

  eventIndex   : array [1..2000] of EventIndexT;

  year,
  month,
  day,
  dayOfWeek : Word;

  myDate    : PDateTime;
  dtStr     : String;

  eventList : array [0..999] of PEvent;
  dateList  : array [0..999] of PDateTime;
  entries   : Integer;
  i         : Integer;

  dd, hh, mi, ss : Integer;
  future         : Boolean;

FUNCTION Get_File_Name (msg : String)
        : String;
VAR
  fileName : String;

BEGIN
  fileName := '';

  while (fileName = '') do
  begin
    write (msg, ' : ');
    while NOT EOLN do
    begin
      read (INPUT, fileName);            (* get the file name *)
    end;  (* while *)

    if fileName = '' then readln;
  end;  (* while *)

  Get_File_Name := fileName;
END;


PROCEDURE Get_File_Names (VAR folderName : String);

begin

  folderName := Get_File_Name('Enter Folder for ICS file(s)');
  writeln;

end;


FUNCTION MakeIndex (entry : integer)
        : String;
var
  convStr : string;

begin
  (* Create a string for the filename of each mail message *)
  (* eg. mailfile001.txt *)
  Str(entry:3, convStr);
  if ( convStr[1] = ' ' )
  then
    convStr[1] := '0';
  if ( convStr[2] = ' ' )
  then
    convStr[2] := '0';

  MakeIndex := convStr;
end;


Procedure DivideIcs (const calName : String;
                     var   count   : Integer);

(*
  Purpose : Read an ICS file and get all the Events
            into EventsList.
            Return the number of events.
 *)

var

  calFile  : Text;

  checkStart  : String;
  currentLn   : String;

  myStart     : PDateTime;
  i           : Integer;

begin

  checkStart := 'BEGIN:VEVENT';

  (* Open the calendar file for reading *)
  assign (calFile, calName);
  reset  (calFile);

  writeln ('INFO: Reading from ', calName);

  while ( NOT eof(calFile) ) 
  do
  begin

    readln ( calFile, currentLn );
    logger^.log (DEBUG, currentLn);

    if ( pos (checkStart, currentLn) = 1 )
    then
    begin
      new (eventList[count]);
      eventList[count]^.init;
      
      eventList[count]^.getEvent(calFile);

      inc (count);
    end;

  end;

  dec (count);

  writeln ('INFO: ', count +1, ' Entries read.');
  writeln;

end;


Procedure loadICS (directory : String);
(*
  Purpose : Load all the *.ics files from the <directory>.
 *)

var
  attr    : Word;
  fileRec : SearchRec;
  calName : String;

begin

  findFirst(directory + '/*.ics', attr, fileRec);

  while DosError = 0
  do
  begin
    calName := directory + '/' +  fileRec.name;

    DivideIcs (calName, entries);
    inc (entries);

    FindNext( fileRec );
  end;
  
  dec (entries);
end;


procedure DisplayCalendar(myDate : PDateTime);
(*
  Purpose : Write out a formatted calendar for the month <myDate>.
 *)

var
  i,
  j,
  daysInMon : Integer;

begin
  writeln;

  daysInMon := daysMon[myDate^.mm];

  if (myDate^.mm = 2) and (isLeapDay(myDate^.yyyy))
  then
    daysInMon := 29;

  writeln(myDate^.yyyy, '    ', mon1[myDate^.mm]);

  for i := 0 to 6
  do
  begin
    write(day2[i], ' ');
  end;
  writeln;

  i := 0;
  while (i < myDate^.day)
  do
  begin
    write('    ');
    inc (i);
  end;

  j := 1;
  while (j <= daysInMon)
  do
  begin

    while (i <= 6) and (j <= daysInMon)
    do
    begin
      write(j:2, '  ');
      inc(i);
      inc(j);
    end;

    i := 0;
    writeln;
  end;

end;


Procedure Events2DateTime;
(*
  Purpose : Create a DateTime object for each Event from the file.
 *)

var
  i : Integer;

begin

  for i := 0 to entries do
  begin
    new (dateList[i]);
    dateList[i]^.init;
    dateList[i]^.dtStr2Obj(eventList[i]^.dtStart);
  end;

end;


Procedure DisplayEvents (rangePast, rangeFuture : Integer);
(*
  Purpose : List all the DateTime/Events that occur either side of
            the current date, after <rangePast> and before <rangeFuture>.
 *)

var
  year,
  month,
  day,
  dayOfWeek : Word;

  hour,
  minute,
  second,
  sec100    : Word;

  i : Integer;

begin

  GetDate(year, month, day, dayOfWeek) ;
  GetTime(hour, minute, second, sec100);

  writeln('Current date is ', year, '/', month:2, '/', day:2, ': ', day1[dayOfWeek] );
  writeln('Current time : ', hour, ':', minute, ':', second, '.', sec100);
  writeln;

  dtStr := date2Str(year, month, day);
  dtStr := dtStr + ' ' + time2Str(hour, minute, second);

  new(myDate);
  myDate^.init;
  myDate^.dtStr2Obj(dtStr);
  myDate^.dayOfWeek;

  logger^.logInt(DEBUG, 'calendar ', myDate^.day);
  logger^.logLongInt(DEBUG, 'epoch ', myDate^.epoch);

  for i := 0 to entries do
  begin
    logger^.log (DEBUG, 'Created on  : ' + eventList[i]^.created);
    logger^.log (DEBUG, 'Event start : ' + eventList[i]^.dtStart);

    timeBetween(dateList[i]^.epoch,
                myDate^.epoch,
                dd, hh, mi, ss,
                future);

    if (rangePast = 0) and (rangeFuture = 0)
       or (not future) and (dd < rangePast)
       or (future)     and (dd < rangeFuture)
    then
    begin

    (*
    writeln('Current date : ', myDate^.yyyy,      myDate^.mm:2,      myDate^.dd:2,
            ' ', myDate^.hh24:2,      ':', myDate^.mi:2,      ':', myDate^.ss:2);
    *)
    writeln('Event on     : ',
                 dateList[i]^.yyyy,
                 dateList[i]^.mm:2,
                 dateList[i]^.dd:2,   ' ',
                 dateList[i]^.hh24:2, ':',
                 dateList[i]^.mi:2,   ':',
                 dateList[i]^.ss:2);

    if (future)
    then
    begin
      writeln('Occurs in    : ', dd, ' days ', hh, 'h ', mi, 'm ', ss, 's');
      if (dd = 0)
      then
        writeln('================================', chr(7) );
    end
    else
      writeln('Occurred     : ', dd, ' days ', hh, 'h ', mi, 'm ', ss, 's ago.');

    writeln (eventList[i]^.summary);
    writeln (eventList[i]^.description);
    writeln;
    writeln ('Event end   : ', eventList[i]^.dtEnd);
    writeln;
    end;

  end;  (* for *)

  Dispose (myDate, Done);

  logger^.level := INFO;
end;


(******************************  MAIN PROGRAM  ********************************)

BEGIN

  writeln;
  writeln ('Extract iCal Version ', version, ' ', dated);

  writeln('---------------------------------------');

  new(logger);
  logger^.init;
  logger^.level := INFO;

  (* have the parameters been put on the command line *)

  if paramCount = 1
  then
  begin
    directory   := paramStr(1);
  end
  else
  begin
    Get_File_Names(directory);
  end;  (* if-then-else *)

  calName := directory;

  if (Exist(directory) )
  then
  begin
    entries := 0;
    loadICS (directory);

    Events2DateTime;
    DisplayEvents(30, 50);

    for i := 0 to entries
    do
    begin
      Dispose (dateList[i], Done);
    end;
  end;

  (* Display this month's calendar *)
  GetDate (year, month, day, dayOfWeek) ;
  dtStr := date2Str(year, month, 1);

  new(myDate);
  myDate^.init;
  myDate^.dtStr2Obj(dtStr);
  myDate^.dayOfWeek;

  DisplayCalendar(myDate);
  Dispose(myDate, Done);

  logger^.log (INFO, 'Completed.');

  Dispose (logger, Done);

END.
