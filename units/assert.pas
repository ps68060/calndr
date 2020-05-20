{$B+,D-,G-,I-,L-,N-,P-,Q-,R-,S-,T-,V-,X+,Z-}

unit Assert;

(* AUTHOR  : P SLEGG
   DATE    : 14th April 2020 Version 1
   PURPOSE : Assert for Unit Testing
*)

interface

  function assertInt(actual   : Integer;
                     expected : Integer)
          : Boolean;


implementation

  function assertInt(actual   : Integer;
                     expected : Integer)
          : Boolean;
  BEGIN

    assertInt := FALSE;
    if (actual <> expected) then
      writeln('ASSERT FAILED : Expected ', expected, ' but got ', actual, chr(7) )
    else
    begin
      writeln('PASSED with value ', expected);
      assertInt := TRUE;
    end;

  END;

end.