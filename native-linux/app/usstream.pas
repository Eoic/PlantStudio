unit Usstream;
{Copyright (c) 1997 Paul D. Fernhout and Cynthia F. Kurtz All rights reserved
http://www.gardenwithinsight.com. See the license file for details on redistribution.
=====================================================================================
usstream: String stream. Used by text filer (ufilertx) to parse strings,
usually those associated with points or arrays (because there are delimiters inside
the string in these cases). Also used by 3d object (in uturt3d) to read strings from tdo file.}

interface

type
  KfStringStream = class(TObject)
  public
    source: string;
    remainder: string;
    separator: string;
    constructor createFromString(aString: string);
    procedure onString(aString: string);
    procedure onStringSeparator(aString: string; aSeparator: string);
    procedure spaceSeparator;
    procedure skipSpaces;
    function nextToken: string;
    function nextInteger: longint;
    function nextSingle: single;
    function nextCharacter: char;
    function match(aString: string): boolean;
    procedure skipWhiteSpace;
    function empty: boolean;
  end;

function skipToProfileSection(var fileStream: TextFile; section: string): boolean;

implementation

uses
  SysUtils;

constructor KfStringStream.createFromString(aString: string);
begin
  self.create;
  self.onStringSeparator(aString, ' ');
end;

procedure KfStringStream.onString(aString: string);
begin
  source := aString;
  remainder := aString;
end;

procedure KfStringStream.onStringSeparator(aString: string; aSeparator: string);
begin
  source := aString;
  remainder := aString;
  separator := aSeparator;
end;

procedure KfStringStream.spaceSeparator;
begin
  separator := ' ';
end;

procedure KfStringStream.skipSpaces;
begin
  while (copy(remainder, 1, 1) = ' ') do
    remainder := copy(remainder, 2, 255);
end;

function KfStringStream.nextToken: string;
var
  location: longint;
begin
  self.skipSpaces;
  location := pos(separator, remainder);
  if location <> 0 then
  begin
    result := copy(remainder, 1, location - 1);
    remainder := copy(remainder, location + length(separator), 255);
  end
  else
  begin
    result := remainder;
    remainder := '';
  end;
end;

function KfStringStream.nextInteger: longint;
var
  token: string;
begin
  token := self.nextToken;
  result := StrToIntDef(token, 0);
end;

function KfStringStream.nextSingle: single;
var
  token: string;
begin
  result := 0.0;
  token := self.nextToken;
  try
    result := strToFloat(token);
  except
    on EConvertError do
      result := 0.0;
  end;
end;

function KfStringStream.nextCharacter: char;
begin
  result := remainder[1];
  remainder := copy(remainder, 2, 255);
end;

function skipToProfileSection(var fileStream: TextFile; section: string): boolean;
var
  inputLine: string;
  stream: KfStringStream;
begin
  stream := KfStringStream.create;
  stream.separator := ']';
  result := false;
  while not eof(fileStream) do
  begin
    readln(fileStream, inputLine);
    stream.onString(inputLine);
    if stream.nextCharacter() = '[' then
      if uppercase(trim(stream.nextToken)) = uppercase(trim(section)) then
      begin
        result := true;
        break;
      end;
  end;
  stream.free;
end;

function KfStringStream.match(aString: string): boolean;
begin
  self.skipWhiteSpace;
  result := (copy(uppercase(remainder), 1, length(aString)) = uppercase(aString));
  if result then
    remainder := copy(remainder, length(aString) + 1, 255);
end;

procedure KfStringStream.skipWhiteSpace;
begin
  while (copy(remainder, 1, 1) = ' ') or (copy(remainder, 1, 1) = chr(9)) do
    remainder := copy(remainder, 2, 255);
end;

function KfStringStream.empty: boolean;
begin
  result := (remainder = '');
end;

end.
