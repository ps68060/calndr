{$B+,D-,I-,L-,N-,P-,Q-,R-,S-,T-,V-,X+,Z-}

unit TxtFl;

(* AUTHOR  : P SLEGG
   DATE    :  4th April 2020 Version 1
   PURPOSE : Text File handler
*)

interface
  uses
    Objects,
    Txt;

type

  PTextFile = ^TTextFile;
  TTextFile = object(TObject)
    filename : String;
    textfile : File of Char;
    txtEof   : boolean;

    constructor init(inFilename : String);
    destructor  done; virtual;

    procedure openFile(writeFile  : Boolean);

    function READ_TXT (retText : PText)
            : Integer;

    function WRITE_TXT (inpText : TText)
            : Integer;
  end;


implementation

  constructor TTextFile.init(inFilename : String);
  begin
    filename := inFilename;
    writeln ('DEBUG' + 'filename set to ', filename);
  end;

  destructor TTextFile.done;
  begin
    close(textfile);
  end;


  procedure TTextFile.openFile(writeFile  : Boolean);
  begin

    writeln ('DEBUG' + 'Open file ' + filename);
    assign (textfile, filename);

    if (writeFile)
    then
      rewrite (textfile)
    else
      reset  (textfile);                             (* open the existing file for reading *)

    writeln ('DEBUG' + 'Opened file ' + filename);
  end;



  function TTextFile.READ_TXT (retText : PText)
         : integer;
  (*
    Read one line of text from from inFile into retText.
    If CR is detected then the line is null terminated
    without the CR and any LF after that.
    Return the length of the line.
  *)

  VAR
    endLine    : Boolean;
    lineLen    : Integer;

  BEGIN

    txtEof     := FALSE;

    lineLen := 0;

    (*writeln('reading ', filename);*)
    READ ( textfile, retText^.txt[lineLen] );

    endLine := FALSE;

    while (NOT (EOF(textfile)
                or endLine
                or (ord(retText^.txt[lineLen]) = 0)
               )
          )
    do
    begin

      (* Check for LF line termination *)
      if (retText^.txt[lineLen] = chr(10))
      then
      begin

        retText^.txt[lineLen] := chr(0);
        dec (lineLen);
        endLine := TRUE;

        (* Check for CR line termination *)
        if (    (lineLen >= 0)
            and (retText^.txt[lineLen] = chr(13)) )
        then
        begin

          retText^.txt[lineLen] := chr(0);
          dec (lineLen);

        end;

      end;

      if (NOT endLine)
      then
      begin
        inc (lineLen);
        read (textfile, retText^.txt[lineLen]);
      end;

    end;  (* while *)

    if ( EOF(textFile) )
    then
      txtEof     := TRUE;

    if ( EOF(textFile)
        or (ord(retText^.txt[lineLen]) = 0 )
       )
    then
    begin
      lineLen := -1;
      (*writeln ('EOF');*)
    end
    else
    begin
      inc (lineLen);
    end;

    READ_TXT := lineLen;
  END;


  function TTextFile.WRITE_TXT (inpText : TText)
           : Integer; 
  (*
    Purpose : Write one line of text from inpText to the file outFile.
              Return the length of the line.
  *)

  VAR
    lineLen    : integer;

  BEGIN
    lineLen := 0;
    WHILE ( inpText.txt[lineLen] <> chr(0)) DO
    begin
      WRITE (textfile, inpText.txt[lineLen] );
      lineLen := lineLen + 1;
    end;

    WRITE_TXT := lineLen;
  END;

end.