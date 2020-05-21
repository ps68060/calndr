{$B+,D-,I-,L-,N-,P-,Q-,R+,S-,T-,V-,X+,Z-}

unit Event;

(* AUTHOR  : P Slegg
   DATE    : 16th May 2020 Version 0
   PURPOSE : TEvent object for iCal Events
*)

interface
  uses
    Objects;


type
  PEvent = ^TEvent;
  TEvent = object(TObject)
    created     : String;
    summary     : String;
    description : String;
    dtStart     : String;
    dtEnd       : String;

    constructor init;
    destructor  done; virtual;

  end;

implementation

  constructor TEvent.init;
  begin
    created     := '';
    description := '';
    dtstart     := '';
    dtend       := '';
  end;

  destructor TEvent.done;
  begin

  end;


end.