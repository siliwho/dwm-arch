
#include <ncurses.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define SCRIPT_PATH "./theme-dwm.sh"

// --- Function Prototypes ---
void print_menu(WINDOW *menu_win, int highlight, const char *choices[],
                int n_choices);
void execute_command(const char *choice);

int main() {
  initscr();
  clear();
  noecho();
  cbreak();
  curs_set(0);

  int height, width;
  getmaxyx(stdscr, height, width);

  const char *choices[] = {
      "tokyo", "gruvbox", "nord", "everforest", "blackwhite",
  };
  int n_choices = sizeof(choices) / sizeof(char *);
  int highlight = 1;
  int c;

  int menu_height = n_choices + 4;
  int menu_width = 30;
  int starty = (height - menu_height) / 2;
  int startx = (width - menu_width) / 2;

  WINDOW *menu_win = newwin(menu_height, menu_width, starty, startx);
  keypad(menu_win, TRUE);

  mvprintw(0, (width - strlen("dwm Theme Switcher")) / 2, "dwm Theme Switcher");
  mvprintw(height - 2, 2, "↑↓/jk navigate | Enter select | q quit");
  refresh();

  print_menu(menu_win, highlight, choices, n_choices);

  while ((c = wgetch(menu_win))) {
    switch (c) {
    case KEY_UP:
    case 'k':
      highlight = (highlight == 1) ? n_choices : highlight - 1;
      break;
    case KEY_DOWN:
    case 'j':
      highlight = (highlight == n_choices) ? 1 : highlight + 1;
      break;
    case 10:
      execute_command(choices[highlight - 1]);
      break;
    case 'q':
      goto end;
    }
    print_menu(menu_win, highlight, choices, n_choices);
  }

end:
  delwin(menu_win);
  endwin();
  return 0;
}

void print_menu(WINDOW *menu_win, int highlight, const char *choices[],
                int n_choices) {
  box(menu_win, 0, 0);
  mvwprintw(menu_win, 0, 9, "Select Theme");

  int y = 2;
  for (int i = 0; i < n_choices; i++) {
    if (highlight == i + 1)
      wattron(menu_win, A_REVERSE);
    mvwprintw(menu_win, y++, 3, "%s", choices[i]);
    wattroff(menu_win, A_REVERSE);
  }
  wrefresh(menu_win);
}

void execute_command(const char *choice) {
  char cmd[256];
  snprintf(cmd, sizeof(cmd), "%s %s >/dev/null 2>&1", SCRIPT_PATH, choice);
  system(cmd);
}
