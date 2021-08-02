program ExploreDelphiLSP;

uses
  Vcl.Forms,
  dla.PipedExecution in 'dla.PipedExecution.pas',
  dla.Main in 'dla.Main.pas' {FormMain},
  dla.Classes in 'dla.Classes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.

