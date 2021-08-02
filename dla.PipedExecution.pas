unit dla.PipedExecution;

interface

uses
  (* Delphi *)
  System.SysUtils, System.Classes, System.Types, WinApi.Windows, VCL.ExtCtrls;

type
  TPipedExecution = class(TThread)
  type
    TOnNewText = procedure(Sender: TObject; const Text: string) of object;
    TOnExit = procedure(Sender: TObject; ExitCode: Cardinal) of object;
  private
    FOnExit: TOnExit;
    FOnInput: TOnNewText;
    FOnError: TOnNewText;

    FStdInReadPipe: THandle;
    FStdInWritePipe: THandle;
    FStdOutReadPipe: THandle;
    FStdOutWritePipe: THandle;
    FStdErrReadPipe: THandle;
    FStdErrWritePipe: THandle;
    FProcessInfo: TProcessInformation;
  public
    constructor Create(const Executable: String;
      const Parameters: String = ''; const WorkDir: string = '');
    destructor Destroy; override;

    procedure Execute; override;

    procedure WriteText(Text: AnsiString); overload;
    procedure WriteText(Text: Utf8String); overload;

    property OnInput: TOnNewText read FOnInput write FOnInput;
    property OnError: TOnNewText read FOnError write FOnError;
    property OnExit: TOnExit read FOnExit write FOnExit;
  end;

implementation

{ TPipedExecution }

constructor TPipedExecution.Create(const Executable: String;
  const Parameters: String = ''; const WorkDir: string = '');
var
  SecurityAttributes: TSecurityAttributes;
  SecurityDescriptor: TSecurityDescriptor;
  StartUpInfo: TStartUpInfo;
  CommandLine: string;
  UseWorkDir: string;
begin
  inherited Create(True);

  // initialize events
  FOnInput := OnInput;
  FOnExit := OnExit;

  // setup security
  SecurityAttributes.nLength := SizeOf(TSecurityAttributes);
  SecurityAttributes.bInheritHandle := true;

  // setup security descriptor
  InitializeSecurityDescriptor(@SecurityDescriptor, SECURITY_DESCRIPTOR_REVISION);
  SetSecurityDescriptorDacl(@SecurityDescriptor, true, nil, false);
  SecurityAttributes.lpSecurityDescriptor := @SecurityDescriptor;

  // Create a pipe for the child process's STDOUT.
  if not CreatePipe(FStdOutReadPipe, FStdOutWritePipe, @SecurityAttributes, 1024) then
    raise Exception.Create('Could not create pipe');

  // Ensure the read handle to the pipe for STDOUT is not inherited.
  if not SetHandleInformation(FStdOutReadPipe, HANDLE_FLAG_INHERIT, 0) then
    raise Exception.Create('Could not set handle information');

  // Create a pipe for the child process's STDERR.
  if not CreatePipe(FStdErrReadPipe, FStdErrWritePipe, @SecurityAttributes, 1024) then
    raise Exception.Create('Could not create pipe');

  // Ensure the read handle to the pipe for STDOUT is not inherited.
  if not SetHandleInformation(FStdErrReadPipe, HANDLE_FLAG_INHERIT, 0) then
    raise Exception.Create('Could not set handle information');

  // Create a pipe for the child process's STDIN.
  if not CreatePipe(FStdInReadPipe, FStdInWritePipe, @SecurityAttributes, 1024) then
    raise Exception.Create('Could not create pipe');

  // Ensure the write handle to the pipe for STDIN is not inherited.
  if not SetHandleInformation(FStdInWritePipe, HANDLE_FLAG_INHERIT, 0) then
    raise Exception.Create('Could not set handle information');

  FillChar(StartUpInfo, Sizeof(TStartupInfo), 0);
  GetStartupInfo(StartUpInfo);
  StartUpInfo.cb := SizeOf(TStartupInfo);
  StartUpInfo.hStdError := FStdErrWritePipe;
  StartUpInfo.hStdOutput := FStdOutWritePipe;
  StartUpInfo.hStdInput := FStdInReadPipe;
  StartUpInfo.dwFlags := STARTF_USESTDHANDLES + STARTF_USESHOWWINDOW;
  StartUpInfo.wShowWindow := SW_HIDE;

  if WorkDir = '' then
    GetDir(0, UseWorkDir)
  else
    UseWorkDir := WorkDir;

  CommandLine := Executable + ' ' + Parameters;

  // create process
  if not CreateProcess(PChar(Executable), PChar(CommandLine), nil, nil, True,
       CREATE_NEW_CONSOLE + NORMAL_PRIORITY_CLASS, nil, PChar(UseWorkDir),
       StartUpInfo, FProcessInfo) then
    RaiseLastOSError;
end;

destructor TPipedExecution.Destroy;
var
  ExitCode: Cardinal;
begin
  // check exit code
  ExitCode := 0;
  if WaitForSingleObject(FProcessInfo.hProcess, 10) = WAIT_TIMEOUT then
    TerminateProcess(FProcessInfo.hProcess, ExitCode)
  else
    GetExitCodeProcess(FProcessInfo.hProcess, ExitCode);

  OutputDebugString(PChar('Exit code: ' + IntToStr(ExitCode)));

  // fire 'OnExit' event
  if Assigned(FOnExit) then
    FOnExit(Self, ExitCode);

  // free timer and buffers and close handles
  CloseHandle(FProcessInfo.hProcess);
  CloseHandle(FProcessInfo.hThread);
  CloseHandle(FStdInReadPipe);
  CloseHandle(FStdInWritePipe);
  CloseHandle(FStdOutReadPipe);
  CloseHandle(FStdOutWritePipe);
  CloseHandle(FStdErrReadPipe);
  CloseHandle(FStdErrWritePipe);

  inherited;
end;

procedure TPipedExecution.WriteText(Text: AnsiString);
var
  BytesWritten: Cardinal;
begin
  WriteFile(FStdInWritePipe, Text[1], Length(Text), BytesWritten, nil);
end;

procedure TPipedExecution.WriteText(Text: Utf8String);
var
  BytesWritten: Cardinal;
begin
  WriteFile(FStdInWritePipe, Text[1], Length(Text), BytesWritten, nil);
end;

procedure TPipedExecution.Execute;
var
  ProcessExitCode: Cardinal;
  BytesRead: DWORD;
  TotalBytesAvail: Integer;
  Data: TBytes;

begin
  repeat
    // delay reaction
    Sleep(10);

    GetExitCodeProcess(FProcessInfo.hProcess, ProcessExitCode);

    // read named pipe (STIN)
    if not PeekNamedPipe(FStdOutReadPipe, nil, 0, nil, @TotalBytesAvail, nil) then
      RaiseLastOSError;

    // check if bytes are available for reading
    if (TotalBytesAvail <> 0) then
    begin
      SetLength(Data, TotalBytesAvail);
      ReadFile(FStdOutReadPipe, Data[0], TotalBytesAvail, BytesRead, nil);

      if Assigned(OnInput) and (BytesRead > 0) then
        with TStringStream.Create(Data) do
        try
          OnInput(Self, DataString);
        finally
          Free;
        end;
    end;

    // read named pipe (STERR)
    if not PeekNamedPipe(FStdErrReadPipe, nil, 0, nil, @TotalBytesAvail, nil) then
      RaiseLastOSError;

    // check if bytes are available for reading (on error pipe)
    if (TotalBytesAvail <> 0) then
    begin
      SetLength(Data, TotalBytesAvail);
      ReadFile(FStdErrReadPipe, Data[0], TotalBytesAvail, BytesRead, nil);

      if Assigned(OnError) and (BytesRead > 0) then
        with TStringStream.Create(Data) do
        try
          OnError(Self, DataString);
        finally
          Free;
        end;
    end;

    // eventually write data here in a sync'ed way
    // ...yet TODO

  until (ProcessExitCode <> STILL_ACTIVE) or Terminated;
end;

end.
