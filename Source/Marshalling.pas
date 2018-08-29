(*   _                     _
 *  | |__  _ __ ___   ___ | | __
 *  | '_ \| '__/ _ \ / _ \| |/ /
 *  | |_) | | | (_) | (_) |   <
 *  |_.__/|_|  \___/ \___/|_|\_\
 *
 *  –– an ideal Pascal microframework to develop cross-platform HTTP servers.
 *
 * Copyright (c) 2012-2018 Silvio Clecio <silvioprog@gmail.com>
 *
 * This file is part of Brook library.
 *
 * Brook framework is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Brook framework is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with Brook framework.  If not, see <http://www.gnu.org/licenses/>.
 *)

{ Useful types for marshalling arguments. }

unit Marshalling;

{$IFDEF FPC}
 {$MODE DELPHI}
 {$IFDEF VER3_0}
  {$PUSH}{$MACRO ON}
  {$DEFINE MarshaledAString := PAnsiChar}
  {$POP}
 {$ENDIF}
{$ENDIF}

interface

uses
  SysUtils;

type

  { TMarshal* }

{$IFDEF FPC}
  TMarshal = record
{$ELSE}
  TMarshalHelper = class helper for TMarshal
{$ENDIF}
  public
    class function ToBytes(const S: MarshaledAString;
      L: NativeUInt): TBytes; static; inline;
    class function ToString(const S: MarshaledAString;
      L: NativeUInt): string; overload; static; inline;
    class function ToString(
      const S: MarshaledAString): string; overload; static; inline;
  end;

  { TMarshaller* }

{$IFDEF FPC}
  TMarshaller = record
{$ELSE}
  TMarshallerHelper = record helper for TMarshaller
{$ENDIF}
  public
    function ToCString(const S: string): MarshaledAString; inline;
    function ToCNullable(const S: string): MarshaledAString; inline;
  end;

implementation

{ TMarshal* }

class function {$IFDEF FPC}TMarshal{$ELSE}TMarshalHelper{$ENDIF}.ToBytes(
  const S: MarshaledAString; L: NativeUInt): TBytes;
begin
  if (not Assigned(S)) or (L = 0) then
    Exit(nil);
  SetLength(Result, L);
  System.Move(S^, Result[0], L);
end;

class function {$IFDEF FPC}TMarshal{$ELSE}TMarshalHelper{$ENDIF}.ToString(
  const S: MarshaledAString; L: NativeUInt): string;
begin
  if (not Assigned(S)) or (L = 0) then
    Exit('');
{$IFDEF FPC}
  SetString(Result, S, L);
  SetCodePage(RawByteString(Result), CP_UTF8, False);
{$ELSE}
  Result := TMarshal.ReadStringAsUtf8(TPtrWrapper.Create(S), L);
{$ENDIF}
end;

class function {$IFDEF FPC}TMarshal{$ELSE}TMarshalHelper{$ENDIF}.ToString(
  const S: MarshaledAString): string;
begin
  Result := ToString(S, Length(S));
end;

{ TMarshaller* }

function {$IFDEF FPC}TMarshaller{$ELSE}TMarshallerHelper{$ENDIF}.ToCString(
  const S: string): MarshaledAString;
begin
  Result :=
{$IFDEF FPC}
    MarshaledAString(S)
{$ELSE}
    AsAnsi(S, CP_UTF8).ToPointer
{$ENDIF};
end;

function {$IFDEF FPC}TMarshaller{$ELSE}TMarshallerHelper{$ENDIF}.ToCNullable(
  const S: string): MarshaledAString;
begin
  if S.IsEmpty then
    Exit(nil);
  Result := ToCString(S);
end;

end.
