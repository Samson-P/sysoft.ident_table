program LR1_T.Kislitsyna_W10;

uses
  UI in 'UI.pas',
  func_hash in '.\gen\func_hash.pas',
  table_element in '.\gen\table_element.pas',
  func_tree in '.\gen\func_tree.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Lab. work 1. War10';
  Application.CreateForm(TLab1Form, Lab1Form);
  Application.Run;
end.
