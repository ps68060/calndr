unit datesubs;

interface
  uses StrSubs;

  function PARSE_DATE (DateLine : string)
          : string;

implementation

function parse_Date (dateLine : string)
        : string;
const
  Months : array [1..12] OF string = 
           ('Jan','Feb','Mar','Apr','May','Jun',
            'Jul','Aug','Sep','Oct','Nov','Dec');

VAR
  i,
  SpacePos : integer;

  DD_Str,
  MM_Str,
  YY_Str,
  TT_Str,
  Month : string;

BEGIN
  (* Possible date formats:
     Date: 23 Oct 2002 16:29:15 +0100
     Date: Wed, 09 Aug 2000 18:04:57 +0100
     Date: Wed, 1 Nov 2000 16:54:29
     Date: Tue, 5 Dec 2000  19:24:26 +0200 (EET)
     Date: Mon, 11 Dec 2000 12:14:01 +0000

     Date=23 Oct 2002 16:29:15 +0100 Month=23 Year=Oct Time=2002 
   *)

  (* DateLine := COPY (DateLine, 12, LENGTH(DateLine) - 11);  (* chop from second space to end *)

  Dateline := copy (Dateline, 7, length(DateLine) );  (*   remove 'Date: '  *)

  (* Remove the day name, if there is one *)
  if ( pos(',', DateLine) > 0 )
  then
  begin
    DateLine := copy (DateLine, 6, length(DateLine) );
  end;

  (*writeln (DateLine);*)

  DD_Str := GET_TOKEN (DateLine);
  MM_Str := GET_TOKEN (DateLine);
  YY_Str := GET_TOKEN (DateLine);
  TT_Str := GET_TOKEN (DateLine);

  if (Length(DD_Str) < 2)
  then
    DD_Str := '0' + DD_Str;

  (*writeln ('Date=', DD_Str, ' Month=', MM_Str, ' Year=', YY_Str, ' Time=', TT_Str);*)

  i := 0;
  REPEAT
    INC(I);
  UNTIL (i = 12) OR (Months[i] = MM_Str);
  STR (I, Month);

  IF (LENGTH(Month) < 2)
  THEN
    Month := '0' + Month;

  (*WRITELN ('Date=', DD_Str, ' Month=', Month, ' Year=', YY_Str, ' Time=',TT_Str); *)
  parse_Date := YY_Str + Month + DD_Str + TT_Str;

END;

end.