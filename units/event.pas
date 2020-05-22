{$B+,D-,I-,L-,N-,P-,Q-,R+,S-,T-,V-,X+,Z-}

unit Event;

(* AUTHOR  : P Slegg
   DATE    : 16th May 2020 Version 0
   PURPOSE : TEvent object for iCal Events.
*)

interface
  uses
    Objects,
    Logger;


type
  PEvent = ^TEvent;
  TEvent = object(TObject)
    created     : String;
    summary     : String;
    description : String;
    dtStart     : String;
    dtEnd       : String;
    alarm       : Boolean;

    constructor init;
    destructor  done; virtual;

    Function GetEvent (VAR calFile : Text)
            : Boolean;

  end;


implementation

  constructor TEvent.init;
  begin
    created     := '';
    summary     := '';
    description := '';
    dtstart     := '';
    dtend       := '';
  end;

  destructor TEvent.done;
  begin

  end;


  Function TEvent.GetEvent (VAR calFile : Text)
          : Boolean;

  (*
    Purpose : Get one iCS event.
   *)

  var
    logger       : PLogger;

    checkEnd,
    convStr      : String;

    currentLn    : String;
    currentCount : Integer;

    endEvent     : Boolean;

  begin
    new(logger);
    logger^.init;

    logger^.level := INFO;

    checkEnd     := 'END:VEVENT';
    endEvent     := FALSE;
    alarm        := FALSE;

    while (NOT eof (calFile) 
           AND NOT endEvent )
    do
    begin

      readln ( calFile, currentLn );
      logger^.log (DEBUG, currentLn);

      (* Look for End Event *)
      if ( pos(checkEnd, currentLn) = 1 )
      then
      begin

        endEvent := TRUE;

      end
      else
      begin
        if ( pos('CREATED:', currentLn) = 1 )
        then
          created := COPY (currentLn, 9, length(currentLn));

        if ( pos('DTSTART:', currentLn) = 1 )
        then
          dtStart := COPY (currentLn, 9, length(currentLn));

        if ( pos('DTEND:', currentLn) = 1 )
        then
          dtEnd   := COPY (currentLn, 7, length(currentLn));

        if ( pos('SUMMARY:', currentLn) = 1 )
           and (NOT alarm)
        then
          summary := COPY (currentLn, 9, length(currentLn));

        if ( pos('DESCRIPTION:', currentLn) = 1 )
           and (NOT alarm)
        then
          description := COPY (currentLn, 13, length(currentLn));

        if (pos('BEGIN:VALARM', currentLn) = 1 )
        then
          alarm := TRUE;

        if (pos('END:VALARM', currentLn) = 1 )
        then
          alarm := FALSE;

      end;  (* if *)

    end;  (* while *)

    Dispose(logger, Done);

    GetEvent := TRUE;

  end;

end.