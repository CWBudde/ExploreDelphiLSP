unit dla.Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  System.JSON, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, dla.PipedExecution, dla.Classes;

type
  TFormMain = class(TForm)
    GroupBoxOutput: TGroupBox;
    Splitter1: TSplitter;
    MemoOutput: TMemo;
    GroupBoxInput: TGroupBox;
    Splitter2: TSplitter;
    MemoInput: TMemo;
    Panel1: TPanel;
    ButtonSend: TButton;
    ButtonClear: TButton;
    GroupBoxPredefined: TGroupBox;
    ButtonInitialize: TButton;
    ButtonInitialized: TButton;
    ButtonShutdown: TButton;
    ButtonExit: TButton;
    procedure EditCommandKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ButtonInitializeClick(Sender: TObject);
    procedure ButtonSendClick(Sender: TObject);
    procedure ButtonClearClick(Sender: TObject);
    procedure ButtonInitializedClick(Sender: TObject);
    procedure ButtonShutdownClick(Sender: TObject);
    procedure ButtonExitClick(Sender: TObject);
  private
    FPipedExecution: TPipedExecution;
    procedure PipedExecutionExitHandler(Sender: TObject; ExitCode: Cardinal);
    procedure PipedExecutionInputHandler(Sender: TObject; const Text: string);
    procedure PipedExecutionErrorHandler(Sender: TObject; const Text: string);
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

{ TFormMain }

procedure TFormMain.FormCreate(Sender: TObject);
var
  Executable: string;
begin
  Executable := 'C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\DelphiLSP.exe';

  if not FileExists(Executable) then
    raise Exception.Create('File ' + Executable + ' does not exist');

  // run executable in a separate process (the output is piped back)
  FPipedExecution := TPipedExecution.Create(Executable, '', '');
  FPipedExecution.OnInput := PipedExecutionInputHandler;
  FPipedExecution.OnError := PipedExecutionErrorHandler;
  FPipedExecution.OnExit := PipedExecutionExitHandler;
  FPipedExecution.Suspended := False;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  FPipedExecution.Terminate;
  FPipedExecution.WaitFor;
  FPipedExecution.Free;
end;

procedure TFormMain.ButtonSendClick(Sender: TObject);
var
  Header: AnsiString;
  Payload: Utf8String;
begin
  Payload := Utf8String(MemoInput.Text);
  Header := AnsiString('Content-Length: ' + IntToStr(Length(Payload)) + #13#10 + #13#10);
  FPipedExecution.WriteText(Header);
  FPipedExecution.WriteText(Payload);
end;

procedure TFormMain.ButtonShutdownClick(Sender: TObject);
var
  Shutdown: TMessageRequestShutdown;
begin
  Shutdown := TMessageRequestShutdown.Create(2);
  MemoInput.Text := Shutdown.Json.Format(2);
end;

procedure TFormMain.ButtonInitializedClick(Sender: TObject);
var
  Initialized: TMessageNotificationInitialized;
begin
  Initialized := TMessageNotificationInitialized.Create;
  MemoInput.Text := Initialized.Json.Format(2);
end;

procedure TFormMain.ButtonClearClick(Sender: TObject);
begin
  MemoInput.Clear;
end;

procedure TFormMain.ButtonExitClick(Sender: TObject);
var
  ExitNotification: TMessageNotificationExit;
begin
  ExitNotification := TMessageNotificationExit.Create;
  MemoInput.Text := ExitNotification.Json.Format(2);
end;

procedure TFormMain.ButtonInitializeClick(Sender: TObject);
var
  Initialize: TMessageRequestInitialize;
begin
  Initialize := TMessageRequestInitialize.Create(1);
  Initialize.Params.Trace := tvVerbose;
  Initialize.Params.RootUri := 'file://c:/Input.txt';
  MemoInput.Text := Initialize.Json.Format(2);
end;

procedure TFormMain.EditCommandKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    FPipedExecution.WriteText(Utf8String(MemoInput.Text));
end;

procedure TFormMain.PipedExecutionErrorHandler(Sender: TObject;
  const Text: string);
var
  StringList: TStringList;
begin
  StringList := TStringList.Create;
  try
    StringList.Text := Text;
    for var Line: String in StringList do
      OutputDebugString(PWideChar(Line));
  finally
    StringList.Free;
  end;
end;

procedure TFormMain.PipedExecutionExitHandler(Sender: TObject;
  ExitCode: Cardinal);
begin
  FPipedExecution := nil;
end;

procedure TFormMain.PipedExecutionInputHandler(Sender: TObject;
  const Text: string);
begin
  FormMain.MemoOutput.Lines.Add(Text);
end;

end.
