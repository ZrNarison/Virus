unit Verrouilleur ;

interface

Uses Classes, Windows ;

type
  TVerrous = set of
  ( vAltEsc
  , vAltTab
  , vCtrlEsc
  , vCtrlAltSup
  , vBarreDesTaches
  , vTouchesMicrosoft
  ) ;

  TVerrouilleur = class ( TComponent )
  private
    FVerrous                  : TVerrous ;
    FVerrouillageBarreDesTaches : Boolean    ;
    FVerrouillageTotal          : Boolean    ;

    procedure SetVerrouillageCtrlAltSup       ( const Value : boolean    ) ;
    procedure SetVerrouillageAltTab           ( const Value : boolean    ) ;
    procedure SetVerrouillageCtrlEsc          ( const Value : boolean    ) ;
    procedure SetVerrouillageAltEsc           ( const Value : boolean    ) ;
    procedure SetVerrouillageBarreDesTaches   ( const Value : boolean    ) ;
    procedure SetVerrouillageTouchesMicrosoft ( const Value : boolean    ) ;
    procedure SetActif                        ( const Value : boolean    ) ;
    procedure SetVerrouillageTotal            ( const Value : boolean    ) ;
    procedure SetVerrous                      ( const Value : TVerrous   ) ;

    function  GetActif : Boolean ;

    procedure MiseAJourVerrous ;

    procedure InstallationDuHook ;
    procedure RetraitDuHook ;

  public
    constructor Create(AOwner: TComponent); override ;
    destructor Destroy ; override ;

    procedure      FreeInstance           ; override ;
    class function  NewInstance : TObject ; override ;

  published
    property    Verrous : TVerrous
      read     FVerrous
      write  SetVerrous
    ;

    property    VerrouillageTotal : Boolean
      read     FVerrouillageTotal
      write  SetVerrouillageTotal
    ;

    property    Actif : Boolean
      read   GetActif
      write  SetActif
    ;

  end ;

procedure Register;

implementation

uses Registry, SysUtils ;

// --------------------------------------------------------------------------------------------- //
// ----- Variables globales -------------------------------------------------------------------- //
// --------------------------------------------------------------------------------------------- //
var
  GActif                        : Boolean ;
  GVerrouillageCtrlEsc          : Boolean ;
  GVerrouillageAltTab           : Boolean ;
  GVerrouillageAltEsc           : Boolean ;
  GVerrouillageTouchesMicrosoft : Boolean ;

// --------------------------------------------------------------------------------------------- //
// ----- Création/Destruction du composant ----------------------------------------------------- //
// --------------------------------------------------------------------------------------------- //
constructor TVerrouilleur.Create(AOwner: TComponent);
begin
  inherited ;
  GActif := FALSE ;
  InstallationDuHook ;
end ;

destructor TVerrouilleur.Destroy;
begin
  VerrouillageTotal := FALSE ;
  RetraitDuHook ;
  inherited;
end ;

// --------------------------------------------------------------------------------------------- //
// ----- Activation/Desactivation du composant ------------------------------------------------- //
// --------------------------------------------------------------------------------------------- //
function TVerrouilleur.GetActif : Boolean ;
begin
  Result := GActif ;
end ;

procedure TVerrouilleur.SetActif( const Value : boolean ) ;
begin
  GActif := Value ;
  MiseAJourVerrous ;
end ;

// --------------------------------------------------------------------------------------------- //
// ----- Hook du clavier ----------------------------------------------------------------------- //
// --------------------------------------------------------------------------------------------- //
type
  PKBDLLHOOKSTRUCT = ^KBDLLHOOKSTRUCT ;
  KBDLLHOOKSTRUCT = record
    vkCode      : DWORD  ;
    scanCode    : DWORD  ;
    flags       : DWORD  ;
    time        : DWORD  ;
    dwExtraInfo : PULONG ;
  end ;

var
  GHookClavier : HHOOK   ;

function MonGestionnaireClavier( Code : Integer; WPar : WPARAM; LPar : LPARAM):LRESULT; stdcall ;
const
  LLKHF_ALTDOWN = 32 ;
var
  Infos        : PKBDLLHOOKSTRUCT ;
  AppuiSurCTRL : Boolean ;
  AppuiSurALT  : Boolean ;
begin
  Result := 1 ;
  Infos := PKBDLLHOOKSTRUCT(LPar) ;

  case Code of
    HC_ACTION :
    begin
      AppuiSurCTRL := GetAsyncKeyState( VK_CONTROL ) <> 0 ;
      AppuiSurALT  := ( Infos.flags and LLKHF_ALTDOWN = LLKHF_ALTDOWN ) ;

      case Infos.vkCode of

        VK_ESCAPE :  // Touche "Echap"
        begin
          if (     ( GVerrouillageCtrlEsc and AppuiSurCTRL )
               or  ( GVerrouillageAltEsc  and AppuiSurALT  )
             ) then
          begin
            Exit ;
          end ;
        end ;

        VK_TAB : // Touche "Tabulation"
        begin
          if (     ( GVerrouillageAltTab  and AppuiSurALT  )
             ) then
          begin
            Exit ;
          end ;
        end ;

        // ----- Clavier Microsoft ----- //
        VK_LWIN , // Touche gauche "Windows"
        VK_RWIN , // Touche droite "Windows"
        VK_APPS : // Touche "Applications"
        begin
          if (     ( GVerrouillageTouchesMicrosoft )
             ) then
          begin
            Exit ;
          end ;
        end ;
      end ;
    end ;
  end ;

  Result:= CallNextHookEx(GHookClavier, Code, WPar, LPar);
end ;

procedure TVerrouilleur.InstallationDuHook ;
const
  WH_KEYBOARD_LL = 13 ;
begin
  GHookClavier :=
    SetWindowsHookEx
    ( { idHook     } WH_KEYBOARD_LL
    , { lpfn       } @MonGestionnaireClavier
    , { hmod       } GetModuleHandle(NIL)
    , { dwThreadId } 0
    ) ;
end ;

procedure TVerrouilleur.RetraitDuHook ;
begin
  // ----- Retrait du Hook ----- //
  if ( GHookClavier <> 0 ) then
  begin
    UnhookWindowsHookEx( GHookClavier ) ;
    GHookClavier := 0 ;
  end ;
end ;

// --------------------------------------------------------------------------------------------- //
// ----- ALT+TAB ------------------------------------------------------------------------------- //
// --------------------------------------------------------------------------------------------- //
procedure TVerrouilleur.SetVerrouillageAltTab(const Value: boolean);
begin
  GVerrouillageAltTab := GActif and Value ;
end ;

// --------------------------------------------------------------------------------------------- //
// ----- CTRL+ESC ------------------------------------------------------------------------------ //
// --------------------------------------------------------------------------------------------- //
procedure TVerrouilleur.SetVerrouillageCtrlEsc(const Value: boolean);
begin
  GVerrouillageCtrlEsc := GActif and Value;
end ;

// --------------------------------------------------------------------------------------------- //
// ----- ALT+ESC ------------------------------------------------------------------------------- //
// --------------------------------------------------------------------------------------------- //
procedure TVerrouilleur.SetVerrouillageAltEsc(const Value: boolean);
begin
  GVerrouillageAltEsc := GActif and Value;
end ;

// --------------------------------------------------------------------------------------------- //
// ----- Touches "WINDOWS" --------------------------------------------------------------------- //
// --------------------------------------------------------------------------------------------- //
procedure TVerrouilleur.SetVerrouillageTouchesMicrosoft(const Value: boolean);
begin
  GVerrouillageTouchesMicrosoft := GActif and Value;
end ;

// --------------------------------------------------------------------------------------------- //
// ----- CTRL+ALT+SUP -------------------------------------------------------------------------- //
// --------------------------------------------------------------------------------------------- //
procedure TVerrouilleur.SetVerrouillageCtrlAltSup(const Value: boolean);
const
  CTRL_ALT_SUP_ROOT_KEY = HKEY_CURRENT_USER ;
  CTRL_ALT_SUP_KEY      = '\Software\Microsoft\Windows\CurrentVersion\Policies\System' ;
  CTRL_ALT_SUP_DONNEE   = 'DisableTaskMgr' ;
var
  BaseDeRegistre : TRegistry ;
begin
  BaseDeRegistre := TRegistry.Create ;
  try
    with BaseDeRegistre do
    begin
      RootKey := CTRL_ALT_SUP_ROOT_KEY ;
      if ( OpenKey(CTRL_ALT_SUP_KEY,TRUE)
         ) then
      begin
        if ( GActif and Value )
          then WriteInteger( CTRL_ALT_SUP_DONNEE, 1 )
          else WriteInteger( CTRL_ALT_SUP_DONNEE, 0 ) ;
        CloseKey;
      end ;
    end ;
  finally
    BaseDeRegistre .Free ;
  end ;
end ;

// --------------------------------------------------------------------------------------------- //
// ----- Barre des tâches ---------------------------------------------------------------------- //
// --------------------------------------------------------------------------------------------- //
procedure TVerrouilleur.SetVerrouillageBarreDesTaches(const Value: boolean);
const
  BARRE_DES_TACHES_NOM = 'Shell_traywnd' ;
  FLAGS : array[boolean] of Cardinal =
    ( { FALSE } SWP_SHOWWINDOW
    , { TRUE  } SWP_HIDEWINDOW
    ) ;
begin
  FVerrouillageBarreDesTaches := GActif and Value ;

  SetWindowPos
    ( { hWnd            } FindWindow( BARRE_DES_TACHES_NOM, '')
    , { hWndInsertAfter } 0
    , { x               } 0
    , { y               } 0
    , { cx              } 0
    , { cy              } 0
    , { uFlags          } FLAGS[ FVerrouillageBarreDesTaches ]
    )
  ;
end ;

// --------------------------------------------------------------------------------------------- //
// ----- Globalité ----------------------------------------------------------------------------- //
// --------------------------------------------------------------------------------------------- //
procedure TVerrouilleur.SetVerrouillageTotal(const Value: boolean);
begin
  FVerrouillageTotal := Value ;

  if ( FVerrouillageTotal ) then
  begin
    SetVerrous             {     , vBarreDesTaches }
    ( [ vCtrlAltSup
      , vCtrlEsc
      , vAltTab
      , vAltEsc
      , vTouchesMicrosoft
      ]
    ) ;
  end ;
end ;

procedure TVerrouilleur.MiseAJourVerrous ;
begin
  SetVerrouillageCtrlAltSup       ( vCtrlAltSup       in FVerrous ) ;
  SetVerrouillageCtrlEsc          ( vCtrlEsc          in FVerrous ) ;
  SetVerrouillageAltTab           ( vAltTab           in FVerrous ) ;
  SetVerrouillageAltEsc           ( vAltEsc           in FVerrous ) ;
  SetVerrouillageBarreDesTaches   ( vBarreDesTaches   in FVerrous ) ;
  SetVerrouillageTouchesMicrosoft ( vTouchesMicrosoft in FVerrous ) ;
end ;

procedure TVerrouilleur.SetVerrous ( const Value : TVerrous ) ;
begin
  FVerrous := Value ;
  MiseAJourVerrous ;
end ;

// --------------------------------------------------------------------------------------------- //
// ----- Singleton ----------------------------------------------------------------------------- //
// --------------------------------------------------------------------------------------------- //
var
  InstanceVerrouilleur : TVerrouilleur = nil ;

class function TVerrouilleur.NewInstance : TObject ;
begin
  if ( InstanceVerrouilleur = NIL ) then
  begin
    InstanceVerrouilleur := TVerrouilleur( inherited NewInstance ) ;
    Result := InstanceVerrouilleur ;
  end else
  begin
    raise Exception .Create( ClassName + ' : Un seul composant pas application est autorisé.' ) ;
  end ;
end ;

procedure TVerrouilleur.FreeInstance ;
begin
  inherited FreeInstance ;
  InstanceVerrouilleur := NIL ;
end ;

// --------------------------------------------------------------------------------------------- //
// ----- Enregistrement du composant ----------------------------------------------------------- //
// --------------------------------------------------------------------------------------------- //
procedure Register ;
begin
  RegisterComponents( 'WHITEHIPPO', [TVerrouilleur] ) ;
end ;


end.
