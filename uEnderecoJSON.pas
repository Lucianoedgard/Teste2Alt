unit uEnderecoJSON;

interface

uses
  SysUtils, IdHTTP, variants;

type
  TEndereco = class (TObject)
    Fcep : string;
    Flogradouro : string;
    Fcomplemento : string;
    Fbairro : string;
    Flocalidade : string;
    Fuf : string;
    Funidade : string;
    Fibge : string;
    Fgia : string;

  private
    procedure proLocalizaCep;
  public
    constructor Create(const Cep: string); overload;
    property cep : string read Fcep;
    property logradouro : string read Flogradouro;
    property complemento : string read Fcomplemento;
    property bairro : string read Fbairro;
    property localidade : string read Flocalidade;
    property uf : string read Fuf;
    property unidade : string read Funidade;
    property ibge : string read Fibge;
    property gia : string read Fgia;
  end;

implementation

uses uLkJSON;

{ TEndereco }

constructor TEndereco.Create(const Cep: string);
begin
  FCep := Cep;
  proLocalizaCep;
end;

procedure TEndereco.proLocalizaCep;
resourcestring
  __rINFORME_NR_CEP = 'Informe o número do cep.';
  __rCEP_INVALIDO = 'O número do CEP deve ser composto por 8 bytes.';
  __rCEP_NAO_ENCONTRADO = 'Cep não encontrado.';
const
  _rcep = 'cep';
  _rlogradouro = 'logradouro';
  _rcomplemento = 'complemento';
  _rbairro = 'bairro';
  _rlocalidade = 'localidade';
  _ruf = 'uf';
  _runidade = 'unidade';
  _ribge = 'ibge';
  _rgia = 'gia';
  _rWS = 'https://viacep.com.br/ws/';
  _rJSON = '/json/';
  _rERRO = 'erro';
  _rTrue = 'true';
var
  _rDJSON: TIdHTTP;
  jsonStringData : String;
  js:TlkJSONobject;
begin
  FCep := StringReplace(Cep, '-', '', [rfReplaceAll]);
  if Cep = EmptyStr then
    raise Exception.Create(__rINFORME_NR_CEP);

  if Length(Cep) <> 8 then
    raise Exception.Create(__rCEP_INVALIDO);


  _rDJSON := TIdHTTP.Create(nil);
  try
    jsonStringData := _rDJSON.get(Format('http://viacep.com.br/ws/%s/json/',[Fcep]));
  finally
    _rDJSON.Free;
  end;

  js := TlkJSON.ParseText(jsonStringData) as TlkJSONobject;

  try
    //Caso o CEP retornado não tenha sido identificado
    if js.Field[_rERRO] is TlkJSONboolean then
      if js.Field[_rERRO].Value = _rTrue then
        raise Exception.Create(__rCEP_NAO_ENCONTRADO);


    fcep         := vartostr(js.Field[_rcep].Value);
    flogradouro  := vartostr(js.Field[_rlogradouro].Value);
    fcomplemento := vartostr(js.Field[_rcomplemento].Value);
    fbairro      := vartostr(js.Field[_rbairro].Value);
    flocalidade  := vartostr(js.Field[_rlocalidade].Value);
    fuf          := vartostr(js.Field[_ruf].Value);
    funidade     := vartostr(js.Field[_runidade].Value);
    fibge        := vartostr(js.Field[_ribge].Value);
    fgia         := vartostr(js.Field[_rgia].Value);
  finally
    js := nil;
  end;
end;

end.
