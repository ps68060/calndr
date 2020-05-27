{$B+,D-,G-,I-,L-,P-,Q-,R+,S+,T-,V-,X+,Z-}
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
  version = '0.02ž';
  dated   = '27.05.2020';

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

  cal         : PCal;

  year,
  month,
  day,
  dayOfWeek : Word;

  myDate    : PDateTime;
  dtStr     : String;

  i         : Integer;

  pastStr, futureStr : String;
  past,    future    : Integer;
  code : Integer;

  eventIndex   : array [1..2000] of EventIndexT;


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


procedure DisplayCalendar(calDate : PDateTime);
(*
  Purpose : Write out a formatted calendar for the month <calDate>.
 *)

var
  i,
  j,
  daysInMon : Integer;

begin
  writeln;

  daysInMon := daysMon[calDate^.mm];

  if (calDate^.mm = 2) and (isLeapDay(calDate^.yyyy))
  then
    daysInMon := 29;

  writeln(calDate^.yyyy, '    ', mon1[calDate^.mm]);

  for i := 0 to 6
  do
  begin
    write(day2[i], ' ');
  end;
  writeln;

  i := 0;
  while (i < calDate^.day)
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


Procedure DisplayEvents (rangePast, rangeFuture : Integer);
(*
  Purpose : List all the DateTime/Events that occur either side of
            the current date, after <rangePast> and before <rangeFuture>.
 *)

var
  ddDiff,
  hhDiff,
  miDiff,
  ssDiff    : Integer;

  year,
  month,
  day,
  dayOfWeek : Word;

  hour,
  minute,
  second,
  sec100    : Word;

  future :Boolean;
  i : Integer;

  calDate : PDateTime;

begin

  GetDate(year, month, day, dayOfWeek) ;
  GetTime(hour, minute, second, sec100);

  dtStr := date2Str(year, month, day);
  dtStr := dtStr + ' ' + time2Str(hour, minute, second);

  new(calDate);
  calDate^.init;
  calDate^.dtStr2Obj(dtStr);

  logger^.logInt(DEBUG, 'calendar ', calDate^.day);
  logger^.logLongInt(DEBUG, 'epoch ', calDate^.epoch);

  for i := 0 to cal^.entries do
  begin
    logger^.log (DEBUG, 'Created on  : ' + cal^.eventList[i]^.created);
    logger^.log (DEBUG, 'Event start : ' + cal^.eventList[i]^.dtStart);

    logger^.logLongInt (DEBUG, 'epoch = ', cal^.eventList[i]^.startDate^.epoch);
    timeBetween(cal^.eventList[i]^.startDate^.epoch,
                calDate^.epoch,
                ddDiff, hhDiff, miDiff, ssDiff,
                future);


    (**cal^.eventList[i]^.isMonthEvent(2020, 5); **)

    if (rangePast = 0) and (rangeFuture = 0)
       or (not future) and (ddDiff < rangePast)
       or (future)     and (ddDiff < rangeFuture)
    then
    begin

    (*
    writeln('Current date : ', calDate^.yyyy,      calDate^.mm:2,      calDate^.dd:2,
            ' ', calDate^.hh24:2,      ':', calDate^.mi:2,      ':', calDate^.ss:2);
    *)

    cal^.eventList[i]^.writeEvent;

    if (future)
    then
    begin
      writeln('Occurs in    : ', ddDiff, ' days ', hhDiff, 'h ', miDiff, 'm ', ssDiff, 's');

      if (ddDiff = 0)
      then
        writeln('================================', chr(7) );

    end

    else
      writeln('Occurred     : ', ddDiff, ' days ', hhDiff, 'h ', miDiff, 'm ', ssDiff, 's ago.');

    writeln('--------------------------------' );
    writeln;
    end;

  end;  (* for *)

  Dispose (calDate, Done);

  writeln('Current date : ', year, '.', month:2, '.', day:2, ': ', day1[dayOfWeek] );
  writeln('Current time : ', hour, ':', minute, ':', second, '.', sec100);
  writeln;

  logger^.level := INFO;
end;


procedure Usage;
begin
  writeln ('Usage:' );
  writeln;
  writeln ('./calndr.ttp  <directory>' );
  writeln ('./calndr.ttp  <past number of days> <future number of days>');
  writeln ('./calndr.ttp  <directory> <past number of days> <future number of days>' );
  writeln;
  writeln ('Supply a directory containing one or more .ics files.' );

end;


(******************************  MAIN PROGRAM  ********************************)

BEGIN

  writeln;
  writeln ('GEMiCal Version ', version, ' ', dated);

  writeln('--------------------------------');

  new(logger);
  logger^.init;
  logger^.level := INFO;

  (* have the parameters been put on the command line
    1 = directory
    2 = past   number of days
    3 = future number of days
   *)


  pastStr   := '50';
  futureStr := '50';

  case paramCount of
    0 : usage;
    1 : directory := paramStr(1);
    2 : 
      begin
        Get_File_Names(directory);
        pastStr   := paramStr(1);
        futureStr := paramStr(2);
      end;
    3 : 
      begin
        directory := paramStr(1);
        pastStr   := paramStr(2);
        futureStr := paramStr(3);
      end;
  end;

  calName := directory;

  if (Exist(directory) )
  then
  begin

    new(cal);
    cal^.init;
    cal^.loadICS (directory);

    cal^.sort;

    val(pastStr, past,   code );
    if (code <> 0)
    then
      writeln ('Integer conversion error of past at ', code, ' in ', paramStr(1) );

    val(futureStr, future, code);
    if (code <> 0)
    then
      writeln ('Integer conversion error of future at ', code, ' in ', paramStr(2) );
 
    DisplayEvents(past, future);

    Dispose (cal, Done);
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

  logger^.log (DEBUG, 'Completed.');

  Dispose (logger, Done);

END.
