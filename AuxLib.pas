unit AuxLib;

interface

uses SysUtils;

  function GetNumero(Texto: string):string;
  function RemoveCaracteres(psValue,psLocaliza,psTroca: string): string;
  function ValidarEMail(aStr: string): Boolean;


implementation

function RemoveCaracteres(psValue,psLocaliza,psTroca: string): string;
const
  sMethodName = 'uLibAux.TrocaCaracter';
var
  sValue : string;
begin
  Result := '';
  sValue := StringReplace(psValue,psLocaliza,psTroca,[rfReplaceAll]);
  Result := sValue
end;

function GetNumero(Texto: string):string;
const
  sMethodName = 'HeNumero';
var Resultado:string;
    nContador:Integer;
begin
  Resultado := '';
  For nContador:=1 to Length(Texto) do
  begin
    {Verifica sé é uma letra ou algum caracter}
    if Texto[nContador] in ['1','2','3','4','5','6','7','8','9','0'] then
      Resultado := Resultado + Texto[nContador];
  end;
  Result:=Resultado;
end;

function ValidarEMail(aStr: string): Boolean;
begin
 aStr := Trim(UpperCase(aStr));
 if Pos('@', aStr) > 1 then
 begin
   Delete(aStr, 1, pos('@', aStr));
   Result := (Length(aStr) > 0) and (Pos('.', aStr) > 2);
 end
 else
   Result := False;
end;
end. 
