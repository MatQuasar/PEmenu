; PEmenu - A GUI version of PEbasic
; Developed by MatQuasar (aka fliermate) - Apr 2025
;
; Dedicated to SherpaSecMy
;
format PE GUI 4.0
include 'win32a.inc'

IDR_MENU = 37
IDM_LOAD   = 101
IDM_EXIT  = 102
IDM_ABOUT = 901
IDD_MAIN = 100
IDC_FILE=200
IDC_TYPE=201

section '.text' code readable executable

entry $

        invoke  GetModuleHandle,0
        invoke  DialogBoxParam,eax,IDD_MAIN,HWND_DESKTOP,DialogProc,0
        invoke  ExitProcess,0

proc DialogProc hwnd,wmsg,wparam,lparam
        push    ebx esi edi
        mov     eax,[wmsg]
        cmp     eax,WM_INITDIALOG
        je      .wminitdialog
        cmp     eax,WM_COMMAND
        je      .wmcommand
        cmp     eax,WM_CLOSE
        je      .wmclose
        xor     eax,eax
        jmp     .finish
  .wminitdialog:
        jmp     .processed
  .wmcommand:
        mov     eax,[wparam]
        and     eax,0FFFFh
        cmp     eax,IDM_LOAD
        je      .load
        cmp     eax,IDM_ABOUT
        je      .about
        cmp     eax,IDM_EXIT
        je      .wmclose
        jmp     .processed
      .load:
        invoke  GetOpenFileName, _ofn
        or      eax, eax
        jz      .processed

        invoke  SetDlgItemText,[hwnd],IDC_FILE,_filename
        ;invoke  SetDlgItemText,[hwnd],IDC_TYPE,_number
        jmp     .processed

      .about:
        invoke  MessageBox,[hwnd],_about_text,_about_title,MB_OK
        jmp     .processed
  .wmclose:
        invoke  EndDialog,[hwnd],0
        xor     eax,eax
  .processed:
        mov     eax,1
  .finish:
        pop     edi esi ebx
        ret
endp

section '.data' data readable writeable

  struct OPENFILENAME
    SizeOf     dd  sizeof.OPENFILENAME
    Res0       rd  2
    Filter     dd  _filter
    Res1       rd  3
    FileName   dd  _filename
    MaxFile    dd  512
    Res2       rd  4
    ofnFlags   dd  OFN_EXPLORER
    Res3       rd  5
  ends

  _ofn          OPENFILENAME
  _filter       db  'Executables (exe, dll, sys, ocx, scr)',0
                db  '*.exe;*.dll;*.sys;*.ocx;*.scr',0,0
  _filename     rb  2048

  _about_title TCHAR 'PEmenu',0
  _about_text TCHAR 'This is a GUI version of PEbasic developed by MatQuasar (aka fliermate) - Apr 2025',0

section '.idata' import data readable writeable

  library kernel,'KERNEL32.DLL',\
          user,'USER32.DLL',\
          comdlg32, 'COMDLG32.DLL'

  import kernel,\
         GetModuleHandle,'GetModuleHandleA',\
         CreateFile, 'CreateFileA', \
         ReadFile, 'ReadFile', \
         CloseHandle, 'CloseHandle', \
         SetFilePointer, 'SetFilePointer', \
         ExitProcess,'ExitProcess'

  import user,\
         DialogBoxParam,'DialogBoxParamA',\
         EndDialog,'EndDialog' ,\
         SetDlgItemText,'SetDlgItemTextA',\
         GetDlgItemText,'GetDlgItemTextA',\
         GetDlgItem,'GetDlgItem',\
         SendMessage,'SendMessageA',\
         MessageBox,'MessageBoxA'

  import comdlg32, GetOpenFileName,'GetOpenFileNameA'

section '.rsrc' resource data readable

  directory RT_DIALOG,dialogs,\
            RT_MENU,menus, \
            RT_VERSION,versions

  resource dialogs,\
           IDD_MAIN,LANG_ENGLISH+SUBLANG_DEFAULT,main_dialog

  resource menus,\
           IDR_MENU,LANG_ENGLISH+SUBLANG_DEFAULT,main_menu

  resource versions,\
           1,LANG_NEUTRAL,version

  dialog main_dialog,'PEmenu',100,100,400,80,WS_CAPTION+WS_POPUP+WS_SYSMENU+DS_MODALFRAME,0,IDR_MENU
     dialogitem 'STATIC','File: ',-1,10,10,70,65,WS_VISIBLE
     dialogitem 'EDIT','',IDC_FILE,80,10,300,15,WS_VISIBLE+WS_BORDER+WS_TABSTOP+ES_AUTOHSCROLL+ES_READONLY
     dialogitem 'STATIC','Program Type',-1,10,30,70,95,WS_VISIBLE
     dialogitem 'EDIT','',IDC_TYPE,80,30,150,15,WS_VISIBLE+WS_BORDER+WS_TABSTOP+ES_AUTOHSCROLL+ES_READONLY
  enddialog

  menu main_menu
       menuitem '&File',0,MFR_POPUP
                menuitem '&Load PE...',IDM_LOAD
                menuseparator
                menuitem 'E&xit',IDM_EXIT,MFR_END
       menuitem '&Help',0,MFR_POPUP + MFR_END
                menuitem '&About...',IDM_ABOUT,MFR_END

  versioninfo version,VOS__WINDOWS32,VFT_APP,VFT2_UNKNOWN,LANG_ENGLISH+SUBLANG_DEFAULT,0,\
              'FileDescription','PEmenu',\
              'LegalCopyright','No rights reserved.',\
              'FileVersion','1.0',\
              'ProductVersion','1.0',\
              'OriginalFilename','PEMENU.EXE'
