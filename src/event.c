void open_console();


void on_winmain_call() {
}


void on_before_window_show() {
  open_console();
}