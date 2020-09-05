unit Unit1;

interface
uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Math;


  type rasp=                     //Массив с распределением по диаметрам (первое измерение) в годичной динамике (второе)
    array[1 ..1000, 1 ..100] of real;
   type Carb=
     array[1 ..10] of real;
  type Taxa=           //Таксационные данные
         record
         k: real;   //Коэффициент пересчета
         A: integer;    //Возраст
         D: real;        //Средний диаметр
         NH: integer;         //Густота, шт/га
         Bon: real;         //Индекс бонитета Iа бонитет - 2, I - 3 и т.д.
         H: real;           // Средняя высота
         G: real;          // Сумма площадей сечения
         f: real;           //Коэффициент формы
         V: real;          //Запас древесины, м3
         end;


  type ForestCarbon=               //Тип для расчета динамики роста деревьев по диаметру и последующего расчета запасов углерода 
    class
      private

         kk: TextFile;

         NP: integer;               //Число деревьев в выборке (пробе)
         Tax: array[1 ..100] of Taxa;    //Массив погодичный с таксационными данными
         raspD: rasp;                //Динамика распределения по диаметрам
         raspRD: array[1 .. 1000] of integer;     //Распределение по относительным диаметрам
         currentA: integer;             //Текущий возраст
         procedure CountRD();         //Расчет относительных диаметров
         procedure CountTaxa();        //Расчет таксационных данных
         procedure Prirost();          //Расчет прироста по диаметру, деревьв входящих в выборку
         procedure Prirost2();
         Procedure Otpad();          //Расчет отпада
      public
        procedure Init(NPP:integer; NH: integer; D:real; Bon:real; A:integer; raspDD: array of real);    //Инициализация
        //function MesCurA: integer;
        procedure ForwardYear();    //Расчет прироста и отпада за год
        //procedure CarbonCount(A: integer);
        procedure GetDataCarbon(AAA: integer; A:integer; var Data: carb);
        procedure getRaspD(a: integer);
        procedure GetTaxa();
        Procedure Rubka(IR: Real);


    end;

implementation
uses model;

procedure ForestCarbon.Init(NPP:integer; NH: integer; D:real; Bon:real; A:integer; raspDD: array of real);

//Инициализация переменных класса, задание первоначальных условий: такс. хар-к и распределения по диаметрам
var i: integer;
begin
NP:=NPP;
Tax[a].D:=d;
currentA:=A;

Tax[a].A:=a;
Tax[a].NH:=NH;
Tax[a].Bon:=Bon;
Tax[a].k:=NH/NP;
Tax[a].G:=(sqr(d)*Pi/4)*nh/10000;
for i:=1 to np do
  raspD[i, a]:=raspDD[i];

randomize;

CountRD();

AssignFile(Kk, 'morta');
        Rewrite(kk);


end;


procedure ForestCarbon.CountRD();
// Распределяет деревья по относительным диаметрам
var i:integer;
begin
for i:=1 to NP do
  begin
  if ((raspD[i,currentA]/Tax[currentA].D<0.6) and (raspD[i, currentA]>0)) then raspRD[i]:=5;
  if ((raspD[i,currentA]/Tax[currentA].D<0.8) and (raspD[i,currentA]/Tax[currentA].D>=0.6)) then raspRD[i]:=7;
  if ((raspD[i,currentA]/Tax[currentA].D<1.0) and (raspD[i,currentA]/Tax[currentA].D>=0.8)) then raspRD[i]:=9;
  if ((raspD[i,currentA]/Tax[currentA].D<1.2) and (raspD[i,currentA]/Tax[currentA].D>=1.0)) then raspRD[i]:=11;
  if ((raspD[i,currentA]/Tax[currentA].D<1.4) and (raspD[i,currentA]/Tax[currentA].D>=1.2)) then raspRD[i]:=13;
  if ((raspD[i,currentA]/Tax[currentA].D<1.6) and (raspD[i,currentA]/Tax[currentA].D>=1.4)) then raspRD[i]:=15;
  if (raspD[i,currentA]/Tax[currentA].D>=1.6) then raspRD[i]:=17;
  if (raspD[i, currentA]<0.0001) then raspRD[i]:=0;
  end;
end;


procedure ForestCarbon.CountTaxa();
//  Предполагается что в Tax[a-1] информация уже имеется
// Выполняется после расчета распределения по диаметрам на данный год
var i: integer;
    sum: real;
    sum2: real;
    nnn: integer;
begin
sum:=0;
sum2:=0;
nnn:=0;
  for i:=1 to NP do
  begin
    if (raspd[i,currenta]>0) then
      begin
         sum:=sum+raspD[i, currenta];
         nnn:=nnn+1;
         sum2:=sum2+(3.14*raspD[i,currenta]*raspD[i,currenta])/4;
      end;
  end;

  if nnn=0 then ShowMessage('gloook');
Tax[currenta].a:=currenta;
Tax[currenta].D:=sum/nnn;
Tax[currenta].k:=Tax[currenta-1].k;
Tax[currenta].g:=(sum2/10000)*Tax[currenta].k;
Tax[currenta].nh:=round((nnn*round(Tax[currenta].k*10000))/10000);
Tax[currenta].Bon:=Tax[currenta-1].Bon;
end;


procedure ForestCarbon.Prirost2();
var i: integer;
    dd: real;
    ds: real;
    r : real;
    ss: real;
    Kw, Kt: real;
begin
for i:=1 to NP do
  begin
    //if (raspd[i, currenta-1]<=0) then
    //begin
    //  raspd[i, currenta]:=0;
    //  rasprd[i]:=0;
    //end;
  if raspd[i, currenta-1]>0 then
  begin

  dd:=-16.4122+15.32260*rasprd[i]/10+0.4154*Tax[currenta-1].bon+0.06690*Tax[currenta-1].a-2.05861*Tax[currenta-1].nh*Tax[currenta-1].d/10000;
  ss:=0.615178+0.358075*dd;
  if (ss<0) then ss:=ss*(-1);

  r:=random;

        if (r>0.5) then
          begin
             r:=r-0.5;
             ss:=(-1*ss*(2.995804+6.36832*r-4.043035*r*r-7.326273*sqrt(r)))/10+(8.393526-0.523469*TV+0.473030*TZ);
             //if (raspD[i, currentA]<raspD[i, currentA-1]) then raspD[i, currentA]:=raspD[i, currentA-1];
          end
          else
             begin
             ss:=(ss*(2.995804+6.36832*r-4.043035*r*r-7.326273*sqrt(r)))/10+(8.393526-0.523469*TV+0.473030*TZ);
             //if (raspD[i, currentA]<raspD[i, currentA-1]) then raspD[i, currentA]:=raspD[i, currentA-1];
             end;
  Kt:=1.14-0.083*Zone;
  Kw:=0.9850774-0.004592*TV+0.139932*TZ;
  dd:=dd*Kw*Kt;

  if dd<0 then
    dd:=0;

  ds:=dd+(sqr(raspd[i,currenta-1])*Pi/4);

    //if ds<0 then
    //   ds:=ds*(-1);
    raspD[i, currentA]:=sqrt(ds*4/Pi);
  end;
  end;
end;

procedure ForestCarbon.Prirost();
var i: integer;
    dd: real;
    r: real;
    s: real;
begin
for i:=1 to NP do
  begin
    if (raspd[i, currenta-1]<0) then
    begin
      raspd[i, currenta]:=0;
      rasprd[i]:=0;
    end;

    if raspRD[i]=5 then
      begin

        dd:=0.030128-0.004296* Tax[currenta-1].d*Tax[currenta-1].nh/10000;
//10*(0.0363459847-0.0000002005*Tax[currenta-1].a*Tax[currenta-1].nh);

        s:=0.036422-0.69375*sqr(dd)+ 0.221293*tax[currenta-1].bon*dd+0.00013*dd* tax[currenta-1].nh+0.000738-0.000016*Tax[currenta-1].a;
        r:=random;
        if (r>0.5) then
          begin
             r:=r-0.5;
               raspD[i, currentA]:=raspD[i, currentA-1]+dd;
             //raspD[i, currentA]:=raspD[i, currentA-1]+(dd-s*(2.995804+6.36832*r-4.043035*r*r-7.326273*sqrt(r)));
             //if (raspD[i, currentA]<raspD[i, currentA-1]) then raspD[i, currentA]:=raspD[i, currentA-1];
          end
          else
             begin
               raspD[i, currentA]:=raspD[i, currentA-1]+dd;
             //raspD[i, currentA]:=raspD[i, currentA-1]+(dd+s*(2.995804+6.36832*r-4.043035*r*r-7.326273*sqrt(r)));
             //if (raspD[i, currentA]<raspD[i, currentA-1]) then raspD[i, currentA]:=raspD[i, currentA-1];
             end;
        end;



        if raspRD[i]=7 then
      begin

        dd:=0.127625-0.022107* Tax[currenta-1].d*Tax[currenta-1].nh/10000+0.006095-0.000003*sqr(Tax[currenta-1].a);
//10*(0.1480834630-0.0000010297*Tax[currenta-1].a*Tax[currenta-1].nh);

        s:=0.175439+0.818446*dd-0.23026*sqr(dd);
        r:=random;
        if (r>0.5) then
          begin
             r:=r-0.5;
               raspD[i, currentA]:=raspD[i, currentA-1]+dd;
             //raspD[i, currentA]:=raspD[i, currentA-1]+(dd-s*(2.995804+6.36832*r-4.043035*r*r-7.326273*sqrt(r)));
             //if (raspD[i, currentA]<raspD[i, currentA-1]) then raspD[i, currentA]:=raspD[i, currentA-1];
          end
          else
             begin
               raspD[i, currentA]:=raspD[i, currentA-1]+dd;
             //raspD[i, currentA]:=raspD[i, currentA-1]+(dd+s*(2.995804+6.36832*r-4.043035*r*r-7.326273*sqrt(r)));
            // if (raspD[i, currentA]<raspD[i, currentA-1]) then raspD[i, currentA]:=raspD[i, currentA-1];
             end;
      end;


      if raspRD[i]=9 then
      begin

        dd:=0.229362-0.031482* Tax[currenta-1].d*Tax[currenta-1].nh/10000+0.006637-0.000003*sqr(Tax[currenta-1].a);
//10*(0.2811862833-0.0000014207*Tax[currenta-1].a*Tax[currenta-1].nh);

        s:=0.499614+0.063424*dd*tax[currenta-1].bon;
        r:=random;
        if (r>0.5) then
          begin
             r:=r-0.5;
               raspD[i, currentA]:=raspD[i, currentA-1]+dd;
             //raspD[i, currentA]:=raspD[i, currentA-1]+(dd-s*(2.995804+6.36832*r-4.043035*r*r-7.326273*sqrt(r)));
            // if (raspD[i, currentA]<raspD[i, currentA-1]) then raspD[i, currentA]:=raspD[i, currentA-1];
          end
          else
             begin
               raspD[i, currentA]:=raspD[i, currentA-1]+dd;
             //raspD[i, currentA]:=raspD[i, currentA-1]+(dd+s*(2.995804+6.36832*r-4.043035*r*r-7.326273*sqrt(r)));
           //  if (raspD[i, currentA]<raspD[i, currentA-1]) then raspD[i, currentA]:=raspD[i, currentA-1];
             end;
      end;


      if raspRD[i]=11 then
      begin

        dd:=0.341587-0.029096* Tax[currenta-1].d*Tax[currenta-1].nh/10000-0.089578+0.004264*Tax[currenta-1].Bon+0.027322-0.000011*sqr(Tax[currenta-1].a);
//10*(0.3664850798-0.0000010970*Tax[currenta-1].a*Tax[currenta-1].nh);

        s:=0.680105+0.096901*dd*tax[currenta-1].bon-0.00063*dd* tax[currenta-1].a;
        r:=random;
        if (r>0.5) then
          begin
             r:=r-0.5;
             raspD[i, currentA]:=raspD[i, currentA-1]+dd;
             //raspD[i, currentA]:=raspD[i, currentA-1]+(dd-s*(2.995804+6.36832*r-4.043035*r*r-7.326273*sqrt(r)));
            // if (raspD[i, currentA]<raspD[i, currentA-1]) then raspD[i, currentA]:=raspD[i, currentA-1];
          end
          else
             begin
             raspD[i, currentA]:=raspD[i, currentA-1]+dd;
             //raspD[i, currentA]:=raspD[i, currentA-1]+(dd+s*(2.995804+6.36832*r-4.043035*r*r-7.326273*sqrt(r)));
            // if (raspD[i, currentA]<raspD[i, currentA-1]) then raspD[i, currentA]:=raspD[i, currentA-1];
             end;
      end;


      if raspRD[i]=13 then
      begin

        dd:=0.417630-0.028208* Tax[currenta-1].d*Tax[currenta-1].nh/10000-0.123969+0.004515*Tax[currenta-1].Bon+0.052740-0.000020*sqr(Tax[currenta-1].a);
//10*(0.1297104578+0.6666866863*Tax[currenta-1].d/Tax[currenta-1].a);

        s:=0.816372+0.001667*dd*tax[currenta-1].a;
        r:=random;
        if (r>0.5) then
          begin
             r:=r-0.5;
             raspD[i, currentA]:=raspD[i, currentA-1]+dd;
             //raspD[i, currentA]:=raspD[i, currentA-1]+(dd-s*(2.995804+6.36832*r-4.043035*r*r-7.326273*sqrt(r)));
             //if (raspD[i, currentA]<raspD[i, currentA-1]) then raspD[i, currentA]:=raspD[i, currentA-1];
          end
          else
             begin
               raspD[i, currentA]:=raspD[i, currentA-1]+dd;
             //raspD[i, currentA]:=raspD[i, currentA-1]+(dd+s*(2.995804+6.36832*r-4.043035*r*r-7.326273*sqrt(r)));
            // if (raspD[i, currentA]<raspD[i, currentA-1]) then raspD[i, currentA]:=raspD[i, currentA-1];
             end;
      end;


      if raspRD[i]=15 then
      begin

        dd:=0.468756-0.022327*Tax[currenta-1].d*Tax[currenta-1].nh/10000-0.000924+0.000039*Tax[currenta-1].Bon+0.073146-0.000027*sqr(Tax[currenta-1].a);
//10*(0.2411848479+0.5466542628*Tax[currenta-1].d/Tax[currenta-1].a);

        s:=1.766324-4.3E-6*tax[currenta-1].a* tax[currenta-1].nh;
        r:=random;
        if (r>0.5) then
          begin
             r:=r-0.5;
               raspD[i, currentA]:=raspD[i, currentA-1]+dd;
             //raspD[i, currentA]:=raspD[i, currentA-1]+(dd-s*(2.995804+6.36832*r-4.043035*r*r-7.326273*sqrt(r)));
            // if (raspD[i, currentA]<raspD[i, currentA-1]) then raspD[i, currentA]:=raspD[i, currentA-1];
          end
          else
             begin
               raspD[i, currentA]:=raspD[i, currentA-1]+dd;
             //raspD[i, currentA]:=raspD[i, currentA-1]+(dd+s*(2.995804+6.36832*r-4.043035*r*r-7.326273*sqrt(r)));
           //  if (raspD[i, currentA]<raspD[i, currentA-1]) then raspD[i, currentA]:=raspD[i, currentA-1];
             end;
      end;


      if raspRD[i]=17 then
      begin

        dd:=0.503432-0.011052*Tax[currenta-1].d*Tax[currenta-1].nh/10000+0.077583-0.000035*sqr(Tax[currenta-1].a);
//10*(0.6919137550-0.0041032641*Tax[currenta-1].a);
        
        s:=2.074096-0.03104* tax[currenta-1].a;
        r:=random;
        if (r>0.5) then
          begin
             r:=r-0.5;
             raspD[i, currentA]:=raspD[i, currentA-1]+dd;
             //raspD[i, currentA]:=raspD[i, currentA-1]+(dd-s*(2.995804+6.36832*r-4.043035*r*r-7.326273*sqrt(r)));
          //   if (raspD[i, currentA]<raspD[i, currentA-1]) then raspD[i, currentA]:=raspD[i, currentA-1];
          end
          else
             begin
             raspD[i, currentA]:=raspD[i, currentA-1]+dd;
             //raspD[i, currentA]:=raspD[i, currentA-1]+(dd+s*(2.995804+6.36832*r-4.043035*r*r-7.326273*sqrt(r)));
          //   if (raspD[i, currentA]<raspD[i, currentA-1]) then raspD[i, currentA]:=raspD[i, currentA-1];
             end;
      end;


      //if raspRD[i]=0 then raspD[i, currentA]:=0;

   end;

end;


Procedure ForestCarbon.Otpad();
var
i: integer;
r: array[5 .. 17] of real ;
Kt5, Kt7, Kt9, Kt11, Kt13, kt15: real;

begin

Kt5:=1.05-0.075*Zone+0.025*sqr(Zone);
Kt7:=1.0125-0.0275*Zone+0.0125*sqr(Zone);
Kt9:=1.025000-0.041000*Zone+0.015000*sqr(Zone);
Kt11:=1.010000-0.022000*Zone+0.010000*sqr(Zone);
Kt13:=1.002500-0.012500*Zone+0.007500*sqr(Zone);
Kt15:=1.000000-0.007000*Zone+0.005000*sqr(Zone);


r[5]:=Kt5*(0.073460+0.0643*Tax[currenta-1].d*Tax[currenta-1].nh/10000);
//0.234359;
//0.248365-0.01317*tax[currenta-1].Bon+0.001457*exp(Tax[currenta-1].NH*Tax[currenta-1].D/10000);
r[7]:=Kt7*(0.0368+0.0163*Tax[currenta-1].d*Tax[currenta-1].nh/10000);
//0.078326;
//0.090866-0.0133*tax[currenta-1].Bon+0.000337*exp(Tax[currenta-1].NH*Tax[currenta-1].D/10000);
r[9]:=Kt9*0.023392; //0.0396-0.0063*Tax[currenta-1].d*Tax[currenta-1].nh/10000;
//0.043049-0.00926*tax[currenta-1].Bon+8.66e-5*exp(Tax[currenta-1].NH*Tax[currenta-1].D/10000);
r[11]:=Kt11*0.008859; //0.0091-9.9566e-5*Tax[currenta-1].d*Tax[currenta-1].nh/10000;
//0.02383-0.0047*tax[currenta-1].Bon+7.04e-6*exp(Tax[currenta-1].NH*Tax[currenta-1].D/10000);
r[13]:=Kt13*0.005971; //0.0172-0.0043*Tax[currenta-1].d*Tax[currenta-1].nh/10000;
//0.014657-0.00165*tax[currenta-1].Bon-2.4e-5*exp(Tax[currenta-1].NH*Tax[currenta-1].D/10000);
r[15]:=Kt15*0.003940; //0.0122-0.0032*Tax[currenta-1].d*Tax[currenta-1].nh/10000;
//.003;
r[17]:=0.008824; //0.0508-0.0149*Tax[currenta-1].d*Tax[currenta-1].nh/10000;
//.0005;

WriteLn(Kk, r[5],'   ', r[7],'    ', r[9],'     ', r[11],'    ', r[13],'    ', r[15]);

for i:=1 to NP do
  begin
   if ((raspRD[i]=5) and (random<r[5])) then raspd[i,currenta]:=(-1)*raspd[i,currenta];
   if ((raspRD[i]=7) and (random<r[7])) then raspd[i,currenta]:=(-1)*raspd[i,currenta];
   if ((raspRD[i]=9) and (random<r[9])) then raspd[i,currenta]:=(-1)*raspd[i,currenta];
   if ((raspRD[i]=11) and (random<r[11])) then raspd[i,currenta]:=(-1)*raspd[i,currenta];
   if ((raspRD[i]=13) and (random<r[13])) then raspd[i,currenta]:=(-1)*raspd[i,currenta];
   if ((raspRD[i]=15) and (random<r[15])) then raspd[i,currenta]:=(-1)*raspd[i,currenta];
   if ((raspRD[i]=17) and (random<r[17])) then raspd[i,currenta]:=(-1)*raspd[i,currenta];
  end;

end;


procedure ForestCarbon.ForwardYear();

begin
currentA:=currentA+1;
Prirost2();
Otpad();
CountTaxa();
CountRD();
end;


procedure ForestCarbon.getRaspD(a: integer);
var
i: integer;
F: TextFile;

begin

AssignFile(F, 'proba');
 Rewrite(F);

for i:=1 to NP do
    Write(F, raspD[i, a]:8:2);
CloseFile(F);
CloseFile(kk);

end;

procedure ForestCarbon.GetTaxa();
var
z: TextFile;
i: integer;

begin
AssignFile(z, 'taxa');
Rewrite(z);
  for i:=10 to 90 do
     begin
      WriteLn(z, Tax[i].A,'   ', Tax[i].nh,'   ', Tax[i].d,'    ', Tax[i].g);
     end;
CloseFile(z);

end;


procedure ForestCarbon.GetDataCarbon(AAA: integer; A:integer; var Data: Carb);
var
i: integer;

begin
Data[1]:=0;
Data[2]:=0;
Data[3]:=0;
Data[4]:=0;
Data[5]:=0;
Data[6]:=0;
Data[7]:=0;
Data[8]:=0;
Data[9]:=0;
Data[10]:=0;

for i:=1 to np do
   begin
   if RaspD[i, a]>0 then
   begin
Data[1]:=Data[1]+Tax[a].k*0.0514*power(RaspD[i, a], 2.354532);    // Древесина ствола
Data[2]:=Data[2]+Tax[a].k*0.0013*power(RaspD[i, a], 2.734965);    // Кора ствола
if (((a-AAA)>8) and (raspD[i, a]>raspD[i, a-7])) then
  Data[3]:=Data[3]+Tax[a].k*0.0270*power(RaspD[i, a],1.7169)*Power(((RaspD[i, a]-RaspD[i, a-7])*10/14),0.2571)
  else
    Data[3]:=Data[3]+Tax[a].k*0.0103*power(RaspD[i, a],2.0545);     //Ветки
if (((a-AAA)>3) and (raspD[i, a]>raspD[i, a-2])) then
      Data[4]:=Data[4]+Tax[a].k*0.0199*power(RaspD[i, a],1.5634)*Power(((RaspD[i, a]-RaspD[i, a-2])*10/4),0.3906)
   else
     Data[4]:=Data[4]+Tax[a].k*0.0085*power(RaspD[i, a],2.0264);     //Хвоя
  end;
end;
  Data[5]:=0.24*(Data[1]+Data[2]+Data[3]+Data[4]);           //Корни

for i:=1 to np do
   begin
   if RaspD[i, a]<0 then
   begin
Data[6]:=Data[6]+Tax[a].k*0.0514*power((-1)*RaspD[i, a], 2.354532);    // Древесина ствола
Data[7]:=Data[7]+Tax[a].k*0.0013*power((-1)*RaspD[i, a], 2.734965);    // Кора ствола
if (((a-AAA)>8) and ((-1)*raspD[i, a]>raspD[i, a-7])) then
  Data[8]:=Data[8]+Tax[a].k*0.0270*power((-1)*RaspD[i, a],1.7169)*Power((((-1)*RaspD[i, a]-RaspD[i, a-7])*10/14),0.2571)
  else
    Data[8]:=Data[8]+Tax[a].k*0.0103*power((-1)*RaspD[i, a],2.0545);     //Ветки
if (((a-AAA)>3) and ((-1)*raspD[i, a]>raspD[i, a-2])) then
      Data[9]:=Data[9]+Tax[a].k*0.0199*power((-1)*RaspD[i, a],1.5634)*Power((((-1)*RaspD[i, a]-RaspD[i, a-2])*10/4),0.3906)
   else
     Data[9]:=Data[9]+Tax[a].k*0.0085*power((-1)*RaspD[i, a],2.0264);     //Хвоя
  end;
end;
  Data[10]:=0.24*(Data[6]+Data[7]+Data[8]+Data[9]);           //Корни






end;




 Procedure ForestCarbon.Rubka(IR: Real);
 var
 i: Integer;
 ggg: real;
 md: integer;
 mdq: real;

 begin
 ggg:=Tax[currenta].G;
  while (100*(ggg/Tax[currenta].g))>(100-IR) do
   begin
    md:=1;
    mdq:=1000;
    for i:=1 to np do
     begin
      if ((RaspD[i, Currenta]>0) and (RaspD[i, currenta]<=mdq)) then
        begin
         md:=i;
         mdq:=RaspD[i, Currenta];
        end;
     end;
    ggg:=ggg-(Tax[currenta].k*((Sqr(RaspD[md, currenta])*3.14/4)/10000));
    RaspD[md, currenta]:=0;
  end;


end;

end.
