unit UI;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Vcl.ExtCtrls;

type
  TLab1Form = class(TForm)
    GroupText: TGroupBox;
    GroupFile: TGroupBox;
    GroupSearch: TGroupBox;
    EditFile: TEdit;
    BtnLoad: TButton;
    EditSearch: TEdit;
    BtnSearch: TButton;
    ListIdents: TMemo;
    FileOpenDlg: TOpenDialog;
    GroupHash: TGroupBox;
    GroupTree: TGroupBox;
    LblSearchCount: TLabel;
    LblHashRes: TLabel;
    LblHashCount: TLabel;
    LblHashAvrg: TLabel;
    LblTreeRes: TLabel;
    LblTreeCount: TLabel;
    LblTreeAvrg: TLabel;
    BtnExit: TButton;
    BtnReset: TButton;
    BtnAllSearch: TButton;
    LblHashAllCount: TLabel;
    LblTreeAllCount: TLabel;
    Panel1: TPanel;
    BtnFile: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnFileClick(Sender: TObject);
    procedure EditFileChange(Sender: TObject);
    procedure BtnLoadClick(Sender: TObject);
    procedure EditSearchChange(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
    procedure BtnSearchClick(Sender: TObject);
    procedure BtnResetClick(Sender: TObject);
    procedure BtnAllSearchClick(Sender: TObject);
   private
    { ������� ������ � ���������� ��� �������� ��������� ����������� ������ }
    iCountNum,iCountHash,iCountTree: integer;
    { ��������� ������ �������� ������ }
    procedure SearchStr(const sSearch: string);
    { ��������� ������ �� ����� �������������� ���������� � ������ ���������� }
    procedure ViewStatistic(iTree,iHash: integer);
   public
    { Public declarations }
  end;

var
  Lab1Form: TLab1Form;

implementation

//{$R *.DFM}

uses func_tree, func_hash;

procedure TLab1Form.FormCreate(Sender: TObject);
begin
  { ��������� ������������� ������ � ��������� }
  InitTreeVar;
  InitHashVar;
  iCountNum := 0;
  iCountHash := 0;
  iCountTree := 0;
end;

procedure TLab1Form.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  { ������������ ������ ������ ��� ������ �� ��������� }
  ClearTreeVar;
  ClearHashVar;
end;

procedure TLab1Form.BtnFileClick(Sender: TObject);
begin
  if FileOpenDlg.Execute then
  { ����� ����� ����� � ������� ������������ ������� }
  begin
    EditFile.Text := FileOpenDlg.FileName;
    BtnLoad.Enabled := (EditFile.Text <> '');
  end;
end;

procedure TLab1Form.EditFileChange(Sender: TObject);
begin
  { ����� ������ ����, ������ ����� ��� ��� �� ������ }
  BtnLoad.Enabled := (EditFile.Text <> '');
end;

procedure TLab1Form.ViewStatistic(iTree,iHash: integer);
{ ����� �� ����� �������������� ���������� � ������ }
begin
  wite(Format('����� �����: %d ���',[iCountNum]));
  wite(Format('��������� �������������: %d',[iHash]));
  wite(Format('��������� ���������: %d',[iTree]));
  wite(Format('����� ��������� �������������: %d',[iCountHash]));
  wite(Format('����� ��������� ���������: %d',[iCountTree]));
  if iCountNum > 0 then
  begin
    wite(Format('� ������� ��������� �������������: %.2f',[iCountHash/iCountNum]));
    wite(Format('� ������� ��������� ���������: %.2f',[iCountTree/iCountNum]));
  end
  else
  begin
    wite(Format('� ������� ��������� �������������: %.2f',[0.0]));
    wite(Format('� ������� ��������� ���������: %.2f',[0.0]));
  end;
end;

procedure TLab1Form.BtnLoadClick(Sender: TObject);
var
  sTmp: string;
  i: integer;
begin
  try
    { ������ ����� }
    with ListIdents.Lines do
    begin
      { ��������� ���� � ������ ����� }
      LoadFromFile(EditFile.Text);
      { ������� ��� ������� � �������� }
      ClearTreeVar;
      ClearHashVar;
      iCountNum := 0;
      iCountHash := 0;
      iCountTree := 0;
      { ������������� ��� ������ ������������ �����,
        ������ ������ ������ ��������������� }
      for i:=Count-1 downto 0 do
      begin
        sTmp := Trim(Strings[i]);
        { ������� ���������� ������� � ������ � � ����� ������ }
        if sTmp <> '' then { ������ ������ ���������� }
        begin
          { ����������� ������� ��������� ��������������� }
          Inc(iCountNum);
          { ��������� ������������� � ������
            � ����������� ������� ��������� ��������� }
          if AddTreeVar(sTmp) = nil then
           MessageDlg(Format('������ ���������� �������������� "%s" � ������!',[sTmp]),
                      mtWarning,[mbOk],0);
          Inc(iCountTree,GetTreeCount);
          { ��������� ������������� � ������� �������������
            � ����������� ������� ��������� ��������� }
          if AddHashVar(sTmp) = nil then
           MessageDlg(Format('������ ������������� �������������� "%s"!',[sTmp]),
                      mtWarning,[mbOk],0);
          Inc(iCountHash,GetHashCount);
        end;
        Strings[i] := sTmp;
      end{for};
      MessageDlg(Format('������� %d ���������������',[iCountNum]),mtInformation,[mbOk],0);
      { ��������� ���������� � ���������� ��������� ��� ���������� ����� }
      LblHashRes.Caption := '����� �� ����������';
      LblTreeRes.Caption := '����� �� ����������';
      ViewStatistic(0,0);
    end{with};
    except
      MessageDlg('������ ������ �����!',mtError,[mbOk],0);
  end;
  { ����� ����� ����� ������ ��� �������� ����� }
  BtnSearch.Enabled := (ListIdents.Lines.Count>0) and (Trim(EditSearch.Text)<>'');
end;

procedure TLab1Form.EditSearchChange(Sender: TObject);
begin
  { ����� ����� ����� ������ ��� �������� ����� }
  BtnSearch.Enabled := (ListIdents.Lines.Count>0) and (Trim(EditSearch.Text)<>'');
end;

procedure TLab1Form.SearchStr(const sSearch: string);
{ ����� �������� ������ }
begin
  { ���� ������ � ������ }
  if GetHashVar(sSearch) = nil then
   LblHashRes.Caption := '������������� �� ������'
  else
   LblHashRes.Caption := '������������� ������';
  { ����������� ������� ������ }
  Inc(iCountHash,GetHashCount);
  { ���� �� �� ����� ������ � ������� ������������� }
  if GetTreeVar(sSearch) = nil then
   LblTreeRes.Caption := '������������� �� ������'
  else
   LblTreeRes.Caption := '������������� ������';
  { ����������� ������� ������ }
  Inc(iCountTree,GetTreeCount);
end;

procedure TLab1Form.BtnSearchClick(Sender: TObject);
var
  sSearch: string;
begin
  { ����������� ������� ������ ������ }
  Inc(iCountNum);
  { ������� ���������� ������� � ������ � � ����� ������� ������ }
  sSearch := Trim(EditSearch.Text);
  EditSearch.Text := sSearch;
  { ��������� ����� �������������� � ����� �������� }
  SearchStr(sSearch);
  { ��������� �������������� ������ }
  ViewStatistic(GetTreeCount,GetHashCount);
end;

procedure TLab1Form.BtnAllSearchClick(Sender: TObject);
{ ����-����� ���� ������ ��������������� �� ������ }
var
  i,iAllTree,iAllHash: integer;
begin
  { ���������� ������� �������� ��������� }
  iAllTree := iCountTree;
  iAllHash := iCountHash;
  { ��������� ��� �������� ��� ������ ����� }
  with ListIdents.Lines do
  begin
    { ��������� �������� ������ ��� ������ �������� ������ }
    for i:=Count-1 downto 0 do
     if Strings[i] <> '' then
     begin
       { ����������� ������� �������� ������ }
       Inc(iCountNum);
       { ��������� ����� }
       SearchStr(Strings[i]);
     end;
  end;
  { ��������� �������������� ������ }
  ViewStatistic(iCountTree-iAllTree,iCountHash-iAllHash);
end;

procedure TLab1Form.BtnResetClick(Sender: TObject);
begin
  { ��������� �������������� ���������� �� ������ "�����" }
  iCountNum := 0;
  iCountHash := 0;
  iCountTree := 0;
  { ��������� �������������� ������ }
  LblHashRes.Caption := '����� �� ����������';
  LblTreeRes.Caption := '����� �� ����������';
  ViewStatistic(0,0);
end;

procedure TLab1Form.BtnExitClick(Sender: TObject);
begin
  { ����� �� ��������� }
  Self.Close;
end;

end.
