void __cdecl open_console();


void __cdecl on_winmain_call() {
}


void __cdecl on_before_window_show() {
  open_console();
}