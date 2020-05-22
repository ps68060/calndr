{$B+,D-,I-,L-,N-,P-,Q-,R-,S-,T-,V-,X+,Z-}

unit Cal;

(* AUTHOR  : P SLEGG
   DATE    : 17th May 2020 Version 1
   PURPOSE : TCal object for ICS file.
*)

interface
  uses
    Objects,
    Event,
    Logger;

const
  maxEvents = 999;

type
  PCal = ^TCal;
  TCal = object(TObject)
    version   : String;
    eventList : array [0..maxEvents] of PEvent;
    entries   : Integer;

    constructor init;
    destructor  done; virtual;

    Procedure DivideIcs (const calName : String);

  end;

implementation

  constructor TCal.init;
  var
    i : Integer;
  begin
    version := '2.0';
    entries := 0;
  end;


  destructor TCal.done;
  var
    i : Integer;
  begin
    for i := 0 to entries
    do
    begin
      Dispose(eventList[i], Done);
    end;
  end;


  Procedure TCal.DivideIcs (const calName : String);

  (*
    Purpose : Read an ICS file and get all the Events
              into EventsList.
              Return the number of events.
   *)

  var
    logger   : PLogger;
    calFile  : Text;

    checkStart  : String;
    currentLn   : String;

    i           : Integer;

  begin
    new(logger);
    logger^.init;
    logger^.level := INFO;

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
        new (eventList[entries]);
        eventList[entries]^.init;
      
        eventList[entries]^.getEvent(calFile);

        inc (entries);
      end;

    end;

    dec (entries);

    writeln ('INFO: ', entries +1, ' Entries read.');
    writeln;

    Dispose (logger, Done);
  end;

end.