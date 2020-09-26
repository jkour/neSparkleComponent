unit MainUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Edit, FMX.ExtCtrls,
  neSparkle, FMX.Layouts;

type
  TForm4 = class(TForm)
    Circle1: TCircle;
    Label1: TLabel;
    CheckBox1: TCheckBox;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Label3: TLabel;
    efURL: TEdit;
    Button4: TButton;
    Button5: TButton;
    Edit2: TEdit;
    Label4: TLabel;
    Edit3: TEdit;
    Label5: TLabel;
    Button6: TButton;
    Button7: TButton;
    Edit4: TEdit;
    Label6: TLabel;
    Button8: TButton;
    Label7: TLabel;
    Edit5: TEdit;
    Label8: TLabel;
    PopupBox1: TPopupBox;
    Button9: TButton;
    GroupBox1: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    Label9: TLabel;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    Label10: TLabel;
    Rectangle1: TRectangle;
    GroupBox2: TGroupBox;
    Label2: TLabel;
    Layout1: TLayout;
    rbUseWeb: TRadioButton;
    rbUseLocalCorrect: TRadioButton;
    rbUseLocalWrong: TRadioButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure rbUseLocalCorrectChange(Sender: TObject);
    procedure rbUseLocalWrongChange(Sender: TObject);
    procedure rbUseWebChange(Sender: TObject);
  private
    fMainWinSparkle: TneSparkle;
    procedure ToggleControls (const newState: Boolean);
    procedure SetupGUI;
    procedure UpdateFound;
    procedure UpdateError;
    procedure UpdateShutDown;
    procedure UpdateNotFound;
    procedure UpdateCancelled;
    function UpdateCanShutdown: Boolean;
    procedure InitialiseSparkle;
  public
    fPubPem: string;
  end;

var
  Form4: TForm4;

implementation

uses
	System.UIConsts, System.IOUtils;

{$R *.fmx}

const
  web_xml = 'https://winsparkle.org/example/appcast.xml';
  local_xml = 'http://localhost:7777/appcast.xml';
  local_wrong_xml = 'http://localhost:7777/appcast-wrong.xml';

procedure TForm4.Button1Click(Sender: TObject);
begin
  if fMainWinSparkle.AutoCheckForUpdates then
    ShowMessage('yes')
  else
    ShowMessage('no');
end;

procedure TForm4.Button2Click(Sender: TObject);
begin
  Rectangle1.Visible:=false;
  CheckBox2.IsChecked:=False;
  CheckBox3.IsChecked:=false;
  CheckBox4.IsChecked:=false;
  CheckBox5.IsChecked:=false;
  if RadioButton1.IsChecked then
    fMainWinSparkle.CheckUpdate(TUpdateType.utWithUI);
  if RadioButton2.IsChecked then
    fMainWinSparkle.CheckUpdate(TUpdateType.utWithUIAndInstall);
  if RadioButton3.IsChecked then
    fMainWinSparkle.CheckUpdate(TUpdateType.utWithoutUI);
end;

procedure TForm4.Button3Click(Sender: TObject);
begin
  Label2.Text:=FormatDateTime('DD/MM/YYYY HH:MM:SS', fMainWinSparkle.LastCheckTime);
end;

procedure TForm4.Button4Click(Sender: TObject);
begin
  fMainWinSparkle.AppcastURL:=efURL.Text;
end;

procedure TForm4.Button5Click(Sender: TObject);
begin
  fMainWinSparkle.AppBuildVersion:=Edit2.Text;
end;

procedure TForm4.Button6Click(Sender: TObject);
begin
  fMainWinSparkle.SetAppDetails('JK','Delphi WinSparkle',Edit3.text);
end;

procedure TForm4.Button7Click(Sender: TObject);
begin
  fMainWinSparkle.RegistryPath:=Edit4.Text;
end;

procedure TForm4.Button8Click(Sender: TObject);
begin
  fMainWinSparkle.UpdateCheckInterval:=Edit5.Text.ToInteger;
  ShowMessage('New Update Interval: '+fMainWinSparkle.UpdateCheckInterval.ToString);
end;

procedure TForm4.Button9Click(Sender: TObject);
begin
  if PopupBox1.Text<>'' then
  begin
    fMainWinSparkle.SetLang(Trim(PopupBox1.Text));
    fMainWinSparkle.Cleanup;
    InitialiseSparkle;
  end;
end;

procedure TForm4.CheckBox1Change(Sender: TObject);
begin
  fMainWinSparkle.AutoCheckForUpdates:=CheckBox1.IsChecked;
end;

procedure TForm4.FormCreate(Sender: TObject);
var
  path: string;
begin
{$IFDEF WIN32}
  path:='..\..\..\Libraries\v.'+WinSparkleVersion+'\Win32';
{$ENDIF}
{$IFDEF WIN64}
  path:='..\..\..\Libraries\v.'+WinSparkleVersion+'\Win64';
{$ENDIF}
  fMainWinSparkle:=TneSparkle.Create(path);
  SetupGui;
  if fMainWinSparkle.DLLLoaded then
  begin
    ToggleControls(true);
    Circle1.Fill.Color:=claGreen;
    Label1.Text:='DLL Loaded';

    InitialiseSparkle;

    CheckBox1.IsChecked:=fMainWinSparkle.AutoCheckForUpdates;
    Edit3.Text:='1.2.0';
    Edit4.Text:=fMainWinSparkle.RegistryPath;
    Edit5.Text:=fMainWinSparkle.UpdateCheckInterval.ToString;

    Button4Click(Button4);

  end
  else
  begin
    ToggleControls(false);
    Circle1.Fill.Color:=claRed;
    Label1.Text:='DLL Not Loaded';
  end;

  fPubPem:=TFile.ReadAllText('..\..\AppCast\keys\dsa_pub.pem');
end;

procedure TForm4.FormDestroy(Sender: TObject);
begin
  fMainWinSparkle.Free;
end;

procedure TForm4.SetupGUI;
begin
  PopupBox1.Items.Clear;
  PopupBox1.Items.Add('ar');
  PopupBox1.Items.Add('bg');
  PopupBox1.Items.Add('bs');
  PopupBox1.Items.Add('ca_ES');
  PopupBox1.Items.Add('co');
  PopupBox1.Items.Add('cs');
  PopupBox1.Items.Add('da');
  PopupBox1.Items.Add('de');
  PopupBox1.Items.Add('el');
  PopupBox1.Items.Add('es');
  PopupBox1.Items.Add('eu');
  PopupBox1.Items.Add('fr');
  PopupBox1.Items.Add('fy_NL');
  PopupBox1.Items.Add('he');
  PopupBox1.Items.Add('hr');
  PopupBox1.Items.Add('hu');
  PopupBox1.Items.Add('hy');
  PopupBox1.Items.Add('id');
  PopupBox1.Items.Add('it');
  PopupBox1.Items.Add('ja');
  PopupBox1.Items.Add('ko');
  PopupBox1.Items.Add('nb');
  PopupBox1.Items.Add('nl');
  PopupBox1.Items.Add('pl');
  PopupBox1.Items.Add('pt_BR');
  PopupBox1.Items.Add('pt_PT');
  PopupBox1.Items.Add('ru');
  PopupBox1.Items.Add('sk');
  PopupBox1.Items.Add('sr');
  PopupBox1.Items.Add('sv');
  PopupBox1.Items.Add('tr');
  PopupBox1.Items.Add('uk');
  PopupBox1.Items.Add('zh_CN');
  PopupBox1.Items.Add('zh_TW');

  RadioButton1.IsChecked:=True;
  Rectangle1.Visible:=false;
end;

procedure TForm4.ToggleControls(const newState: Boolean);
begin
  GroupBox2.Enabled:=newState;
end;

procedure TForm4.UpdateCancelled;
begin
  Rectangle1.Visible:=True;
end;

function TForm4.UpdateCanShutdown: Boolean;
begin
  result:=true;
end;

procedure TForm4.InitialiseSparkle;
begin
  fMainWinSparkle.SetAppDetails('JK', 'Delphi WinSparkle', '1.2.0');
  fMainWinSparkle.OnDidFindUpdate := UpdateFound;
  fMainWinSparkle.OnError := UpdateError;
  fMainWinSparkle.OnShutDown := UpdateShutDown;
  fMainWinSparkle.OnDidNotFindUpdate := UpdateNotFound;
  fMainWinSparkle.OnUpdateCancelled := UpdateCancelled;
  fMainWinSparkle.OnCanShutDown := UpdateCanShutdown;
  fMainWinSparkle.Init;
end;

procedure TForm4.rbUseLocalCorrectChange(Sender: TObject);
begin
  efURL.Text:=local_xml;
  fMainWinSparkle.DSAPublicPem:=fPubPem;
  Button4Click(Sender);
end;

procedure TForm4.rbUseLocalWrongChange(Sender: TObject);
begin
  efURL.Text:=local_wrong_xml;
  fMainWinSparkle.DSAPublicPem:=fPubPem;
  Button4Click(Sender);
end;

procedure TForm4.rbUseWebChange(Sender: TObject);
begin
  efURL.Text:=web_xml;
  fMainWinSparkle.DSAPublicPem:='';
  Button4Click(Sender);
end;

procedure TForm4.UpdateError;
begin
  CheckBox3.IsChecked:=true;
end;

procedure TForm4.UpdateFound;
begin
  CheckBox2.IsChecked:=true;
end;

procedure TForm4.UpdateNotFound;
begin
  CheckBox5.IsChecked:=true;
end;

procedure TForm4.UpdateShutDown;
begin
  CheckBox4.IsChecked:=true;
end;

end.
