unit BrookHTTPResponse;

{$I Brook.inc}

interface

uses
  RTLConsts,
  SysConst,
  SysUtils,
  Classes,
  Platform,
  Marshalling,
  libsagui,
  BrookHandledClasses,
  BrookStringMap,
  BrookHTTPExtra;

resourcestring
  SBrookInvalidHTTPStatus = 'Invalid status code: %d.';

type
  TBrookHTTPResponse = class(TBrookHandledPersistent)
  private
    FHeaders: TBrookStringMap;
    FHandle: Psg_httpres;
  protected
    class function DoStreamRead(Acls: Pcvoid; Aoffset: cuint64_t; Abuf: Pcchar;
      Asize: csize_t): cssize_t; cdecl; static;
    class procedure DoStreamFree(Acls: Pcvoid); cdecl; static;
    class procedure CheckStatus(AStatus: Word); static; inline;
    class procedure CheckStream(AStream: TStream); static; inline;
    function CreateHeaders(AHandle: Pointer): TBrookStringMap; virtual;
    function GetHandle: Pointer; override;
  public
    constructor Create(AHandle: Pointer); virtual;
    destructor Destroy; override;
    procedure SetCookie(const AName, AValue: string); virtual;
    procedure Send(const AValue, AContentType: string;
      AStatus: Word); overload; virtual;
    procedure Send(const AFmt: string; const AArgs: array of const;
      const AContentType: string; AStatus: Word); overload; virtual;
    procedure Send(const ABytes: TBytes; ASize: NativeUInt;
      const AContentType: string; AStatus: Word); overload; virtual;
    procedure SendBinary(ABuffer: Pointer; ASize: NativeUInt;
      const AContentType: string; AStatus: Word); virtual;
    procedure SendFile(ABlockSize: NativeUInt; AMaxSize: UInt64;
      const AFileName: TFileName; ARendered: Boolean;
      AStatus: Word); overload; virtual;
    procedure SendFile(const AFileName: TFileName); overload; virtual;
    procedure SendStream(AStream: TStream; AStatus: Word);
    property Headers: TBrookStringMap read FHeaders;
  end;

implementation

constructor TBrookHTTPResponse.Create(AHandle: Pointer);
begin
  inherited Create;
  FHandle := AHandle;
  FHeaders := CreateHeaders(sg_httpres_headers(FHandle));
end;

destructor TBrookHTTPResponse.Destroy;
begin
  FHeaders.Free;
  inherited Destroy;
end;

function TBrookHTTPResponse.GetHandle: Pointer;
begin
  Result := FHandle;
end;

class procedure TBrookHTTPResponse.CheckStatus(AStatus: Word);
begin
  if (AStatus < 100) or (AStatus > 599) then
    raise EArgumentException.CreateResFmt(@SBrookInvalidHTTPStatus, [AStatus]);
end;

class procedure TBrookHTTPResponse.CheckStream(AStream: TStream);
begin
  if not Assigned(AStream) then
    raise EArgumentNilException.CreateResFmt(@SParamIsNil, ['AStream']);
end;

function TBrookHTTPResponse.CreateHeaders(AHandle: Pointer): TBrookStringMap;
begin
  Result := TBrookStringMap.Create(AHandle);
  Result.ClearOnDestroy := False;
end;

{$IFDEF FPC}
 {$PUSH}{$WARN 5024 OFF}
{$ENDIF}
class function TBrookHTTPResponse.DoStreamRead(Acls: Pcvoid;
  Aoffset: cuint64_t; Abuf: Pcchar; Asize: csize_t): cssize_t;
begin
  Result := TStream(Acls).Read(Abuf^, Asize);
  if Result = 0 then
    Exit(sg_httpread_end(False));
  if Result = -1 then
    Result := sg_httpread_end(True);
end;
{$IFDEF FPC}
 {$POP}
{$ENDIF}

class procedure TBrookHTTPResponse.DoStreamFree(Acls: Pcvoid);
begin
  TStream(Acls).Free;
end;

procedure TBrookHTTPResponse.SetCookie(const AName, AValue: string);
var
  M: TMarshaller;
begin
  SgCheckLibrary;
  SgCheckLastError(sg_httpres_set_cookie(FHandle, M.ToCString(AName),
    M.ToCString(AValue)));
end;

procedure TBrookHTTPResponse.Send(const AValue, AContentType: string;
  AStatus: Word);
var
  M: TMarshaller;
begin
  SgCheckLastError(sg_httpres_sendbinary(FHandle, M.ToCString(AValue),
    Length(AValue), M.ToCString(AContentType), AStatus));
end;

procedure TBrookHTTPResponse.Send(const AFmt: string;
  const AArgs: array of const; const AContentType: string; AStatus: Word);
begin
  Send(Format(AFmt, AArgs), AContentType, AStatus);
end;

procedure TBrookHTTPResponse.Send(const ABytes: TBytes; ASize: NativeUInt;
  const AContentType: string; AStatus: Word);
begin
  SendBinary(@ABytes[0], ASize, AContentType, AStatus);
end;

procedure TBrookHTTPResponse.SendBinary(ABuffer: Pointer; ASize: NativeUInt;
  const AContentType: string; AStatus: Word);
var
  M: TMarshaller;
begin
  CheckStatus(AStatus);
  SgCheckLibrary;
  SgCheckLastError(sg_httpres_sendbinary(FHandle, ABuffer, ASize,
    M.ToCString(AContentType), AStatus));
end;

procedure TBrookHTTPResponse.SendFile(ABlockSize: NativeUInt; AMaxSize: UInt64;
  const AFileName: TFileName; ARendered: Boolean; AStatus: Word);
var
  M: TMarshaller;
  R: cint;
begin
  CheckStatus(AStatus);
  SgCheckLibrary;
  R := sg_httpres_sendfile(FHandle, ABlockSize, AMaxSize,
    M.ToCString(AFileName), ARendered, AStatus);
  if R = ENOENT then
    raise EFileNotFoundException.CreateRes(@SFileNotFound);
  SgCheckLastError(R);
end;

procedure TBrookHTTPResponse.SendFile(const AFileName: TFileName);
begin
  SendFile(BROOK_BLOCK_SIZE, 0, AFileName, False, 200);
end;

procedure TBrookHTTPResponse.SendStream(AStream: TStream; AStatus: Word);
begin
  CheckStream(AStream);
  CheckStatus(AStatus);
  SgCheckLibrary;
  SgCheckLastError(sg_httpres_sendstream(FHandle, AStream.Size, BROOK_BLOCK_SIZE,
{$IFNDEF VER3_0}@{$ENDIF}DoStreamRead, AStream,
{$IFNDEF VER3_0}@{$ENDIF}DoStreamFree, AStatus));
end;

end.
