
#include <ncurses.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define SCRIPT_PATH "./theme-dwm.sh"
#define WALLPAPER_SCRIPT "~/.config/dwm/list-wallpapers.sh"
#define MAX_WALLPAPERS 64

/* ---------------- State ---------------- */
enum Mode { MODE_THEME, MODE_WALLPAPER };
static enum Mode mode = MODE_THEME;

static char *wallpapers[MAX_WALLPAPERS];
static int wp_count = 0;
static int wp_highlight = 0;
static char selected_theme[32];

/* ---------------- Prototypes ---------------- */
void print_theme_menu(WINDOW *win, int highlight, const char *choices[], int n);
void print_wallpaper_menu(WINDOW *win);
int load_wallpapers(const char *theme);
void preview_wallpaper(const char *path);
void apply_theme_and_wallpaper(const char *theme, const char *wp);
void cleanup_wallpapers(void);

/* ---------------- Helpers ---------------- */
int load_wallpapers(const char *theme) {
  char cmd[256];
  snprintf(cmd, sizeof(cmd), "%s %s", WALLPAPER_SCRIPT, theme);

  FILE *fp = popen(cmd, "r");
  if (!fp)
    return 0;

  wp_count = 0;
  char line[256];
  while (fgets(line, sizeof(line), fp) && wp_count < MAX_WALLPAPERS) {
    line[strcspn(line, "\n")] = 0;
    wallpapers[wp_count++] = strdup(line);
  }
  pclose(fp);
  return wp_count;
}

void cleanup_wallpapers(void) {
  for (int i = 0; i < wp_count; i++)
    free(wallpapers[i]);
  wp_count = 0;
}

void preview_wallpaper(const char *path) {
  char cmd[512];
  snprintf(cmd, sizeof(cmd), "nitrogen --set-zoom-fill \"%s\" 2>/dev/null",
           path);
  system(cmd);
}

void apply_theme_and_wallpaper(const char *theme, const char *wp) {
  char cmd[512];
  snprintf(cmd, sizeof(cmd), "%s %s \"%s\" >/dev/null 2>&1", SCRIPT_PATH, theme,
           wp);
  system(cmd);
}

/* ---------------- UI ---------------- */
void print_theme_menu(WINDOW *win, int highlight, const char *choices[],
                      int n) {
  werase(win);
  box(win, 0, 0);
  mvwprintw(win, 0, 8, " Select Theme ");

  int y = 2;
  for (int i = 0; i < n; i++) {
    if (highlight == i + 1)
      wattron(win, A_REVERSE);
    mvwprintw(win, y++, 3, "%s", choices[i]);
    wattroff(win, A_REVERSE);
  }
  wrefresh(win);
}

void print_wallpaper_menu(WINDOW *win) {
  werase(win);
  box(win, 0, 0);
  mvwprintw(win, 0, 5, " Wallpaper Preview ");

  mvwprintw(win, 2, 3, "Theme: %s", selected_theme);
  mvwprintw(win, 4, 3, "Wallpaper %d / %d", wp_highlight + 1, wp_count);

  mvwprintw(win, 6, 3, "←/→ or h/l : preview");
  mvwprintw(win, 7, 3, "Enter     : apply");
  mvwprintw(win, 8, 3, "Esc/q     : back");

  wrefresh(win);
}

/* ---------------- Main ---------------- */
int main(void) {
  initscr();
  noecho();
  cbreak();
  curs_set(0);

  int height, width;
  getmaxyx(stdscr, height, width);

  const char *themes[] = {"tokyo", "gruvbox", "nord", "everforest",
                          "blackwhite"};
  int theme_count = sizeof(themes) / sizeof(char *);
  int highlight = 1;

  int win_h = 12, win_w = 34;
  WINDOW *win = newwin(win_h, win_w, (height - win_h) / 2, (width - win_w) / 2);
  keypad(win, TRUE);

  mvprintw(1, (width - 18) / 2, "dwm Theme Switcher");
  refresh();

  print_theme_menu(win, highlight, themes, theme_count);

  int ch;
  while ((ch = wgetch(win))) {
    if (mode == MODE_THEME) {
      switch (ch) {
      case KEY_UP:
      case 'k':
        highlight = (highlight == 1) ? theme_count : highlight - 1;
        break;

      case KEY_DOWN:
      case 'j':
        highlight = (highlight == theme_count) ? 1 : highlight + 1;
        break;

      case 10: /* Enter */
        strcpy(selected_theme, themes[highlight - 1]);
        system("nitrogen --restore 2>/dev/null");
        if (load_wallpapers(selected_theme) > 0) {
          wp_highlight = 0;
          preview_wallpaper(wallpapers[0]);
          mode = MODE_WALLPAPER;
        }
        break;

      case 'q':
        goto exit;
      }
      print_theme_menu(win, highlight, themes, theme_count);
    }

    else if (mode == MODE_WALLPAPER) {
      switch (ch) {
      case KEY_LEFT:
      case 'h':
        wp_highlight = (wp_highlight == 0) ? wp_count - 1 : wp_highlight - 1;
        preview_wallpaper(wallpapers[wp_highlight]);
        break;

      case KEY_RIGHT:
      case 'l':
        wp_highlight = (wp_highlight + 1) % wp_count;
        preview_wallpaper(wallpapers[wp_highlight]);
        break;

      case 10: /* Enter → APPLY */
        apply_theme_and_wallpaper(selected_theme, wallpapers[wp_highlight]);
        goto exit;

      case 27: /* Esc */
      case 'q':
      case KEY_BACKSPACE:
        system("nitrogen --restore 2>/dev/null");
        cleanup_wallpapers();
        mode = MODE_THEME;
        break;
      }
      if (mode == MODE_WALLPAPER)
        print_wallpaper_menu(win);
      else
        print_theme_menu(win, highlight, themes, theme_count);
    }
  }

exit:
  cleanup_wallpapers();
  delwin(win);
  endwin();
  return 0;
}
