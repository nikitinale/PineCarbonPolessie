unit model;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Unit1;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    FileName: TEdit;
    FileLoad: TButton;
    CNP: TLabel;
    CNH: TLabel;
    CD: TLabel;
    CBon: TLabel;
    CA: TLabel;
    GroupBox1: TGroupBox;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    AR1: TEdit;
    PR1: TEdit;
    AR2: TEdit;
    PR2: TEdit;
    AR3: TEdit;
    PR3: TEdit;
    AR4: TEdit;
    PR4: TEdit;
    AR5: TEdit;
    PR5: TEdit;
    AR6: TEdit;
    PR6: TEdit;
    AR7: TEdit;
    Label16: TLabel;
    PR7: TEdit;
    Label17: TLabel;
    Panel2: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    NNN: TEdit;
    AK: TEdit;
    Button1: TButton;
    Panel3: TPanel;
    Label4: TLabel;
    EFileName: TEdit;
    Button2: TButton;
    Edit1: TEdit;
    Label5: TLabel;
    Edit2: TEdit;
    Edit3: TEdit;
    Label20: TLabel;
    Label21: TLabel;
    procedure FileLoadClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
  
  var
    Form1: TForm1;
    c: ForestCarbon;  // Создание переменной класса
    AAA: integer;       //НАчальный возраст
    OG, TV, TZ, Zone: real;

implementation

{$R *.dfm}

procedure TForm1.FileLoadClick(Sender: TObject);
var
  F: TextFile;
  i: integer;
  A: integer;
  NH, NPp: Integer;
  D, Bon: real;
  raspD: array [1 .. 1000] of real;

begin
 AssignFile(F, FileName.Text);
 Reset(F);

 OG:=623.5985;
 TV:=StrToFloat(Edit2.Text);
 TZ:=StrToFloat(Edit3.Text);
 Zone:=StrToFloat(Edit1.Text);

 Read(F, NPp);
 Read(F, NH);
 Read(f, D);
 Read(F, Bon);
 Read(F, A);
 for i:=1 to NPp do
  begin
    if (not(EOF(F))) then
        Read(F, raspD[i])
      else showMessage('Неверный формат файла');
  end;
 CloseFile(F);

  AAA:=a;
  CNP.Caption:=CNP.Caption+IntToStr(NPp);
  CNH.Caption:=CNH.Caption+IntToStr(NH);
  CA.Caption:=CA.Caption+IntToStr(A);
  CD.Caption:=CD.Caption+FloatToStrF(D, ffGeneral,5,2);
  CBon.Caption:=CBon.Caption+FloatToStrF(Bon, ffGeneral, 4, 2);

  c:=ForestCarbon.Create;
  c.Init(NPp, NH, D, Bon, A, raspD);

end;

procedure TForm1.Button1Click(Sender: TObject);
var
  i, j, q, e: Integer;
  s: integer;
  Data: Carb;
  carbon: TextFile;
  scet: array [1 .. 101, 1 .. 100, 1 .. 10] of real;

begin
AssignFile(carbon, EFileName.Text);
Rewrite(carbon);

s:= StrToInt(Ak.Text);

for i:=AAA to s do
  begin
  c.ForwardYear;
  if StrToInt(Ar1.Text)=i then c.Rubka(StrToFloat(PR1.Text));
  if StrToInt(Ar2.Text)=i then c.Rubka(StrToFloat(PR2.Text));
  if StrToInt(Ar3.Text)=i then c.Rubka(StrToFloat(PR3.Text));
  if StrToInt(Ar4.Text)=i then c.Rubka(StrToFloat(PR4.Text));
  if StrToInt(Ar5.Text)=i then c.Rubka(StrToFloat(PR5.Text));
  if StrToInt(Ar6.Text)=i then c.Rubka(StrToFloat(PR6.Text));
  if StrToInt(Ar7.Text)=i then c.Rubka(StrToFloat(PR7.Text));
  end;
c.getRaspD(70);
e:=StrToInt(NNN.Text);

 for j:=1 to e do   //Количество повторов
   begin
   for i:=AAA to s do
     begin
     c.GetDataCarbon(AAA, i, Data);
        for q:=1 to 10 do
          scet[j,i,q]:=Data[q];
     end;
   end;

for i:=AAA to s do
  for q:=1 to 10 do
    scet[101,i,q]:=0;

for j:=1 to e do
  for i:=AAA to s do
     for q:=1 to 10 do
        scet[101, i, q]:= scet[101, i, q]+scet[j, i, q];

for i:=AAA to s do
  for q:=1 to 10 do
    scet[101,i,q]:=scet[101,i,q]/e;

for i:=AAA to s do
  WriteLn(carbon, i, scet[101, i, 1], scet[101, i, 2], scet[101, i, 3], scet[101, i, 4], scet[101, i, 5], scet[101, i, 6], scet[101, i, 7], scet[101, i, 8], scet[101, i, 9], scet[101, i, 10]);

CloseFile(Carbon);

c.GetTaxa;

end;

end.
