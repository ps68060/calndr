{$B+,D-,G-,I-,L-,N-,P-,Q-,R-,S-,T-,V-,X+,Z-}

unit StrArr;

(* AUTHOR  : P SLEGG
   DATE    : 19th April 2020 Version 1
   PURPOSE : StrArr object for multiple string 255 char
*)

interface
  uses
    Objects;


type
  PStrArr = ^TStrArr;
  TStrArr = object(TObject)
    size : integer;
    strs : array [0..3] of string;

    constructor init;
    destructor done; virtual;

    procedure WriteLnStrArr(VAR textFile : Text);
  end;

implementation

  constructor  TStrArr.init;
  begin
    size := 0;

    strs[0] := '';
    strs[1] := '';
    strs[2] := '';
    strs[3] := '';
  end;

  destructor  TStrArr.done;
  begin

  end;


procedure TStrArr.WriteLnStrArr(VAR textFile : Text);

(*
  Purpose: Write each of the separated lines to the file.
 *)

begin
  if (length(strs[0]) > 0 )
  then
    write(textFile, strs[0]);

  if (length(strs[1]) > 0 )
  then
  begin
    writeln(textFile);
    writeln(textFile, strs[1]);
  end;

  if (length(strs[2]) > 0 )
  then
  begin
    writeln(textFile);
    writeln(textFile, strs[2]);
  end;

  if (length(strs[3]) > 0 )
  then
  begin
    writeln(textFile);
    writeln(textFile, strs[3]);
  end;
end;

  
end.