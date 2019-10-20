unit uFrmCadastro;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ACBrBase, ACBrMail, ComCtrls, inifiles, Mask,
  ExtCtrls, DB, RxMemDS, XMLDoc, XMLIntf, IdHTTP, TypInfo;

type
  TFrmCadastro = class(TForm)
    ACBrMail1: TACBrMail;
    pgc: TPageControl;
    tsMensagem: TTabSheet;
    Label2: TLabel;
    Label6: TLabel;
    Label3: TLabel;
    lblAdressName: TLabel;
    edSubject: TEdit;
    edtAddressEmail: TEdit;
    mAltBody: TMemo;
    edtAddressName: TEdit;
    tsCadastro: TTabSheet;
    pnl1: TPanel;
    Label1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl4: TLabel;
    dbedtNome: TMaskEdit;
    dbedtIdentidade: TMaskEdit;
    dbedtCPF: TMaskEdit;
    dbedtEmail: TMaskEdit;
    grp1: TGroupBox;
    lbl10: TLabel;
    lbl11: TLabel;
    lbl12: TLabel;
    lbl5: TLabel;
    lbl6: TLabel;
    lbl7: TLabel;
    lbl8: TLabel;
    lbl9: TLabel;
    dbedtBairro: TMaskEdit;
    dbedtCEP: TMaskEdit;
    dbedtCidade: TMaskEdit;
    dbedtComplemento: TMaskEdit;
    dbedtEstado: TMaskEdit;
    dbedtLogradouro: TMaskEdit;
    dbedtNumero: TMaskEdit;
    dbedtPais: TMaskEdit;
    Panel1: TPanel;
    Button2: TButton;
    Button3: TButton;
    Panel2: TPanel;
    btnSalvar: TButton;
    btnEnvio: TButton;
    lblFrom: TLabel;
    lblFromName: TLabel;
    edtFromName: TEdit;
    edtFrom: TEdit;
    lblHost: TLabel;
    edtHost: TEdit;
    edtPort: TEdit;
    lblPort: TLabel;
    lblTipoAutenticacao: TLabel;
    chkTLS: TCheckBox;
    chkSSL: TCheckBox;
    lblUser: TLabel;
    lblPassword: TLabel;
    edtUser: TEdit;
    edtPassword: TEdit;
    chkMostraSenha: TCheckBox;
    lblDefaultCharset: TLabel;
    lbl1: TLabel;
    cbbDefaultCharset: TComboBox;
    cbbIdeCharSet: TComboBox;
    btnSalvarConfig: TButton;
    jvm1: TRxMemoryData;
    jvm1Nome: TStringField;
    jvm1Identidade: TStringField;
    jvm1CPF: TStringField;
    jvm1Email: TStringField;
    jvm1CEP: TStringField;
    jvm1Logradouro: TStringField;
    jvm1Numero: TIntegerField;
    jvm1Complemento: TStringField;
    jvm1Bairro: TStringField;
    jvm1Cidade: TStringField;
    jvm1Estado: TStringField;
    jvm1Pais: TStringField;
    stQtdRegMemoria: TStaticText;
    pnlWait: TPanel;
    procedure bEnviarClick(Sender: TObject);
    procedure btnEnvioClick(Sender: TObject);
    procedure btnSalvarConfigClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure dbedtCEPExit(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure dbedtCPFExit(Sender: TObject);
    procedure dbedtEmailExit(Sender: TObject);
    procedure edtFromExit(Sender: TObject);
    procedure edtAddressEmailExit(Sender: TObject);
    procedure chkMostraSenhaClick(Sender: TObject);
  private
    { Private declarations }
    procedure GravaParamsEmail;
    procedure AjustaParametrosDeEnvio;
    function ValidaCampo: Boolean;
    function ValidaConfiguracaoEmail: Boolean;
    procedure AbrirConfigracaoDefault;
    procedure LimpaCampos;
  public
    { Public declarations }
  end;

var
  FrmCadastro: TFrmCadastro;

implementation

uses AuxLib, uEnderecoJSON, uLkJSON, uValidarPCF;

const
  _sEmailInvalido = 'Endereço de email inválido.';
  _sCPFInvalido = 'CPF Inválido';

{$R *.dfm}

procedure TFrmCadastro.bEnviarClick(Sender: TObject);
var
  Dir, ArqXML: string;
  MS: TMemoryStream;
  P, N: Integer;
begin

  Dir := ExtractFilePath(ParamStr(0));

  P := pos(' - ', edSubject.Text);
  if P > 0 then
  begin
    N := StrToIntDef(copy(edSubject.Text, P + 3, 5), 0) + 1;
    edSubject.Text := copy(edSubject.Text, 1, P + 2) + IntToStr(N);
  end;

  AjustaParametrosDeEnvio;

  ACBrMail1.Clear;
  ACBrMail1.IsHTML := False;
  ACBrMail1.Subject := edSubject.Text;

  ACBrMail1.AltBody.Assign(mAltBody.Lines);

  MS := TMemoryStream.Create;
  try
    ArqXML := '.xml';
    MS.LoadFromFile(ArqXML);
    ACBrMail1.AddAttachment(MS, ArqXML);
  finally
    MS.Free;
  end;

  ACBrMail1.Send(False);

end;

procedure TFrmCadastro.GravaParamsEmail;
var
  IniFile: string;
  Ini: TIniFile;
begin
  IniFile := ChangeFileExt(Application.ExeName, '.ini');
  Ini := TIniFile.Create(IniFile);
  try
    Ini.WriteString('Email', 'From', edtFrom.text);
    Ini.WriteString('Email', 'FromName', edtFromName.text);
    Ini.WriteString('Email', 'Host', edtHost.text);
    Ini.WriteString('Email', 'Port', edtPort.text);
    Ini.WriteString('Email', 'User', edtUser.text);
    Ini.WriteString('Email', 'Pass', edtPassword.text);
    Ini.WriteBool('Email', 'TLS', chkTLS.Checked);
    Ini.WriteBool('Email', 'SSL', chkSSL.Checked);
    Ini.WriteInteger('Email', 'DefaultCharset', cbbDefaultCharset.ItemIndex);
    Ini.WriteInteger('Email', 'IdeCharset', cbbIdeCharSet.ItemIndex);
  finally
    Ini.Free;
  end;
end;

procedure TFrmCadastro.AjustaParametrosDeEnvio;
begin
  ACBrMail1.From := edtFrom.text;
  ACBrMail1.FromName := edtFromName.text;
  ACBrMail1.Host := edtHost.text;
  ACBrMail1.Username := edtUser.text;
  if (not chkMostraSenha.Checked) then
    edtPassword.PasswordChar := '#'
  else
    edtPassword.PasswordChar := #0;
  ACBrMail1.Password := edtPassword.Text;
  ACBrMail1.Port := edtPort.text;
  ACBrMail1.SetTLS := chkTLS.Checked;
  ACBrMail1.SetSSL := chkSSL.Checked;
  ACBrMail1.DefaultCharset := TMailCharset(cbbDefaultCharset.ItemIndex);
  ACBrMail1.IDECharset := TMailCharset(cbbIdeCharSet.ItemIndex);
  ACBrMail1.AddAddress(edtAddressEmail.text, edtAddressName.text);
end;


procedure TFrmCadastro.btnEnvioClick(Sender: TObject);
var
  Dir, ArqXML: string;
  MS: TMemoryStream;
  P, N: Integer;

  XMLDocument: TXMLDocument;
  NodeTbl,
  NodeRegistro: IXMLNode;
  I: Integer;
begin
  if (not ValidaConfiguracaoEmail) then
  begin
    pgc.ActivePage := tsMensagem;
    ShowMessage('Configure os dados para envio do email.');
    exit;
  end;

  Dir := ExtractFilePath(ParamStr(0));

  XMLDocument := TXMLDocument.Create(Self);
  try
    XMLDocument.Active := True;
    NodeTbl := XMLDocument.AddChild('Cadastro');
    jvm1.First;
    while not jvm1.Eof do
    begin
      NodeRegistro := NodeTbl.AddChild('Informacoes');
      for I := 1 To 11 do
      begin
        NodeRegistro.ChildValues[Copy(jvm1.Fields[i].Name, 5, Length(jvm1.Fields[i].Name))] := jvm1.Fields[i].Value;
      end;
      jvm1.Next;
    end;
    XMLDocument.SaveToFile(Dir+'Cadastro.xml');
  finally
    XMLDocument.Free;
  end;

  P := pos(' - ', edSubject.Text);
  if P > 0 then
  begin
    N := StrToIntDef(copy(edSubject.Text, P + 3, 5), 0) + 1;
    edSubject.Text := copy(edSubject.Text, 1, P + 2) + IntToStr(N);
  end;

  ACBrMail1.Clear;
  ACBrMail1.IsHTML := False;
  ACBrMail1.Subject := edSubject.Text;

  AjustaParametrosDeEnvio;

  ACBrMail1.AltBody.Assign(mAltBody.Lines);

  MS := TMemoryStream.Create;
  try
    ArqXML := Dir+'Cadastro.xml';
    MS.LoadFromFile(ArqXML);
    ACBrMail1.AddAttachment(MS, ArqXML);
  finally
    MS.Free;
  end;
  pnlWait.Align := alClient;
  try
    pnlWait.Visible := true;
    Application.ProcessMessages;
    ACBrMail1.Send(False);
  finally
    pnlWait.Visible := False;
    pnlWait.Align := alNone;
  end;

end;

procedure TFrmCadastro.btnSalvarConfigClick(Sender: TObject);
begin
  GravaParamsEmail;
  AjustaParametrosDeEnvio
end;

procedure TFrmCadastro.LimpaCampos;
var
  j: Integer;
  oCampo: TComponent;
begin
  for j := 0 to ComponentCount -1 do
  begin
    if (Components[j] is TMaskEdit) then
    begin
      oCampo := FindComponent((Components[j] as TMaskEdit).Name);
      (oCampo as TMaskEdit).Clear;
    end;
  end;

end;

function TFrmCadastro.ValidaCampo: Boolean;
var
  j: Integer;
  oCampo: TComponent;
  sValue: string;
begin

  Result := True;
  for j := 0 to ComponentCount -1 do
  begin
    if (Components[j] is TMaskEdit) then
    begin
      oCampo := FindComponent((Components[j] as TMaskEdit).Name);
      sValue := Trim((oCampo as TMaskEdit).Text);
      if ((sValue = EmptyStr) and (StrToIntDef(sValue, 0) = 0)) or
         ((sValue = '_____-___') or (sValue = '___.___.___-__')) then
      begin
        ShowMessage('Valor inválido para o campo: ' + Copy((oCampo as TMaskEdit).Name, 6, Length((oCampo as TMaskEdit).Name)));
        (oCampo as TMaskEdit).SetFocus;
        Result := False;
        Break;
      end;
    end;
  end;

end;

procedure TFrmCadastro.btnSalvarClick(Sender: TObject);
var
  i,j: Integer;
  oCampo: TComponent;
begin
  if not ValidaCampo then
  begin
    Exit;
  end;

  jvm1.Append;
  for I := 0  To jvm1.Fields.Count -1 do
  begin
    for j := 0 to ComponentCount -1 do
    begin
      if (Components[j] is TMaskEdit) and (jvm1.Fields[i].Tag = i + 1) then
      begin
        oCampo := (FindComponent('dbedt'+jvm1.Fields[i].FieldName));
        jvm1.Fields[i].Value := (oCampo as TMaskEdit).Text;
        Break;
      end;
    end;
  end;
  jvm1.Post;
  LimpaCampos;
  dbedtNome.SetFocus;
  btnEnvio.Enabled := (not jvm1.IsEmpty);
  stQtdRegMemoria.Caption := format('Qtde de registros em memória: %d', [jvm1.RecordCount]);
end;

procedure TFrmCadastro.dbedtCEPExit(Sender: TObject);
var
  _rEndereco: TEndereco;
  sCEP: string;
begin
  //valida se esta diferente de vazio
  if (Trim(dbedtCEP.Text) <> EmptyStr) then
  begin
    sCEP := getnumero(dbedtCEP.Text);
    //valida se o tamanho esta correto sem maracara
    if (Length(sCEP) <> 8) then
    begin
      ShowMessage('CEP inválido.');
      dbedtCEP.SetFocus;
      Exit;
    end;

    _rEndereco := TEndereco.Create(sCEP);
    try
      dbedtLogradouro.Text  := _rEndereco.Logradouro;
      dbedtCidade.Text      := _rEndereco.localidade;
      dbedtComplemento.Text := _rEndereco.complemento;
      dbedtEstado.Text      := _rEndereco.uf;
    finally
      _rEndereco.Free;
    end;
  end;
end;

function TFrmCadastro.ValidaConfiguracaoEmail: Boolean;
begin
  result := (ACBrMail1.From <> EmptyStr)
        and (ACBrMail1.FromName <> EmptyStr)
        and (ACBrMail1.Host <> EmptyStr)
        and (ACBrMail1.Username <> EmptyStr)
        and (ACBrMail1.Password <> EmptyStr)
        and (ACBrMail1.Port <> EmptyStr)
        and (edtAddressEmail.text <> EmptyStr);
end;

procedure TFrmCadastro.FormCreate(Sender: TObject);
var
  m: TMailCharset;
begin
  jvm1.EmptyTable;
  jvm1.Active := true;

  cbbDefaultCharset.Items.Clear;
  for m := Low(TMailCharset) to High(TMailCharset) do
    cbbDefaultCharset.Items.Add(GetEnumName(TypeInfo(TMailCharset), integer(m)));
  cbbDefaultCharset.ItemIndex := 0;
  cbbIdeCharSet.Items.Assign(cbbDefaultCharset.Items);
  cbbIdeCharSet.ItemIndex := 0;
  AbrirConfigracaoDefault;
end;

procedure TFrmCadastro.dbedtCPFExit(Sender: TObject);
begin
  if (not isCPF(RemoveCaracteres(RemoveCaracteres(dbedtCPF.Text,'-', ''),'-', ''))) then
  begin
    ShowMessage(_sCPFInvalido);
    dbedtCPF.SetFocus;
  end;
end;

procedure TFrmCadastro.dbedtEmailExit(Sender: TObject);
begin
  if (not ValidarEMail(dbedtEmail.Text)) then
  begin
    ShowMessage(_sEmailInvalido);
    dbedtEmail.SetFocus;
  end;
end;

procedure TFrmCadastro.edtFromExit(Sender: TObject);
begin
  if (not ValidarEMail(edtFrom.Text)) then
  begin
    ShowMessage(_sEmailInvalido);
    edtFrom.SetFocus;
  end;

end;

procedure TFrmCadastro.edtAddressEmailExit(Sender: TObject);
begin
  if (not ValidarEMail(edtAddressEmail.Text)) then
  begin
    ShowMessage(_sEmailInvalido);
    edtAddressEmail.SetFocus;
  end;
end;

procedure TFrmCadastro.AbrirConfigracaoDefault;
var
  IniFile: string;
  Ini: TIniFile;
begin
  IniFile := ChangeFileExt(Application.ExeName, '.ini');
  Ini := TIniFile.Create(IniFile);
  try
    edtFrom.text := Ini.ReadString('Email', 'From', '');
    edtFromName.text := Ini.ReadString('Email', 'FromName', '');
    edtHost.text := Ini.ReadString('Email', 'Host', '');
    edtPort.text := Ini.ReadString('Email', 'Port', '25');
    edtUser.text := Ini.ReadString('Email', 'User', '');
    edtPassword.text := Ini.ReadString('Email', 'Pass', '');
    chkTLS.Checked := Ini.ReadBool('Email', 'TLS', StrToBoolDef('0', False));
    chkSSL.Checked := Ini.ReadBool('Email', 'SSL', StrToBoolDef('0', False));
    cbbDefaultCharset.ItemIndex := Ini.ReadInteger('Email', 'DefaultCharset', -1);
    cbbIdeCharSet.ItemIndex := Ini.ReadInteger('Email', 'IdeCharset', -1);
  finally
    Ini.Free;
  end;
end;

procedure TFrmCadastro.chkMostraSenhaClick(Sender: TObject);
begin
  if chkMostraSenha.Checked then
    edtPassword.PasswordChar := #0
  else
    edtPassword.PasswordChar := '#';
end;

end.
