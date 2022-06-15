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
    { Счетчик поиска и переменные для хранения суммарных результатов поиска }
    iCountNum,iCountHash,iCountTree: integer;
    { Процедура поиска заданной строки }
    procedure SearchStr(const sSearch: string);
    { Процедура вывода на экран статистической информации о поиске переписана }
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
  { Начальная инициализация таблиц и счетчиков }
  InitTreeVar;
  InitHashVar;
  iCountNum := 0;
  iCountHash := 0;
  iCountTree := 0;
end;

procedure TLab1Form.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  { Освобождение памяти таблиц при выходе из программы }
  ClearTreeVar;
  ClearHashVar;
end;

procedure TLab1Form.BtnFileClick(Sender: TObject);
begin
  if FileOpenDlg.Execute then
  { Выбор имени файла с помощью стандартного диалога }
  begin
    EditFile.Text := FileOpenDlg.FileName;
    BtnLoad.Enabled := (EditFile.Text <> '');
  end;
end;

procedure TLab1Form.EditFileChange(Sender: TObject);
begin
  { Можно читать файл, только когда его имя не пустое }
  BtnLoad.Enabled := (EditFile.Text <> '');
end;

procedure TLab1Form.ViewStatistic(iTree,iHash: integer);
{ Вывод на экран статистической информации о поиске }
begin
  wite(Format('Всего поиск: %d раз',[iCountNum]));
  wite(Format('Сравнений рехэширование: %d',[iHash]));
  wite(Format('Сравнений ветвление: %d',[iTree]));
  wite(Format('Всего сравнений рехэширование: %d',[iCountHash]));
  wite(Format('Всего сравнений ветвление: %d',[iCountTree]));
  if iCountNum > 0 then
  begin
    wite(Format('В среднем сравнений рехэширование: %.2f',[iCountHash/iCountNum]));
    wite(Format('В среднем сравнений ветвление: %.2f',[iCountTree/iCountNum]));
  end
  else
  begin
    wite(Format('В среднем сравнений рехэширование: %.2f',[0.0]));
    wite(Format('В среднем сравнений ветвление: %.2f',[0.0]));
  end;
end;

procedure TLab1Form.BtnLoadClick(Sender: TObject);
var
  sTmp: string;
  i: integer;
begin
  try
    { Чтение файла }
    with ListIdents.Lines do
    begin
      { загружаем файл в список строк }
      LoadFromFile(EditFile.Text);
      { Очищаем обе таблицы и счетчики }
      ClearTreeVar;
      ClearHashVar;
      iCountNum := 0;
      iCountHash := 0;
      iCountTree := 0;
      { Просматриваем все строки прочитанного файла,
        считая каждую строку идентификатором }
      for i:=Count-1 downto 0 do
      begin
        sTmp := Trim(Strings[i]);
        { Убираем незначащие пробелы в начале и в конце строки }
        if sTmp <> '' then { пустую строку пропускаем }
        begin
          { Увеличиваем счетчик считанных идентификаторов }
          Inc(iCountNum);
          { Добавляем идентификатор в дерево
            и увеличиваем счетчик сделанных сравнений }
          if AddTreeVar(sTmp) = nil then
           MessageDlg(Format('Ошибка добавления идентификатора "%s" в дерево!',[sTmp]),
                      mtWarning,[mbOk],0);
          Inc(iCountTree,GetTreeCount);
          { Добавляем идентификатор в таблицу рехэширования
            и увеличиваем счетчик сделанных сравнений }
          if AddHashVar(sTmp) = nil then
           MessageDlg(Format('Ошибка рехэширования идентификатора "%s"!',[sTmp]),
                      mtWarning,[mbOk],0);
          Inc(iCountHash,GetHashCount);
        end;
        Strings[i] := sTmp;
      end{for};
      MessageDlg(Format('Считано %d идентификаторов',[iCountNum]),mtInformation,[mbOk],0);
      { Заполняем информацию о статистике сравнений для считанного файла }
      LblHashRes.Caption := 'Поиск не проводился';
      LblTreeRes.Caption := 'Поиск не проводился';
      ViewStatistic(0,0);
    end{with};
    except
      MessageDlg('Ошибка чтения файла!',mtError,[mbOk],0);
  end;
  { Поиск можно вести только для непустых строк }
  BtnSearch.Enabled := (ListIdents.Lines.Count>0) and (Trim(EditSearch.Text)<>'');
end;

procedure TLab1Form.EditSearchChange(Sender: TObject);
begin
  { Поиск можно вести только для непустых строк }
  BtnSearch.Enabled := (ListIdents.Lines.Count>0) and (Trim(EditSearch.Text)<>'');
end;

procedure TLab1Form.SearchStr(const sSearch: string);
{ Поиск заданной строки }
begin
  { Ищем строку в дереве }
  if GetHashVar(sSearch) = nil then
   LblHashRes.Caption := 'Идентификатор не найден'
  else
   LblHashRes.Caption := 'Идентификатор найден';
  { Увеличиваем счетчик поиска }
  Inc(iCountHash,GetHashCount);
  { Ищем ту же самую строку в таблице рехэширования }
  if GetTreeVar(sSearch) = nil then
   LblTreeRes.Caption := 'Идентификатор не найден'
  else
   LblTreeRes.Caption := 'Идентификатор найден';
  { Увеличиваем счетчик поиска }
  Inc(iCountTree,GetTreeCount);
end;

procedure TLab1Form.BtnSearchClick(Sender: TObject);
var
  sSearch: string;
begin
  { Увеличиваем счетчик вызова поиска }
  Inc(iCountNum);
  { Убираем незначащие пробелы в начале и в конце искомой строки }
  sSearch := Trim(EditSearch.Text);
  EditSearch.Text := sSearch;
  { Выполняем поиск идентификатора в обеих таблицах }
  SearchStr(sSearch);
  { Заполняем статистические данные }
  ViewStatistic(GetTreeCount,GetHashCount);
end;

procedure TLab1Form.BtnAllSearchClick(Sender: TObject);
{ Авто-поиск всех подряд идентификаторов из списка }
var
  i,iAllTree,iAllHash: integer;
begin
  { Запоминаем текущие счетчики сравнений }
  iAllTree := iCountTree;
  iAllHash := iCountHash;
  { Выполняем все действия для списка строк }
  with ListIdents.Lines do
  begin
    { Выполняем операцию поиска для каждой непустой строки }
    for i:=Count-1 downto 0 do
     if Strings[i] <> '' then
     begin
       { Увеличиваем счетчик операций поиска }
       Inc(iCountNum);
       { Выполняем поиск }
       SearchStr(Strings[i]);
     end;
  end;
  { Заполняем статистические данные }
  ViewStatistic(iCountTree-iAllTree,iCountHash-iAllHash);
end;

procedure TLab1Form.BtnResetClick(Sender: TObject);
begin
  { Обнуление статистической информации по кнопке "Сброс" }
  iCountNum := 0;
  iCountHash := 0;
  iCountTree := 0;
  { Заполняем статистические данные }
  LblHashRes.Caption := 'Поиск не проводился';
  LblTreeRes.Caption := 'Поиск не проводился';
  ViewStatistic(0,0);
end;

procedure TLab1Form.BtnExitClick(Sender: TObject);
begin
  { Выход из программы }
  Self.Close;
end;

end.
