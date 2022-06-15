TLab1Form.ViewStatistic(iTree,iHash: integer); { FormLab1.pas }

{$R *.DFM}




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