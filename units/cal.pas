{$B+,D-,I-,L-,N-,P-,Q-,R-,S-,T-,V-,X+,Z-}

unit Cal;

(* AUTHOR  : P SLEGG
   DATE    : 13th April 2020 Version 1
   PURPOSE : TText object for long strings of 1024 char
*)

interface
  uses
    Objects,
    Event;


type
  PCal = ^TCal;
  TCal = object(TObject)
    version : String;
    event   : PEvent;

    constructor init;
    destructor  done; virtual;

  end;

implementation

  constructor TCal.init;
  begin
    version := '2.0';
    new(event);
    event^.init;
  end;

  destructor TCal.done;
  begin
    Dispose(event, Done);
  end;


end.