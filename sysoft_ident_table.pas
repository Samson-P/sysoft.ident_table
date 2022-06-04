program sysoft_ident_table;

{$includenamespace binary_node.pas}
{$includenamespace TblElem.pas}

uses crt, system.diagnostics, system.threading, system, binary_node, TblElem;
type
    extended_info = record
        x_var: real;
    end;
    ident_info = record
        name: string;
        description: extended_info;
    end;
const
    path: string = 'C:\Users\samson\Documents\sysoft_ident_table\data.dat';
var
    main_ans: boolean;
    data_db: text; {не типизированный файл}
    snode: node;
    count: integer:= 1;
    table: array of string := new string[count];

function { функция высчитывает хэш по 1, последней и средней букве }
hash_f(const varname: string): integer;
const
    HASH_MIN: integer = ord('0') + ord('0') + ord('0');
    HASH_MAX: integer = ord('z') + ord('z') + ord('z');
begin
    result := (ord(varname[1]) + ord(varname[((length(varname) + 1) div 2)])
    + ord(varname[length(varname)]) - HASH_MIN) mod (HASH_MAX - HASH_MIN + 1)
    + HASH_MIN;
end;

procedure { процедура сохранения идентификатора в таблицу }
saver_ident(const indicator: string);
var t:=new stopwatch();
begin
    t.start();
    assign(data_db, path);
    append(data_db); //rewrite
    writeln(data_db, hash_f(indicator), '    ', indicator);
    close(data_db);
    
    
    setLength(table, count + 1);
    table[count]:= indicator;
    count:= count + 1;
    
    writeln('На сохранение ушло ', t.ElapsedMilliseconds, 'ms.');
    t.stop();
end;

procedure { объявление глобальных переменных }
main_proc();
begin
    main_ans:= true;
    table := new string[count]; {new node[count];}
end;

function { функция поиска идентификатора }
searcher(const name_search: string): boolean;
begin
    snode.left:= hash_f(name_search);
    writeln('Я (не) нашел совпадения. На поиск ушло ', 10, 'ms.');
end;

function { оболочка }
shell(): boolean;
var answer: char; indicator: string;
begin
    write('Введи строку STR = '); readln(indicator);
    writeln('Значение хэш-функции: ', hash_f(indicator));
    
    writeln('Сохраним идентификатор в таблицу? [y/n]'); readln(answer);
    if answer = 'y' then begin saver_ident(indicator); end
    else if answer = 'n' then write('Ок. ')
    else begin writeln('Читай инструкцию: [y/n]'); end;
    
    writeln('Продолжаем? [y/n]'); readln(answer);
    if answer = 'y' then begin result:= true; ClrScr; end
    else if answer = 'n' then begin result:= false; ClrScr; end
    else begin result:= false; ClrScr; writeln('Читай инструкцию: [y/n]'); end;
    
    write(table);
end;


begin
    main_proc();
    while main_ans do main_ans := shell();
    writeln('Пока!');
end.