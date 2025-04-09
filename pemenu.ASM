format PE GUI 4.0
include 'win32a.inc'

;IDR_ICON = 17
IDR_MENU = 37

IDM_LOAD   = 101
IDM_EXIT  = 102
IDM_ABOUT = 901

section '.text' code readable executable

entry $

        invoke  GetModuleHandle,0
        mov     [wc.hInstance],eax

;        invoke  LoadIcon,eax,IDR_ICON
;        mov     [wc.hIcon],eax
        invoke  LoadCursor,0,IDC_ARROW
        mov     [wc.hCursor],eax
        invoke  RegisterClass,wc
        test    eax,eax
        jz      error

        invoke  LoadMenu,[wc.hInstance],IDR_MENU
        invoke  CreateWindowEx,0,_class,_title,WS_VISIBLE+WS_OVERLAPPEDWINDOW,144,128,256,256,NULL,eax,[wc.hInstance],NULL
        test    eax,eax
        jz      error

  msg_loop:
        invoke  GetMessage,msg,NULL,0,0
        cmp     eax,1
        jb      end_loop
        jne     msg_loop
        invoke  TranslateMessage,msg
        invoke  DispatchMessage,msg
        jmp     msg_loop

  error:
        invoke  MessageBox,NULL,_error,NULL,MB_ICONERROR+MB_OK

  end_loop:
        invoke  ExitProcess,[msg.wParam]

proc WindowProc hwnd,wmsg,wparam,lparam
        push    ebx esi edi
        mov     eax,[wmsg]
        cmp     eax,WM_CREATE
        je      .wmcreate
        cmp     eax,WM_COMMAND
        je      .wmcommand
        cmp     eax,WM_DESTROY
        je      .wmdestroy
  .defwndproc:
        invoke  DefWindowProc,[hwnd],[wmsg],[wparam],[lparam]
        jmp     .finish
  .wmcreate:
        xor     eax,eax
        jmp     .finish
  .wmcommand:
        mov     eax,[wparam]
        and     eax,0FFFFh
        cmp     eax,IDM_LOAD
        je      .new
        cmp     eax,IDM_ABOUT
        je      .about
        cmp     eax,IDM_EXIT
        je      .wmdestroy
        jmp     .defwndproc
      .new:
        ;invoke  SendMessage,[edithwnd],WM_SETTEXT,0,0
        jmp     .finish
      .about:
        invoke  MessageBox,[hwnd],_about_text,_about_title,MB_OK
        jmp     .finish
  .wmdestroy:
        invoke  PostQuitMessage,0
        xor     eax,eax
  .finish:
        pop     edi esi ebx
        ret
endp

section '.data' data readable writeable

  _title TCHAR 'PEmenu',0
  _about_title TCHAR 'PEmenu',0
  _about_text TCHAR 'This is a GUI version of PEbasic developed by MatQuasar (Apr 2025).',0
  _error TCHAR 'Startup failed.',0

  _class TCHAR 'PEmenu',0

  wc WNDCLASS 0,WindowProc,0,0,NULL,NULL,NULL,COLOR_BTNFACE+1,NULL,_class

  msg MSG
  client RECT

section '.idata' import data readable writeable

  library kernel,'KERNEL32.DLL',\
          user,'USER32.DLL'

  import kernel,\
         GetModuleHandle,'GetModuleHandleA',\
         ExitProcess,'ExitProcess'

  import user,\
         RegisterClass,'RegisterClassA',\
         CreateWindowEx,'CreateWindowExA',\
         DefWindowProc,'DefWindowProcA',\
         SetWindowLong,'SetWindowLongA',\
         GetMessage,'GetMessageA',\
         TranslateMessage,'TranslateMessage',\
         DispatchMessage,'DispatchMessageA',\
         SendMessage,'SendMessageA',\
         LoadCursor,'LoadCursorA',\
         LoadIcon,'LoadIconA',\
         LoadMenu,'LoadMenuA',\
         GetClientRect,'GetClientRect',\
         MessageBox,'MessageBoxA',\
         PostQuitMessage,'PostQuitMessage'

section '.rsrc' resource data readable

  ; resource directory

  directory RT_MENU,menus,\
            RT_VERSION,versions

;            RT_ICON,icons,\
;            RT_GROUP_ICON,group_icons,\


  ; resource subdirectories

  resource menus,\
           IDR_MENU,LANG_ENGLISH+SUBLANG_DEFAULT,main_menu

;  resource icons,\
;           1,LANG_NEUTRAL,icon_data

;  resource group_icons,\
;           IDR_ICON,LANG_NEUTRAL,main_icon

  resource versions,\
           1,LANG_NEUTRAL,version

  menu main_menu
       menuitem '&File',0,MFR_POPUP
                menuitem '&Load PE...',IDM_LOAD
                menuseparator
                menuitem 'E&xit',IDM_EXIT,MFR_END
       menuitem '&Help',0,MFR_POPUP + MFR_END
                menuitem '&About...',IDM_ABOUT,MFR_END

;  icon main_icon,icon_data,'minipad.ico'

  versioninfo version,VOS__WINDOWS32,VFT_APP,VFT2_UNKNOWN,LANG_ENGLISH+SUBLANG_DEFAULT,0,\
              'FileDescription','PEmenu',\
              'LegalCopyright','No rights reserved.',\
              'FileVersion','1.0',\
              'ProductVersion','1.0',\
              'OriginalFilename','PEMENU.EXE'
