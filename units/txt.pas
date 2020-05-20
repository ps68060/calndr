{$B+,D-,I-,L-,N-,P-,Q-,R-,S-,T-,V-,X+,Z-}

unit Txt;

(* AUTHOR  : P SLEGG
   DATE    : 13th April 2020 Version 1
   PURPOSE : TText object for long strings of 1024 char
*)

interface
  uses
    Objects,
    StrArr;


type
  PText = ^TText;
  TText = object(TObject)
    size : Integer;
    txt  : packed array [0..1023] of Char;

    constructor init;
    destructor  done; virtual;

    function TText2String(VAR strArray : PStrArr)
            : Integer;
  end;

implementation

  constructor TText.init;
  begin
    txt[0] := chr(0);
    size   := -1;
  end;

  destructor TText.done;
  begin
    
  end;


  function TText.TText2String(VAR strArray : PStrArr)
          : Integer;

  (*
    Purpose : Convert a 1023 char Text line into an array of Pascal 256 byte Strings
              Return the size of the array < 4
  *)
  VAR
    i, j, k : Integer;
    endloop : Boolean;

  BEGIN

    i := 0;
    j := 1;
    k := 0;

    endloop := FALSE;

    while ((k <= 1023) and (not endloop) ) do
    begin

      (* writeln ('A:  [', i, ']', '   [', j, ']', ' : ', txt[k]); *)

      (* Is the char a null terminator ? *)
      if (txt[k] = chr(0))
      then
      begin
        (* writeln ('Null at ', k );  *)
        endloop := TRUE;
      end
      else
      begin
        strArray^.strs[i][j] := txt[k];

        (* writeln ('B:  [', i, ']', '   [', j, ']', ' : ', txt[k]);  *)
        (* Store string length in byte 0 *)
        strArray^.strs[i][0] := chr(j);
      end;

      inc (j);
      inc (k);

      if ( (k mod 255) = 0 )
      then
      begin
        inc (i);
        j := 1;
      end;

    end;  (* while *)

    (*
    writeln ('array 0 = ', strArray[0]);
    writeln ('array 1 = ', strArray[1]);
    writeln ('array 2 = ', strArray[2]);
    writeln ('array 3 = ', strArray[3]);
    *)

    strArray^.size := i + 1;
    TText2String  := i + 1;
  END;

end.