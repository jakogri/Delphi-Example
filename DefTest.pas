unit DefTest;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TOper = record
   FirstOperand   : Extended;
   Operation : string;
   Priority	 : integer;
   Deletet : Boolean;
  end;
  TCalcArray = array of TOper;
  TForm1 = class(TForm)
    Edit1: TEdit;
    StaticText1: TStaticText;
    Button1: TButton;
    StaticText2: TStaticText;
    ResultText: TRichEdit;
    procedure Edit1Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    open_bracket : string;
    WorkSettings: TFormatSettings;
    MyCalcArray: array of TCalcArray;
    MyCalcLength : integer;
    ArraysSizes: array of integer;
    ZeroDivide : Boolean;
    function GetPriority(Statement: string): integer;
    function ComputeCalcArray(InputArray : TCalcArray): Extended;
    function SetOperation(Operand1 : Extended; Operand2 : Extended; Operation : string): Extended;
    procedure MakeColoredEdit(re: TRichEdit);
    procedure SetResultColor();
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.MakeColoredEdit(re: TRichEdit);
begin
  SetWindowLong(re.Handle, GWL_STYLE,
                GetWindowLong(re.Handle, GWL_STYLE) and not ES_MULTILINE);
  re.WordWrap := False;
  re.WantReturns := False;
  re.Height := 21;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
 i, ArraysSizesLength, k: integer;
 NumberStr : string;
 CurArray : TCalcArray;
 value : Extended;
 a,b,c : string;
 v : integer;
begin
 ZeroDivide := false;
 if (Length(open_bracket) > 0) then
  begin
   ResultText.Font.Color := clRed;
   ResultText.Text :=  'Ошибка: есть незакрытые скобки';
   exit;
  end;
 if (Edit1.Text[Length(Edit1.Text)] in ['+', '-', '*', '/']) then
  begin
   ResultText.Font.Color := clRed;
   ResultText.Text :=  'Ошибка: входная строка заканчивается на оператор';
   exit;
  end;
 NumberStr := '';
 MyCalcLength := 1;
 SetLength(MyCalcArray, MyCalcLength);
 SetLength(ArraysSizes, MyCalcLength);
 ArraysSizes[MyCalcLength - 1] := 0;
 for i := 1 to Length(Edit1.Text) do
  begin
    if (Edit1.Text[i] in ['(', '{', '[']) then
     begin
      Inc(MyCalcLength);
      SetLength(MyCalcArray, MyCalcLength);
      SetLength(ArraysSizes, MyCalcLength);
      ArraysSizes[MyCalcLength - 1] := 0;
      NumberStr := '';
     end
    else if (Edit1.Text[i] in ['0'..'9']) then
     NumberStr := NumberStr + Edit1.Text[i]
    else if (Edit1.Text[i] in ['+', '-', '*', '/']) then
     begin
      if(MyCalcLength = 0) then
       begin
        Inc(MyCalcLength);
        SetLength(MyCalcArray, MyCalcLength);
        SetLength(ArraysSizes, MyCalcLength);
       end;
      if ((ArraysSizes[MyCalcLength - 1] > 0) and(MyCalcArray[MyCalcLength - 1][ArraysSizes[MyCalcLength - 1]-1].Operation = '')) then
        MyCalcArray[MyCalcLength - 1][ArraysSizes[MyCalcLength - 1]-1].Operation := Edit1.Text[i]
      else
       begin
        Inc(ArraysSizes[MyCalcLength - 1]);
        SetLength(MyCalcArray[MyCalcLength - 1], ArraysSizes[MyCalcLength - 1]);
        if (NumberStr <> '') then
         MyCalcArray[MyCalcLength - 1][ArraysSizes[MyCalcLength - 1]-1].FirstOperand := StrToFloat(NumberStr)
        else
         MyCalcArray[MyCalcLength - 1][ArraysSizes[MyCalcLength - 1]-1].FirstOperand := value;
        MyCalcArray[MyCalcLength - 1][ArraysSizes[MyCalcLength - 1]-1].Operation := Edit1.Text[i];
        MyCalcArray[MyCalcLength - 1][ArraysSizes[MyCalcLength - 1]-1].Priority := GetPriority(Edit1.Text[i]);
        MyCalcArray[MyCalcLength - 1][ArraysSizes[MyCalcLength - 1]-1].Deletet := false;
       end;
      NumberStr := '';
     end
    else if (Edit1.Text[i] in [')', '}', ']']) then
     begin
      if (NumberStr <> '') then
       begin
        Inc(ArraysSizes[MyCalcLength - 1]);
        SetLength(MyCalcArray[MyCalcLength - 1], ArraysSizes[MyCalcLength - 1] );
        MyCalcArray[MyCalcLength - 1][ArraysSizes[MyCalcLength - 1] - 1].FirstOperand := StrToFloat(NumberStr);
        MyCalcArray[MyCalcLength - 1][ArraysSizes[MyCalcLength - 1] - 1].Operation := '';
        MyCalcArray[MyCalcLength - 1][ArraysSizes[MyCalcLength - 1] - 1].Priority := 0;
        MyCalcArray[MyCalcLength - 1][ArraysSizes[MyCalcLength - 1] - 1].Deletet := false;
       end;
      NumberStr := '';
      value := ComputeCalcArray(MyCalcArray[MyCalcLength - 1]);
      if (ZeroDivide) then
        begin
         ResultText.Font.Color := clRed;
         ResultText.Text :=  'Ошибка - деление на ноль!';
         exit;
        end;
      Dec(MyCalcLength);
      SetLength(MyCalcArray, MyCalcLength);
      Inc(ArraysSizes[MyCalcLength - 1]);
      SetLength(MyCalcArray[MyCalcLength - 1], ArraysSizes[MyCalcLength - 1] );
      MyCalcArray[MyCalcLength - 1][ArraysSizes[MyCalcLength - 1] - 1].FirstOperand := value;
      MyCalcArray[MyCalcLength - 1][ArraysSizes[MyCalcLength - 1] - 1].Operation := '';
      MyCalcArray[MyCalcLength - 1][ArraysSizes[MyCalcLength - 1] - 1].Priority := 0;
      MyCalcArray[MyCalcLength - 1][ArraysSizes[MyCalcLength - 1] - 1].Deletet := false;
     end;
  end;
  if ((MyCalcLength = 0) or (ArraysSizes[MyCalcLength - 1] = 0)) then
   ResultText.Text := FloatToStr(value)
  else
   begin
    if (NumberStr <> '') then
     begin
      Inc(ArraysSizes[MyCalcLength - 1]);
      SetLength(MyCalcArray[MyCalcLength - 1], ArraysSizes[MyCalcLength - 1] );
      MyCalcArray[MyCalcLength - 1][ArraysSizes[MyCalcLength - 1] - 1].FirstOperand := StrToFloat(NumberStr);
      MyCalcArray[MyCalcLength - 1][ArraysSizes[MyCalcLength - 1] - 1].Operation := '';
      MyCalcArray[MyCalcLength - 1][ArraysSizes[MyCalcLength - 1] - 1].Priority := 0;
      MyCalcArray[MyCalcLength - 1][ArraysSizes[MyCalcLength - 1] - 1].Deletet := false;
     end;
    value := ComputeCalcArray(MyCalcArray[MyCalcLength - 1]);
    if (ZeroDivide) then
     begin
      ResultText.Font.Color := clRed;
      ResultText.Text :=  'Ошибка - деление на ноль!';
      exit;
     end
    else
     begin
      ResultText.Font.Color := clWindowText;
      ResultText.Text := FloatToStrF(value, ffNumber, 10, 2);
      SetResultColor();
     end;
   end;
end;

procedure TForm1.Edit1Change(Sender: TObject);
var
  i: integer;
  str, str1 : string;
begin
   str := '';
   open_bracket := '';
   for i := 1 to Length(Edit1.Text) do
    begin
     str1 := '';
     if (Edit1.Text[i] in ['0'..'9', '(', ')', '{', '}', '[', ']', '+', '-', '*', '/'])
       then str1 := Edit1.Text[i];
     if (Edit1.Text[i] in ['(', '{', '[']) then open_bracket := open_bracket + Edit1.Text[i];
     if (Edit1.Text[i] in [')', '}', ']']) then
      begin
       if (Length(open_bracket) = 0) then str1 := ''
       else if ((Edit1.Text[i] = ')') and (open_bracket[Length(open_bracket)] <> '(')) then str1 := ''
       else if ((Edit1.Text[i] = '}') and (open_bracket[Length(open_bracket)] <> '{')) then str1 := ''
       else if ((Edit1.Text[i] = ']') and (open_bracket[Length(open_bracket)] <> '[')) then str1 := ''
       else
        begin
          str1 := Edit1.Text[i];
          SetLength(open_bracket, Length(open_bracket) - 1);
        end;
      end;
     if ((Edit1.Text[i] in ['(', '{', '[']) and (Edit1.Text[i-1] in [')', '}', ']']))
      then str1 := '';
     if ((Edit1.Text[i] in ['(', '{', '[']) and (Edit1.Text[i-1] in ['0'..'9']))
      then str1 := '';
     if ((Edit1.Text[i -1] in [')', '}', ']']) and (Edit1.Text[i] in ['0'..'9']))
      then str1 := '';
     str := str + str1;
    end;
   Edit1.Text := str;
   Edit1.SelStart:=Length(Edit1.Text);
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
 MakeColoredEdit(ResultText);
 WorkSettings := TFormatSettings.Create;
 WorkSettings.ThousandSeparator := ' ';
 WorkSettings.DecimalSeparator := ',';
end;

function TForm1.GetPriority(Statement: string): integer;
begin
 if ((Statement = '+')or (Statement= '-')) then result := 1;
 if ((Statement = '*')or(Statement = '/')) then result := 2;
end;

procedure TForm1.SetResultColor();
 var
  i: integer;
  Color: TColor;
  Color1: TColor;
  Color2: TColor;
  Color3: TColor;
  a : string;
begin
  Color1 := clLime;
  Color2 := clBlue;
  Color3 := clFuchsia;
  if not(ZeroDivide) then
   begin
    ResultText.SelStart := 0;
    Color := Color1;
    for i := 1 to Length(ResultText.Text) do
     begin
      a := ResultText.Text[i];
      if (a = ' ') then
       begin
        ResultText.SelLength := i-1 - ResultText.SelStart;
        ResultText.SelAttributes.Color := Color;
        ResultText.SelStart := i;
        if (Color = Color1) then Color := Color2
        else if (Color = Color2) then Color := Color1
       end
      else if (ResultText.Text[i] = ',') then
       begin
        ResultText.SelLength := i-1 - ResultText.SelStart;
        ResultText.SelAttributes.Color := Color;
        ResultText.SelStart := i;
        ResultText.SelLength := Length(ResultText.Text) - i;
        ResultText.SelAttributes.Color := Color3;
       end;
     end;
   end;
end;

function TForm1.ComputeCalcArray(InputArray : TCalcArray): Extended;
var
   i : integer;
   ResultArray : TCalcArray;
   ResultArrayLenght : integer;
begin
  result := 0;
  ResultArrayLenght := 0;
  for i := 0 to (Length(InputArray) - 1) do
   begin
    if InputArray[i].Priority = 2 then
     begin
      InputArray[i].Deletet := true;
      InputArray[i+1].FirstOperand := SetOperation(InputArray[i].FirstOperand, InputArray[i+1].FirstOperand, InputArray[i].Operation);
      if (ZeroDivide) then
       begin
        result := 0;
        exit;
       end;
     end
   end;
  for i := 0 to (Length(InputArray) - 1) do
   begin
    if (InputArray[i].Deletet = false) then
     begin
      Inc(ResultArrayLenght);
      SetLength(ResultArray, ResultArrayLenght);
      ResultArray[ResultArrayLenght - 1].FirstOperand := InputArray[i].FirstOperand;
      ResultArray[ResultArrayLenght - 1].Operation := InputArray[i].Operation;
      ResultArray[ResultArrayLenght - 1].Priority :=  InputArray[i].Priority;
      ResultArray[ResultArrayLenght - 1].Deletet := InputArray[i].Deletet;
     end;
   end;
  if (ResultArrayLenght > 1) then
   begin
    for i := 0 to (ResultArrayLenght - 2) do
     begin
      if (ResultArray[i].Operation <> '') then
       ResultArray[i+1].FirstOperand := SetOperation(ResultArray[i].FirstOperand, ResultArray[i+1].FirstOperand, ResultArray[i].Operation);
     end;
   end;
 result := ResultArray[ResultArrayLenght - 1].FirstOperand;
end;

function TForm1.SetOperation(Operand1 : Extended; Operand2 : Extended; Operation : string): Extended;
 begin
   if (Operation = '+') then result := Operand1 + Operand2
   else if (Operation = '') then result := Operand1 + Operand2
   else if (Operation = '-') then result := Operand1 - Operand2
   else if (Operation = '*') then result := Operand1 * Operand2
   else if (Operation = '/') then
    begin
     if (Operand2 = 0) then
      begin
       ZeroDivide := true;
       result := 0;
       exit;
      end;
     result := Operand1 / Operand2;
    end;
 end;

end.
