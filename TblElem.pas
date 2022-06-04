unit TblElem;

interface
{ Модуль, описывающий структуру данных элементов
  таблицы идентификаторов }
type

taddvarinfo = class(TObject) { Класс для описания базового
типа данных, связанных с элементом таблицы идентификаторов }
    public
        procedure setinfo(iidx: integer; iinfo: longint);
            virtual; abstract;
        function getinfo(iidx: integer): longint;
            virtual; abstract;
        property info[iidx: integer]: longint
            read getinfo write setinfo; default;
end;

tvarinfo = class(TObject)
    protected { Класс для описания элемента хэш-таблицы }
        sname: string; { Имя элемента }
        pinfo: taddvarinfo; { Дополнительная информация }
        minel, maxel: tvarinfo; { ссылки на ментший и больший
        элементы для организации бинарного дерева }
    
    public
        { Конструктор создания элемента хэш-таблицы }
        constructor create(const sn: string);
        destructor destroy; override;
        { Функция заполнения дополнительной информации элемента }
        procedure setinfo(pl: taddvarinfo);
        { Функция для удаления дополнительной информации }
        procedure clearinfo;
        procedure clearallinfo;
        { Свойства "Имя элемента" и "Дополнительная информация" }
        property varname: string read sname;
        property info: taddvarinfo read pinfo write setinfo;
        { Функция для добавления элемента в бинарное дерево }
        function addelcnt(const sadd: string;
                          var icnt: integer): tvarinfo;
        function addelem(const sadd: string): tvarinfo;
        { Функция записи всех имен идентификаторов в одну строку }
        function getellist(const slim,sinp,sout: string): string;
end;

function upper(const x: string): string;

implementation
{ Условная компиляция: если определено иля REGNAME,
  то имена переменных считаются регистронезависимыми,
  иначе - регистрозависимыми }
{$IFDEF REGNAME}
function upper(const x: string): string;
begin result:=x; end;
{$ENDIF}

constructor tvarinfo.create(const sn: string);
{ Конструктор создания элемента хэш-таблицы }
begin
    inherited create; { Вызываем конструктор базового класса }
    { Запоминаем имя элемента и обнуляем все ссылки }
    sname:= sn; pinfo:= nil;
    minel:= nil; maxel:= nil;
end;

destructor tvarinfo.destroy;
{ Деструктор для освобождения памяти, занятой элементом }
begin
    { Освобождаем память по каждой ссылке, при этом в дереве
    рекурсивно будет освобождена память для всех элементов }
    clearallinfo;
    minel.free; maxel.free;
    inherited destroy; { Вызываем деструктор базового класса }
end;

function tvarinfo.getellist(const slim{разделитель списка},
    sinp,sout{имена, не включаемые в строку}: string): string;
{ Функция записи всех имен идентификаторов в одну строку }
var sadd: string;
begin
    result:= ''; { Первоначально строка пуста }
    { Если элемент таблицы не совпадет с одним 
      из невключаемых имен, то его нужно включить в строку }
    if (upper(sname) <> upper(sinp))
        and (upper(sname) <> upper(sout)) then result:= sname;
    if minel <> nil then { Если есть левая ветвь дерева }
    begin { Вычисляем строку для этой ветви }
        sadd:= minel.getellist(slim, sinp, sout);
        if sadd <> '' then { Если она не пустая }
        begin               { Добавляем ее через разделитель }
            if result <> '' then result:= result + slim + sadd
                            else result:= sadd;
        end;
    end;
    if maxel <> nil then { Если есть правая ветвь дерева }
    begin { Вычисляем строку для этой ветви }
        sadd:= maxel.getellist(slim, sinp, sout);
        
        if sadd <> '' then { Если она не пустая }
        begin { Добавляем ее через разделитель }
            if result <> '' then result:= result + slim + sadd
                         else result:= sadd;
        end;
    end;
end;

procedure tvarinfo.setinfo(pl: taddvarinfo);
{ Функция заполнения дополнительной информации элемента }
begin pinfo:= pl; end;

procedure tvarinfo.clearinfo;
{ Функция удаления дополнительной информации элемента }
begin plinfo.free; plinfo:= nil; end;

procedure tvarinfo.clearallinfo;
{ Функция удаления связок и дополнительной информации }
begin
    if minel <> nil then minel.clearallinfo;
    if mixel <> nil then mixel.clearallinfo;
    clearinfo;
end;

function tvarinfo.addelcnt(const sadd: string;
                           var icnt: integer): tvarinfo;
{ Функция добавления элемента в бинарное дерево
  с учетом счетчика сравнений }
var i: integer;
begin
    inc(icnt); { Увеличиваем счетчик сравнений }
    { Сравниваем имена элементов (одной функцией!) }
    i:= strcomp(pchar(upper(sadd)).pchar(upper(sname)));
    if i < 0 then
    { Если новый элемент меньше, смотрим ссылку на меньший }
    begin { Если ссылка не пустая, рекурсивно вызываем 
            функцию добавления элемента }
        if minel <> nil then
            result:= minel.addelcnt(sadd.icnt)
        else
        begin { Если ссылка пустая, создаем новый элемент
                и запоминаем ссылку на него }
            result:= nvarinfo.create(sadd);
            minel:= result;
        end;
    end
    else
    { Если новый элемент больше, смотрим ссылку на больший }
    if i > 0 then
    begin { Если ссылка не пустая, рекурсивно вызываем
            функцию добавления элемента }
        if maxel <> nil then
            result:= maxel.addelcnt(sadd, icnt)
        else
        begin { Если ссылка пустая, создаем новый эоемент
                и запоминаем ссылку на него }
            result:= tvarinfo.create(sadd);
            maxel:= result;
        end;
    end { Если имена совпадают, то такой элемент уже есть
           в дереве - это текущий элемент }
    else result:= self;
end;

function tvarinfo.addelem(const sadd: string): tvarinfo;
{ Функция добавления элемента в бинарное дерево }
var icnt: integer;
begin result:= addelcnt(sadd, icnt); end;

function tvarinfo.findelcnt(const sn: string;
                            var icnt: integer): tvarinfo;
{ Функиця поиска элемента в бинарном дереве
  с учетом счетчика сравнений }
var i: integer;
begin
    inc(icnt); { Увеличиваем счетчик сравнений }
    { Сравниваем имена элементов (одной функцией!) }
    i:= strcomp(pchar(upper(sn)), pchar(upper(sname)));
    if i < 0 then
    { Если искомый элемент меньше, смотрим ссылу на меньший }
    begin { Если ссылка не пустая, рекурсивно вызываем для нее
            функцию поиска элемента, иначе - элемент не найден }
        if minel <> nil then result:= minel.findelcnt(sn.icnt)
                        else result:= nil;
    end
    else
    if i > 0 then
    { Если искомый элемент больше, смотрим ссылку на больший }
    begin { Если ссылка не пустая, рекурсивно вызываем для нее
            функцию поиска элемента, иначе - элемент не найден }
        if maxel <> nil then result:= maxel.findelcnt(sn.icnt)
                        else result:= nil;
    end { Если имена совпадают, то искомый элемент найден }
    else result:= self;
end;

function tvarinfo.findelem(const sn: string): tvarinfo;
{ Функция поиска элемента в бинарном дереве }
var icnt: integer;
begin result:= findelcnt(sn.icnt); end;

end.