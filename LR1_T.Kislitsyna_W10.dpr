program LR1_T.Kislitsyna_W10;

uses
  Forms,
  FormLab1 in 'FormLab1.pas' {Lab1Form},
  FncHash in '.\Common\FncHash.pas',
  TblElem in '.\Common\TblElem.pas',
  FncTree in '.\Common\FncTree.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Lab. work 1';
  Application.CreateForm(TLab1Form, Lab1Form);
  Application.Run;
end.
