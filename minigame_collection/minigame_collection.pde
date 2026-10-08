// ============================================================
//  ミニゲームコレクション
//
//  収録ゲーム
//   1. 激熱！メガトンバーニング
//   2. とれたて！フルーツフェスティバル
//   3. 刹那の早撃ち
//   4. 春風スターグライド
// ============================================================

// ---------- キー番号 ----------
final int K_UP = 1038;
final int K_DOWN = 1040;
final int K_LEFT = 1037;
final int K_RIGHT = 1039;
final int K_ENTER = 10;
final int K_SPACE = 32;

// ---------- 共通フェーズ ----------
final int PH_MENU = 0;     // ミニゲーム専用タイトル
final int PH_HELP = 1;     // ミニゲームの説明
final int PH_RESULT = 9;   // リザルト

boolean[] keys = new boolean[1200];
PFont jpFont;
Scene cur;
TitleScene titleScene;
SelectScene selectScene;
Game1 game1;
Game2 game2;
Game3 game3;
Game4 game4;

// フルーツ描画用
final float[] RADII = {18, 18, 20, 24, 18, 20, 18};   // 6番目＝爆弾
final float[] GRAPE_X = {-9, 0, 9, -5, 5, 0};
final float[] GRAPE_Y = {-6, -7, -6, 3, 3, 11};

// ============================================================
//  基本処理
// ============================================================
void setup() {
  size(960, 600);
  frameRate(60);
  jpFont = loadJapaneseFont();
  textFont(jpFont);
  titleScene = new TitleScene();
  selectScene = new SelectScene();
  game1 = new Game1();
  game2 = new Game2();
  game3 = new Game3();
  game4 = new Game4();
  changeScene(titleScene);
}

void draw() {
  cur.show();
}

void changeScene(Scene s) {
  cur = s;
  s.enter();
}

PFont loadJapaneseFont() {
  String[] cands = {
    "Meiryo", "Yu Gothic UI", "Yu Gothic", "MS Gothic", "MS PGothic",
    "Hiragino Sans", "Hiragino Kaku Gothic ProN", "Noto Sans CJK JP",
    "Noto Sans JP", "IPAexGothic", "IPAGothic", "TakaoGothic", "VL Gothic", "Osaka"
  };
  String[] avail = PFont.list();
  for (int i = 0; i < cands.length; i++) {
    for (int j = 0; j < avail.length; j++) {
      if (avail[j].equalsIgnoreCase(cands[i])) {
        return createFont(avail[j], 48, true);
      }
    }
  }
  return createFont("SansSerif", 48, true);
}

// ---------- キー入力 ----------
int normKey() {
  if (key == CODED) return 1000 + keyCode;
  if (key == ENTER || key == RETURN) return K_ENTER;
  if (key == ' ') return K_SPACE;
  int c = Character.toUpperCase(key);
  return c;
}

void keyPressed() {
  int kc = normKey();
  if (kc < 0 || kc >= keys.length) return;
  if (keys[kc]) return;        // 押しっぱなしのオートリピートは無視
  keys[kc] = true;
  cur.onKeyDown(kc);
}

void keyReleased() {
  int kc = normKey();
  if (kc < 0 || kc >= keys.length) return;
  keys[kc] = false;
  cur.onKeyUp(kc);
}

void mousePressed() {
  cur.onMouse();
}

// ============================================================
//  描画ヘルパー
// ============================================================
void gradBG(color a, color b) {
  noStroke();
  for (int y = 0; y < height; y += 6) {
    fill(lerpColor(a, b, y / (float) height));
    rect(0, y, width, 6);
  }
}

void txt(String s, float x, float y, float sz, color c) {
  textAlign(CENTER, CENTER);
  textSize(sz);
  noStroke();
  fill(c);
  text(s, x, y);
}

void txtL(String s, float x, float y, float sz, color c) {
  textAlign(LEFT, CENTER);
  textSize(sz);
  noStroke();
  fill(c);
  text(s, x, y);
}

void txtO(String s, float x, float y, float sz, color c, color oc) {
  textAlign(CENTER, CENTER);
  textSize(sz);
  noStroke();
  float o = max(2, sz * 0.04);
  fill(oc);
  for (int i = 0; i < 8; i++) {
    float a = i * QUARTER_PI;
    text(s, x + cos(a) * o, y + sin(a) * o);
  }
  fill(c);
  text(s, x, y);
}

void drawStar(float x, float y, float r1, float r2, float rot) {
  beginShape();
  for (int i = 0; i < 10; i++) {
    float a = rot + i * PI / 5 - HALF_PI;
    float r = (i % 2 == 0) ? r2 : r1;
    vertex(x + cos(a) * r, y + sin(a) * r);
  }
  endShape(CLOSE);
}

float sstep(float a, float b, float x) {
  float t = constrain((x - a) / (b - a), 0, 1);
  return t * t * (3 - 2 * t);
}

float fl2(float v) {
  return floor((v + 0.001) * 100) / 100.0;
}

void updateParts(ArrayList<Particle> ps) {
  for (int i = ps.size() - 1; i >= 0; i--) {
    Particle p = ps.get(i);
    p.update();
    if (p.life <= 0) ps.remove(i);
  }
}

void drawFruit(int type, float x, float y, float r, float rot) {
  pushMatrix();
  translate(x, y);
  rotate(rot);
  noStroke();
  switch (type) {
  case 0: // リンゴ
    fill(215, 40, 45);
    ellipse(0, 2, r * 2, r * 1.9);
    fill(110, 70, 30);
    rect(-1.5, -r - 3, 3, 9);
    fill(70, 170, 60);
    ellipse(7, -r + 1, 12, 7);
    fill(255, 255, 255, 90);
    ellipse(-r * 0.4, -r * 0.1, r * 0.4, r * 0.6);
    break;
  case 1: // ミカン
    fill(255, 150, 20);
    ellipse(0, 0, r * 2, r * 2);
    fill(60, 150, 50);
    ellipse(0, -r + 2, 10, 6);
    fill(255, 200, 100, 150);
    ellipse(-r * 0.35, -r * 0.25, r * 0.5, r * 0.4);
    break;
  case 2: // メロン
    fill(150, 215, 100);
    ellipse(0, 0, r * 2, r * 2);
    noFill();
    stroke(100, 170, 70);
    strokeWeight(1.5);
    ellipse(0, 0, r * 1.0, r * 2);
    ellipse(0, 0, r * 1.7, r * 2);
    noStroke();
    fill(90, 150, 60);
    rect(-1.5, -r - 4, 3, 7);
    break;
  case 3: // スイカ
    fill(45, 150, 65);
    ellipse(0, 0, r * 2.2, r * 2);
    stroke(20, 95, 40);
    strokeWeight(3);
    for (int k = -1; k <= 1; k++) {
      line(k * r * 0.55, -r * 0.85 * (1 - abs(k) * 0.3), k * r * 0.4, r * 0.85 * (1 - abs(k) * 0.3));
    }
    noStroke();
    break;
  case 4: // ブドウ
    fill(125, 55, 170);
    for (int k = 0; k < 6; k++) {
      ellipse(GRAPE_X[k], GRAPE_Y[k], 14, 14);
    }
    fill(255, 255, 255, 70);
    ellipse(-4, -9, 4, 4);
    fill(110, 70, 30);
    rect(-1.5, -17, 3, 7);
    fill(70, 170, 60);
    ellipse(6, -16, 11, 6);
    break;
  case 6: // 爆弾
    fill(35, 35, 40);
    ellipse(0, 3, r * 2, r * 2);
    fill(255, 255, 255, 80);
    ellipse(-r * 0.35, -r * 0.2, r * 0.45, r * 0.35);
    stroke(150, 110, 60);
    strokeWeight(3);
    line(0, -r + 3, 7, -r - 6);
    noStroke();
    fill(255, 170, 0);
    drawStar(8, -r - 8, 3, 8, frameCount * 0.3);
    fill(255, 60, 40);
    ellipse(0, 4, 8, 8);
    break;
  default: // 黄金のリンゴ
    float pu = 1 + 0.08 * sin(frameCount * 0.2);
    fill(255, 235, 90, 70);
    ellipse(0, 0, r * 3.2 * pu, r * 3.2 * pu);
    fill(255, 205, 0);
    ellipse(0, 2, r * 2, r * 1.9);
    fill(120, 80, 20);
    rect(-1.5, -r - 3, 3, 9);
    fill(90, 190, 70);
    ellipse(7, -r + 1, 12, 7);
    fill(255, 255, 255, 190);
    drawStar(-r * 0.35, -r * 0.2, 2, 6, 0);
    break;
  }
  popMatrix();
}

// ============================================================
//  共通部品クラス
// ============================================================
abstract class Scene {
  void enter() {
  }
  abstract void show();
  void onKeyDown(int kc) {
  }
  void onKeyUp(int kc) {
  }
  void onMouse() {
  }
}

class Particle {
  float x, y, vx, vy, grav, sz, rot, vr;
  int life, maxLife;
  color c;
  Particle(float x, float y, float vx, float vy, float grav, float sz, int life, color c) {
    this.x = x;
    this.y = y;
    this.vx = vx;
    this.vy = vy;
    this.grav = grav;
    this.sz = sz;
    this.life = life;
    this.maxLife = life;
    this.c = c;
    this.rot = random(TWO_PI);
    this.vr = random(-0.3, 0.3);
  }
  void update() {
    x += vx;
    y += vy;
    vy += grav;
    rot += vr;
    life--;
  }
}

// ---------- ボタンメニュー（マウス＆WASD対応） ----------
class Menu {
  String[] labels;
  int cols;
  float[] bx, by;
  float bw, bh;
  int sel = 0;
  float lastMX = -1, lastMY = -1;

  Menu(String[] labels, int cols, float cx, float topY, float bw, float bh, float gapX, float gapY) {
    this.labels = labels;
    this.cols = cols;
    this.bw = bw;
    this.bh = bh;
    int n = labels.length;
    bx = new float[n];
    by = new float[n];
    float totalW = cols * bw + (cols - 1) * gapX;
    for (int i = 0; i < n; i++) {
      int r = i / cols;
      int c = i % cols;
      bx[i] = cx - totalW / 2 + c * (bw + gapX);
      by[i] = topY + r * (bh + gapY);
    }
  }

  int hit(float mx, float my) {
    for (int i = 0; i < labels.length; i++) {
      if (mx >= bx[i] && mx <= bx[i] + bw && my >= by[i] && my <= by[i] + bh) return i;
    }
    return -1;
  }

  void display(float tsz) {
    if (mouseX != lastMX || mouseY != lastMY) {
      int h = hit(mouseX, mouseY);
      if (h >= 0) sel = h;
      lastMX = mouseX;
      lastMY = mouseY;
    }
    for (int i = 0; i < labels.length; i++) {
      boolean s = (i == sel);
      if (s) {
        stroke(255);
        strokeWeight(4);
        fill(255, 205, 70);
      } else {
        stroke(255, 255, 255, 130);
        strokeWeight(2);
        fill(20, 20, 45, 200);
      }
      rect(bx[i], by[i], bw, bh, 14);
      txt(labels[i], bx[i] + bw / 2, by[i] + bh / 2, tsz, s ? color(50, 30, 0) : color(255));
    }
    noStroke();
    strokeWeight(1);
  }

  int click() {
    int h = hit(mouseX, mouseY);
    if (h >= 0) sel = h;
    return h;
  }

  void move(int dx, int dy) {
    int n = labels.length;
    int rows = (n + cols - 1) / cols;
    int r = sel / cols;
    int c = sel % cols;
    int nr = r + dy;
    int nc = c + dx;
    if (nr < 0 || nr >= rows || nc < 0 || nc >= cols) {
      if (cols == 1 && dy != 0) sel = (sel + dy + n) % n;
      return;
    }
    int ni = nr * cols + nc;
    if (ni < n) sel = ni;
  }

  // 選択されたら番号、そうでなければ -1
  int keyNav(int kc) {
    if (kc == 'W' || kc == K_UP) move(0, -1);
    else if (kc == 'S' || kc == K_DOWN) move(0, 1);
    else if (kc == 'A' || kc == K_LEFT) move(-1, 0);
    else if (kc == 'D' || kc == K_RIGHT) move(1, 0);
    else if (kc == K_ENTER) return sel;
    return -1;
  }
}

// ============================================================
//  タイトル画面 / ミニゲーム選択画面
// ============================================================
class TitleScene extends Scene {
  int t = 0;
  void enter() {
    t = 0;
  }
  void show() {
    t++;
    gradBG(color(25, 30, 80), color(150, 60, 140));
    noStroke();
    for (int i = 0; i < 16; i++) {
      float s = 30 + (i % 4) * 16;
      float px = (i * 151 + t * (0.4 + (i % 3) * 0.3)) % (width + 100) - 50;
      float py = (i * 97 + 40) % height;
      fill(255, 255, 255, 28);
      rect(px, py, s, s);
    }
    txtO("ミニゲームコレクション", width / 2, 190, 72, color(255, 235, 90), color(60, 20, 80));
    txt("～ 4つのミニゲームで遊ぼう！ ～", width / 2, 285, 28, color(255));
    if ((t / 30) % 2 == 0) {
      txt("エンターキーを押してスタート", width / 2, 440, 36, color(255));
    }
  }
  void onKeyDown(int kc) {
    if (kc == K_ENTER) changeScene(selectScene);
  }
}

class SelectScene extends Scene {
  Menu m;
  String[] names = {
    "激熱！メガトンバーニング\n【ひとり用】",
    "とれたて！フルーツフェスティバル\n【ふたり対戦】",
    "刹那の早撃ち\n【ひとり / ふたり】",
    "春風スターグライド\n【ひとり用】"
  };
  SelectScene() {
    m = new Menu(names, 2, width / 2, 190, 430, 120, 30, 30);
  }
  void enter() {
    m.sel = 0;
  }
  void show() {
    gradBG(color(20, 60, 110), color(60, 20, 90));
    txtO("ミニゲームを選んでね", width / 2, 80, 46, color(255), color(20, 20, 60));
    txt("マウスでクリック　または　WASDで移動してエンターキーで決定", width / 2, 135, 22, color(220, 235, 255));
    m.display(23);
  }
  void onKeyDown(int kc) {
    int c = m.keyNav(kc);
    if (c >= 0) launch(c);
  }
  void onMouse() {
    int c = m.click();
    if (c >= 0) launch(c);
  }
  void launch(int c) {
    if (c == 0) changeScene(game1);
    else if (c == 1) changeScene(game2);
    else if (c == 2) changeScene(game3);
    else if (c == 3) changeScene(game4);
  }
}

// ============================================================
//  ミニゲーム共通の土台（専用タイトル・説明・リザルトメニュー）
// ============================================================
abstract class MiniGame extends Scene {
  int phase = PH_MENU;
  int resT = 0;
  String title;
  String[] help;
  color c1, c2;
  Menu menu, resMenu;

  MiniGame(String t, String[] h, int ra, int ga, int ba, int rb, int gb, int bb) {
    title = t;
    help = h;
    c1 = color(ra, ga, ba);
    c2 = color(rb, gb, bb);
    menu = new Menu(new String[] {"スタート", "ゲームの説明", "ミニゲーム選択画面に戻る"}, 1, width / 2, 300, 440, 58, 0, 16);
    resMenu = new Menu(new String[] {"もう一度遊ぶ", "ミニゲーム選択画面に戻る"}, 2, width / 2, height - 110, 380, 64, 24, 0);
  }

  abstract void onStart();
  abstract void restart();

  void enter() {
    phase = PH_MENU;
    menu.sel = 0;
  }

  void showMenuScreen() {
    gradBG(c1, c2);
    txtO(title, width / 2, 150, 50, color(255), color(30, 20, 50));
    txt("～ スタート・ゲームの説明・戻る から選んでね ～", width / 2, 235, 22, color(255));
    menu.display(26);
  }

  void showHelpScreen() {
    gradBG(c1, c2);
    noStroke();
    fill(0, 0, 0, 175);
    rect(50, 40, width - 100, height - 80, 20);
    txt("ゲームの説明", width / 2, 85, 38, color(255, 220, 80));
    for (int i = 0; i < help.length; i++) {
      txtL(help[i], 100, 145 + i * 36, 24, color(255));
    }
    txt("エンターキー または クリック で もどる", width / 2, height - 70, 22, color(200, 230, 255));
  }

  // 専用タイトル／説明フェーズのキー処理。処理したら true
  boolean menuPhaseKey(int kc) {
    if (phase == PH_MENU) {
      int c = menu.keyNav(kc);
      if (c >= 0) menuChosen(c);
      return true;
    }
    if (phase == PH_HELP) {
      if (kc == K_ENTER || kc == K_SPACE) phase = PH_MENU;
      return true;
    }
    return false;
  }

  boolean menuPhaseMouse() {
    if (phase == PH_MENU) {
      int c = menu.click();
      if (c >= 0) menuChosen(c);
      return true;
    }
    if (phase == PH_HELP) {
      phase = PH_MENU;
      return true;
    }
    return false;
  }

  void menuChosen(int c) {
    if (c == 0) onStart();
    else if (c == 1) phase = PH_HELP;
    else if (c == 2) changeScene(selectScene);
  }

  void startResult() {
    phase = PH_RESULT;
    resT = 0;
    resMenu.sel = 0;
  }

  void drawResultMenu() {
    resT++;
    resMenu.display(26);
  }

  void resultKey(int kc) {
    if (resT < 30) return;
    handleResult(resMenu.keyNav(kc));
  }

  void resultMouse() {
    if (resT < 30) return;
    handleResult(resMenu.click());
  }

  void handleResult(int c) {
    if (c == 0) restart();
    else if (c == 1) changeScene(selectScene);
  }

  void drawCountdownText(String s, float y) {
    if (s.length() == 0) return;
    float sz = (s.length() > 1) ? 100 : 150;
    txtO(s, width / 2, y, sz, color(255, 230, 60), color(90, 40, 0));
  }
}

// ============================================================
//  1. 激熱！メガトンバーニング
// ============================================================
class Game1 extends MiniGame {
  final int G_COUNT = 2, G_PLAY = 3, G_DASH = 4;
  final float GX = 40, GY = 110, GW = 64, GH = 330, RED_H = 36, MH = 14;
  final int PLAY_FRAMES = 1200;   // 20秒
  final int DASH_FRAMES = 300;
  final float[] WALL_D = {60, 350, 900};          // 壁の位置(km)
  final float[] WALL_REQ = {0.40, 0.75, 0.999};   // 壁を壊すのに必要なパワー
  final String[] RES_TXT = {"great", "nice", "miss...", ":("};

  int cdT, playT, attempts, clicks, popT, lastRes, lastResT, greatN, niceN;
  int[] res = new int[8];
  float gaugeSum, m, mdir;
  float power, freeD, finalD, dashS, distKm, scroll, groundOff, bump;
  int curWall, pauseT, stopT, shake, msgT;
  boolean blocked, stopped;
  boolean[] gone = new boolean[3];
  String msg = "";
  ArrayList<Particle> parts = new ArrayList<Particle>();
  ArrayList<Particle> flames = new ArrayList<Particle>();   // 主人公がまとう炎
  final float JUMP_H = 110;                                 // ジャンプの高さ
  float lift = 0;                                           // 現在の浮き上がり量

  Game1() {
    super("激熱！メガトンバーニング", new String[] {
      "20秒の制限時間のあいだに、左側にある上下するゲージを",
      "赤い枠のいちばん上でクリックして止めろ！",
      "（クリックする場所は画面のどこでもOK）",
      "これを8回くりかえしたら、残り時間は連打！連打！",
      "ゲージが上にあるほど・連打が多いほど、",
      "主人公は長い距離をダッシュしていくぞ！",
      "途中に立ちはだかる壁は、スピードが足りないと壊せない！",
      "目指せカンスト999.99km！"
    }, 255, 120, 40, 120, 20, 20);
  }

  void onStart() {
    startGame();
  }
  void restart() {
    startGame();
  }

  void startGame() {
    phase = G_COUNT;
    cdT = 0;
    playT = 0;
    attempts = 0;
    clicks = 0;
    gaugeSum = 0;
    greatN = 0;
    niceN = 0;
    for (int i = 0; i < 8; i++) res[i] = -1;
    m = GH - MH;
    mdir = -1;
    lastResT = 0;
    popT = 0;
    groundOff = 0;
    parts.clear();
  }

  void show() {
    if (phase == PH_MENU) {
      showMenuScreen();
      return;
    }
    if (phase == PH_HELP) {
      showHelpScreen();
      return;
    }
    if (phase == G_COUNT) {
      cdT++;
      if (cdT >= 300) {
        phase = G_PLAY;
        playT = 0;
      }
      drawField(0);
      drawHero(0, 0);
      String s = "";
      if (cdT < 60) s = "3";
      else if (cdT < 120) s = "2";
      else if (cdT < 180) s = "1";
      else if (cdT < 240) s = "スタート";
      drawCountdownText(s, 140);
    } else if (phase == G_PLAY) {
      updatePlay();
      if (phase == G_PLAY) drawPlay();
      else drawDash();
    } else if (phase == G_DASH) {
      updateDash();
      if (phase == G_DASH) drawDash();
      else drawResult1();
    } else if (phase == PH_RESULT) {
      drawResult1();
    }
  }

  void onKeyDown(int kc) {
    if (menuPhaseKey(kc)) return;
    if (phase == PH_RESULT) resultKey(kc);
  }

  void onMouse() {
    if (menuPhaseMouse()) return;
    if (phase == G_PLAY) {
      if (attempts < 8) evalGauge();
      else {
        clicks++;
        popT = 6;
      }
    } else if (phase == PH_RESULT) {
      resultMouse();
    }
  }

  // ---------- ゲージ ----------
  void evalGauge() {
    int r;
    if (m <= 24) {
      r = 0;
      gaugeSum += 1.0;
      greatN++;
    } else if (m <= 56) {
      r = 1;
      gaugeSum += 0.6;
      niceN++;
    } else if (m <= 130) {
      r = 2;
      gaugeSum += 0.25;
    } else {
      r = 3;
    }
    res[attempts] = r;
    attempts++;
    lastRes = r;
    lastResT = 50;
  }

  color resColor(int r) {
    if (r == 0) return color(255, 210, 0);
    if (r == 1) return color(70, 200, 110);
    if (r == 2) return color(140, 140, 150);
    return color(90, 110, 230);
  }

  void updatePlay() {
    playT++;
    if (attempts < 8) {
      m += 10.0 * mdir;
      float mx = GH - MH;
      if (m >= mx) {
        m = mx;
        mdir = -1;
      }
      if (m <= 0) {
        m = 0;
        mdir = 1;
      }
    }
    if (lastResT > 0) lastResT--;
    if (popT > 0) popT--;
    if (playT >= PLAY_FRAMES) startDash();
  }

  // ---------- 描画（共通） ----------
  void drawField(float off) {
    gradBG(color(160, 210, 255), color(235, 245, 255));
    noStroke();
    fill(110, 165, 95);
    rect(0, 328, width, height - 328);
    stroke(90, 140, 75);
    strokeWeight(3);
    for (int i = 0; i < 10; i++) {
      float x = i * 120 - off;
      line(x, 328, x - 60, height);
    }
    noStroke();
    strokeWeight(1);
  }

  void drawHero(float ox, float oy) {
    noStroke();
    fill(0);
    rect(width / 2 - 28 + ox, height / 2 - 28 + oy, 56, 56);
  }

  void drawPlay() {
    drawField(0);
    float ox = 0, oy = 0;
    if (attempts >= 8 && popT > 0) {
      ox = random(-4, 4);
      oy = random(-4, 4);
    }
    drawHero(ox, oy);
    int remain = max(0, PLAY_FRAMES - playT);
    int sec = ceil(remain / 60.0);
    txt("のこり時間", width / 2, 20, 20, color(40, 50, 70));
    txtO(str(sec), width / 2, 62, 64, sec <= 5 ? color(255, 60, 60) : color(255), color(30, 40, 70));
    if (attempts < 8) drawGauge();
    else drawMash();
  }

  void drawGauge() {
    stroke(255);
    strokeWeight(5);
    fill(0);
    rect(GX, GY, GW, GH);
    noStroke();
    fill(225, 30, 30);
    rect(GX + 3, GY + 3, GW - 6, RED_H - 3);
    fill(255);
    rect(GX + 3, GY + m, GW - 6, MH);
    // 結果表示
    if (lastResT > 0) {
      txtO(RES_TXT[lastRes], GX + GW + 120, GY + 50, 56, resColor(lastRes), color(20, 20, 40));
    }
    // 回数ボックス
    for (int i = 0; i < 8; i++) {
      float bxp = GX + i * 24;
      float byp = GY + GH + 20;
      if (res[i] >= 0) {
        noStroke();
        fill(resColor(res[i]));
      } else {
        stroke(60, 70, 90);
        strokeWeight(2);
        noFill();
      }
      rect(bxp, byp, 18, 18, 4);
    }
    noStroke();
    strokeWeight(1);
    txtL(attempts + " / 8", GX, GY + GH + 58, 22, color(40, 50, 70));
  }

  void drawMash() {
    txtO("連打！", width / 2, 150, 150, color(255, 60, 40), color(255));
    txtO(clicks + " 回", width / 2, 400, 64, color(255), color(30, 40, 70));
  }

  // ---------- ダッシュ ----------
  void startDash() {
    phase = G_DASH;
    float gRatio;
    if (greatN >= 7) gRatio = 1.0;
    else gRatio = min(0.95, gaugeSum / 7.0 * 0.95);
    float mRatio = min(1.0, clicks / 100.0);
    if (gRatio >= 1.0 && mRatio >= 1.0) power = 1.0;
    else power = min(0.998, 0.6 * gRatio + 0.4 * mRatio);
    if (power >= 1.0) freeD = 999.99;
    else freeD = 999.99 * pow(power, 2.2);
    dashS = 0;
    distKm = 0;
    finalD = 0;
    scroll = 0;
    curWall = 0;
    pauseT = 0;
    stopT = 0;
    shake = 0;
    msgT = 0;
    bump = 0;
    blocked = false;
    stopped = false;
    msg = "";
    for (int i = 0; i < 3; i++) gone[i] = false;
    parts.clear();
    flames.clear();
    lift = 0;
  }

  // 体中から炎を出す
  void spawnFlames() {
    float cx = width / 2 + bump;
    float cy = height / 2 - lift;
    int n = (pauseT > 0) ? 3 : 7;
    for (int i = 0; i < n; i++) {
      float a = random(TWO_PI);
      float px = cx + cos(a) * random(14, 36);
      float py = cy + sin(a) * random(14, 36);
      float q = random(1);
      color c;
      if (q < 0.4) c = color(255, 70, 20);
      else if (q < 0.75) c = color(255, 150, 20);
      else c = color(255, 230, 80);
      flames.add(new Particle(px, py, -random(1, 4) - scroll * 0.15, random(-2.5, 0.5), -0.06, random(12, 26), (int) random(12, 22), c));
    }
  }

  void updateDash() {
    // 1回だけジャンプして、空中をダッシュ（止まったら着地）
    if (stopped) lift = max(0, lift - 7);
    else lift = JUMP_H * pow(max(0, sin(PI * dashS)), 0.7);
    updateParts(flames);
    if (!stopped) spawnFlames();
    if (shake > 0) shake--;
    if (bump < 0) bump = min(0, bump + 1.2);
    if (msgT > 0) msgT--;
    updateParts(parts);
    if (stopped) {
      scroll = 0;
      stopT++;
      if (stopT >= 120) startResult();
      return;
    }
    if (pauseT > 0) {
      pauseT--;
      scroll *= 0.7;
      groundOff = (groundOff + scroll) % 120;
      if (pauseT == 0 && blocked) {
        stopped = true;
        stopT = 0;
        finalD = min(999.99, fl2(distKm));
      }
      return;
    }
    dashS += 1.0 / DASH_FRAMES;
    if (dashS > 1) dashS = 1;
    float prev = distKm;
    float d = freeD * (1 - pow(1 - dashS, 3));
    if (curWall < 3 && d >= WALL_D[curWall]) {
      d = WALL_D[curWall];
      if (freeD > 0) dashS = 1 - pow(1 - d / freeD, 1.0 / 3.0);
      if (power >= WALL_REQ[curWall]) {
        // 壁を破壊！
        gone[curWall] = true;
        for (int i = 0; i < 40; i++) {
          color pc = (curWall == 0) ? color(175, 125, 65) : (curWall == 1 ? color(185, 80, 60) : color(140, 150, 175));
          parts.add(new Particle(width / 2 + 40, random(90, 320), random(-4, 13), random(-9, 4), 0.45, random(6, 15), 70, pc));
        }
        curWall++;
        pauseT = 40;
        shake = 30;
        msg = "ドカーン！壁を破壊！";
        msgT = 70;
      } else {
        blocked = true;
        pauseT = 45;
        shake = 20;
        bump = -22;
        msg = "壁が壊せない…！";
        msgT = 120;
      }
    }
    distKm = d;
    scroll = 8 + min(60, (d - prev) * 6);
    groundOff = (groundOff + scroll) % 120;
    if (dashS >= 1 && pauseT == 0) {
      stopped = true;
      stopT = 0;
      finalD = min(999.99, fl2(distKm));
    }
  }

  void drawWall(int i, float x) {
    float top = 328 - 250;
    noStroke();
    if (i == 0) fill(175, 125, 65);
    else if (i == 1) fill(185, 80, 60);
    else fill(125, 135, 160);
    rect(x, top, 70, 250);
    stroke(0, 0, 0, 90);
    strokeWeight(2);
    for (float yy = top + 25; yy < 328; yy += 25) {
      line(x, yy, x + 70, yy);
    }
    if (i == 1) {
      int row = 0;
      for (float yy = top; yy < 328; yy += 25) {
        float off = (row % 2 == 0) ? 23 : 47;
        line(x + off, yy, x + off, yy + 25);
        row++;
      }
    }
    noStroke();
    if (i == 2) {
      fill(50);
      for (float yy = top + 12; yy < 328; yy += 25) {
        ellipse(x + 9, yy, 6, 6);
        ellipse(x + 61, yy, 6, 6);
      }
    }
    strokeWeight(1);
  }

  void drawDash() {
    float ox = 0, oy = 0;
    if (shake > 0) {
      ox = random(-7, 7);
      oy = random(-7, 7);
    }
    pushMatrix();
    translate(ox, oy);
    drawField(groundOff);
    for (int i = 0; i < 3; i++) {
      if (gone[i]) continue;
      float wxp = width / 2 + 28 + (WALL_D[i] - distKm) * 6;
      if (wxp < width + 5) drawWall(i, wxp);
    }
    // 影（高く跳ぶほど小さく薄く）
    float shr = 1 - lift / (JUMP_H * 1.8);
    noStroke();
    fill(0, 0, 0, 70);
    ellipse(width / 2 + bump, 334, 80 * shr, 14 * shr);
    // 炎のオーラ
    float hcx = width / 2 + bump;
    float hcy = height / 2 - lift;
    if (!stopped || lift > 0) {
      float pu = 1 + 0.1 * sin(frameCount * 0.5);
      fill(255, 110, 20, 70);
      ellipse(hcx, hcy, 140 * pu, 140 * pu);
      fill(255, 200, 60, 70);
      ellipse(hcx, hcy, 100 * pu, 100 * pu);
    }
    // 主人公（前傾・後傾しながら飛ぶ）
    float tilt = stopped ? 0 : -0.3 * cos(PI * dashS);
    pushMatrix();
    translate(hcx, hcy);
    rotate(tilt);
    fill(0);
    rect(-28, -28, 56, 56);
    popMatrix();
    // 体中の炎
    for (Particle p : flames) {
      float ratio = p.life / (float) p.maxLife;
      float fs = p.sz * (0.4 + 0.6 * ratio);
      fill(red(p.c), green(p.c), blue(p.c), 220 * ratio);
      ellipse(p.x, p.y, fs, fs * 1.3);
    }
    if (!stopped && pauseT == 0 && scroll > 14) {
      stroke(255, 255, 255, 170);
      strokeWeight(3);
      for (int i = 0; i < 10; i++) {
        float lx = random(0, width / 2 - 50);
        float ly = random(60, height - 60);
        line(lx, ly, lx - scroll * 2, ly);
      }
      strokeWeight(1);
    }
    noStroke();
    for (Particle p : parts) {
      fill(p.c);
      pushMatrix();
      translate(p.x, p.y);
      rotate(p.rot);
      rect(-p.sz / 2, -p.sz / 2, p.sz, p.sz);
      popMatrix();
    }
    popMatrix();
    // HUD
    txtO(nf(distKm, 0, 2) + " km", width / 2, 60, 70, color(255), color(30, 40, 70));
    if (msgT > 0) txtO(msg, width / 2, 170, 56, color(255, 230, 60), color(90, 30, 0));
    if (stopped && stopT > 10) txtO("ストップ！", width / 2, 450, 50, color(255), color(30, 40, 70));
  }

  // ---------- リザルト ----------
  void drawResult1() {
    gradBG(color(40, 20, 70), color(200, 80, 40));
    txt("今回のスコア", width / 2, 55, 34, color(255));
    txtO(nf(finalD, 0, 2) + " km", width / 2, 145, 100, color(255, 230, 60), color(90, 30, 0));
    if (finalD >= 999.98) {
      txtO("★ カンスト！！ ★", width / 2, 245, 46, color(255, 130, 210), color(60, 0, 40));
    }
    txt("great: " + greatN + "回    nice: " + niceN + "回    連打: " + clicks + "回", width / 2, 325, 28, color(255));
    noStroke();
    fill(0);
    rect(width / 2 - 28, 375, 56, 56);
    drawResultMenu();
  }
}

// ============================================================
//  2. とれたて！フルーツフェスティバル
// ============================================================
class Basket {
  float x, y, px, py, kx, ky, vx, vy;
  final float w = 110, h = 70, wt = 14;
  int score = 0;
  int freezeT = 0;   // 爆弾で動けない残りフレーム
  color col;
  String label;
  Basket(float x0, float y0, color c, String l) {
    x = x0;
    y = y0;
    px = x;
    py = y;
    col = c;
    label = l;
  }
}

class Fruit {
  float x, y, px, py, vx, vy, r, rot, vr;
  int type;
  boolean bounced = false;
}

class Popup {
  float x, y;
  String s;
  int life = 45;
  color c;
  Popup(float x, float y, String s, color c) {
    this.x = x;
    this.y = y;
    this.s = s;
    this.c = c;
  }
}

class Game2 extends MiniGame {
  final int G_COUNT = 2, G_PLAY = 3;
  final int TOTAL = 3600;   // 1分
  int cdT, playT, spawnT, spurtT;
  Basket b1, b2;
  ArrayList<Fruit> fruits = new ArrayList<Fruit>();
  ArrayList<Popup> pops = new ArrayList<Popup>();
  int[] bunt = {color(255, 90, 90), color(255, 210, 70), color(90, 200, 120), color(90, 160, 255)};

  Game2() {
    super("とれたて！フルーツフェスティバル", new String[] {
      "1分間、バスケットを動かして、落ちてくる",
      "フルーツをバスケットの『上から』入れよう！",
      "1P（白）　　： W（上） A（左） S（下） D（右）",
      "2P（青）　　： 矢印キー（上・左・下・右）",
      "フルーツは1点、黄金に輝くリンゴは5点！",
      "たまに降ってくる『爆弾』は取っちゃダメ！-3点＆1秒動けなくなる。",
      "横や下にぶつけると、フルーツは吹っ飛んでしまうよ。",
      "バスケット同士がぶつかると、ちょっと跳ね返る。",
      "残り20秒になると、フルーツが速く・多くなる！"
    }, 60, 170, 110, 20, 70, 70);
  }

  void onStart() {
    startGame();
  }
  void restart() {
    startGame();
  }

  void startGame() {
    phase = G_COUNT;
    cdT = 0;
    playT = 0;
    spawnT = 0;
    spurtT = 0;
    fruits.clear();
    pops.clear();
    b1 = new Basket(width * 0.25 - 55, height - 130, color(255), "1P");
    b2 = new Basket(width * 0.75 - 55, height - 130, color(70, 130, 255), "2P");
  }

  void show() {
    if (phase == PH_MENU) {
      showMenuScreen();
      return;
    }
    if (phase == PH_HELP) {
      showHelpScreen();
      return;
    }
    if (phase == G_COUNT) {
      cdT++;
      if (cdT >= 300) {
        phase = G_PLAY;
        playT = 0;
      }
      drawScene();
      String s = "";
      if (cdT < 60) s = "3";
      else if (cdT < 120) s = "2";
      else if (cdT < 180) s = "1";
      else if (cdT < 240) s = "スタート";
      drawCountdownText(s, 220);
    } else if (phase == G_PLAY) {
      updatePlay();
      if (phase == G_PLAY) drawScene();
      else drawResult2();
    } else if (phase == PH_RESULT) {
      drawResult2();
    }
  }

  void onKeyDown(int kc) {
    if (menuPhaseKey(kc)) return;
    if (phase == PH_RESULT) resultKey(kc);
  }

  void onMouse() {
    if (menuPhaseMouse()) return;
    if (phase == PH_RESULT) resultMouse();
  }

  // ---------- 更新 ----------
  void updatePlay() {
    playT++;
    int remain = TOTAL - playT;
    if (remain <= 0) {
      startResult();
      return;
    }
    boolean spurt = remain <= 1200;
    if (remain == 1200) spurtT = 110;
    if (spurtT > 0) spurtT--;

    spawnT++;
    int interval = spurt ? 20 : 38;
    if (spawnT >= interval) {
      spawnT = 0;
      spawnFruit(spurt);
      if (spurt && random(1) < 0.35) spawnFruit(spurt);
    }

    moveBasket(b1, keys['A'], keys['D'], keys['W'], keys['S']);
    moveBasket(b2, keys[K_LEFT], keys[K_RIGHT], keys[K_UP], keys[K_DOWN]);
    resolveBaskets();
    b1.vx = b1.x - b1.px;
    b1.vy = b1.y - b1.py;
    b2.vx = b2.x - b2.px;
    b2.vy = b2.y - b2.py;

    for (int i = fruits.size() - 1; i >= 0; i--) {
      Fruit f = fruits.get(i);
      f.px = f.x;
      f.py = f.y;
      if (!f.bounced) {
        f.y += f.vy;
      } else {
        f.vy += 0.12;
        f.vx *= 0.995;
        f.x += f.vx;
        f.y += f.vy;
      }
      f.rot += f.vr;
      boolean caught = false;
      for (int k = 0; k < 2 && !caught; k++) {
        Basket b = (k == 0) ? b1 : b2;
        if (tryCatch(f, b)) caught = true;
        else collideFruit(f, b);
      }
      if (caught) {
        fruits.remove(i);
        continue;
      }
      if (f.y > height + 60 || f.x < -80 || f.x > width + 80) fruits.remove(i);
    }
    for (int i = pops.size() - 1; i >= 0; i--) {
      Popup p = pops.get(i);
      p.y -= 1.2;
      p.life--;
      if (p.life <= 0) pops.remove(i);
    }
  }

  void spawnFruit(boolean spurt) {
    Fruit f = new Fruit();
    float rr = random(1);
    if (rr < 0.05) f.type = 5;          // 黄金のリンゴ
    else if (rr < 0.11) f.type = 6;     // 爆弾（約6%）
    else f.type = (int) random(5);
    f.r = RADII[f.type];
    f.x = random(40, width - 40);
    f.y = -30;
    f.px = f.x;
    f.py = f.y;
    f.vy = spurt ? random(2.6, 3.4) : random(1.6, 2.3);
    f.vx = 0;
    f.vr = random(-0.03, 0.03);
    fruits.add(f);
  }

  void moveBasket(Basket b, boolean l, boolean r, boolean u, boolean d) {
    b.px = b.x;
    b.py = b.y;
    if (b.freezeT > 0) {          // 爆弾を取ると1秒間動けない
      b.freezeT--;
      l = false;
      r = false;
      u = false;
      d = false;
    }
    float sp = 5.2;
    if (l) b.x -= sp;
    if (r) b.x += sp;
    if (u) b.y -= sp;
    if (d) b.y += sp;
    b.x += b.kx;
    b.y += b.ky;
    b.kx *= 0.82;
    b.ky *= 0.82;
    clampBasket(b);
  }

  void clampBasket(Basket b) {
    b.x = constrain(b.x, 0, width - b.w);
    b.y = constrain(b.y, 70, height - b.h);
  }

  void resolveBaskets() {
    float ox = min(b1.x + b1.w, b2.x + b2.w) - max(b1.x, b2.x);
    float oy = min(b1.y + b1.h, b2.y + b2.h) - max(b1.y, b2.y);
    if (ox > 0 && oy > 0) {
      if (ox < oy) {
        float dir = (b1.x + b1.w / 2 < b2.x + b2.w / 2) ? -1 : 1;
        b1.x += dir * ox / 2;
        b2.x -= dir * ox / 2;
        b1.kx += dir * 6;
        b2.kx -= dir * 6;
      } else {
        float dir = (b1.y + b1.h / 2 < b2.y + b2.h / 2) ? -1 : 1;
        b1.y += dir * oy / 2;
        b2.y -= dir * oy / 2;
        b1.ky += dir * 6;
        b2.ky -= dir * 6;
      }
      clampBasket(b1);
      clampBasket(b2);
    }
  }

  boolean inMouth(Basket b, float fx) {
    return fx >= b.x + b.wt - 6 && fx <= b.x + b.w - b.wt + 6;
  }

  // バスケットの上側(口)から入ったら得点
  boolean tryCatch(Fruit f, Basket b) {
    if (f.bounced) return false;
    float relPrev = f.py - b.py;
    float rel = f.y - b.y;
    if (relPrev < 4 && rel >= 4 && rel < b.h - b.wt && inMouth(b, f.x)) {
      if (f.type == 6) {            // 爆弾：-3点＆1秒間バスケット停止
        b.score -= 3;
        b.freezeT = 60;
        b.kx = 0;
        b.ky = 0;
        pops.add(new Popup(b.x + b.w / 2, b.y - 40, "-3", color(255, 70, 70)));
        pops.add(new Popup(b.x + b.w / 2, b.y + 20, "ドカン！", color(255, 170, 0)));
        return true;
      }
      int pts = (f.type == 5) ? 5 : 1;
      b.score += pts;
      pops.add(new Popup(b.x + b.w / 2, b.y - 40, "+" + pts, f.type == 5 ? color(255, 220, 60) : color(255)));
      return true;
    }
    return false;
  }

  // 横・下・ふち にぶつかったら吹っ飛ぶ
  void collideFruit(Fruit f, Basket b) {
    float rel = f.y - b.y;
    if (!f.bounced && rel < 4 && inMouth(b, f.x)) return;   // 口の真上は通過
    hitRect(f, b, b.x, b.y, b.wt, b.h);
    hitRect(f, b, b.x + b.w - b.wt, b.y, b.wt, b.h);
    hitRect(f, b, b.x + b.wt, b.y + b.h - b.wt, b.w - 2 * b.wt, b.wt);
  }

  void hitRect(Fruit f, Basket b, float rx, float ry, float rw, float rh) {
    float cx = constrain(f.x, rx, rx + rw);
    float cy = constrain(f.y, ry, ry + rh);
    float dx = f.x - cx;
    float dy = f.y - cy;
    float d2 = dx * dx + dy * dy;
    if (d2 >= f.r * f.r) return;
    float nx, ny;
    if (d2 < 0.0001) {
      float l = f.x - rx;
      float rr = rx + rw - f.x;
      float t = f.y - ry;
      float bt = ry + rh - f.y;
      float mn = min(min(l, rr), min(t, bt));
      if (mn == l) {
        nx = -1;
        ny = 0;
      } else if (mn == rr) {
        nx = 1;
        ny = 0;
      } else if (mn == t) {
        nx = 0;
        ny = -1;
      } else {
        nx = 0;
        ny = 1;
      }
      f.x += nx * (mn + f.r);
      f.y += ny * (mn + f.r);
    } else {
      float d = sqrt(d2);
      nx = dx / d;
      ny = dy / d;
      f.x = cx + nx * f.r;
      f.y = cy + ny * f.r;
    }
    float vx = f.vx;
    float vy = f.vy;
    float vn = vx * nx + vy * ny;
    if (vn < 0) {
      vx -= 1.7 * vn * nx;
      vy -= 1.7 * vn * ny;
    }
    vx += b.vx * 0.9 + nx * 3.0;
    vy += b.vy * 0.9 + ny * 3.0;
    f.vx = constrain(vx, -14, 14);
    f.vy = constrain(vy, -14, 14);
    f.vr = random(-0.3, 0.3);
    f.bounced = true;
  }

  // ---------- 描画 ----------
  void drawBasket(Basket b) {
    stroke(20, 30, 30);
    strokeWeight(2);
    fill(b.col);
    rect(b.x, b.y, b.wt, b.h, 3);
    rect(b.x + b.w - b.wt, b.y, b.wt, b.h, 3);
    rect(b.x + b.wt, b.y + b.h - b.wt, b.w - 2 * b.wt, b.wt, 3);
    noStroke();
    fill(0, 0, 0, 55);
    rect(b.x + b.wt, b.y, b.w - 2 * b.wt, b.h - b.wt);
    stroke(0, 0, 0, 60);
    strokeWeight(1);
    for (int i = 1; i < 4; i++) {
      float yy = b.y + i * (b.h - b.wt) / 4.0;
      line(b.x, yy, b.x + b.wt, yy);
      line(b.x + b.w - b.wt, yy, b.x + b.w, yy);
    }
    noStroke();
    if (b.freezeT > 0) {
      noStroke();
      fill(255, 90, 0, (frameCount / 4) % 2 == 0 ? 150 : 60);
      rect(b.x - 4, b.y - 4, b.w + 8, b.h + 8, 6);
      txtO("×", b.x + b.w / 2, b.y + 28, 40, color(255, 230, 60), color(90, 0, 0));
    }
    color lc = (b.label.equals("1P")) ? color(255) : color(150, 200, 255);
    txtO(b.label, b.x + b.w / 2, b.y - 20, 28, lc, color(0));
  }

  void drawScene() {
    gradBG(color(40, 110, 90), color(20, 60, 60));
    // 飾り（フェスティバル風のガーランド）
    noStroke();
    for (int i = 0; i < width; i += 48) {
      fill(bunt[(i / 48) % 4]);
      triangle(i, 58, i + 42, 58, i + 21, 86);
    }
    for (Fruit f : fruits) drawFruit(f.type, f.x, f.y, f.r, f.rot);
    drawBasket(b1);
    drawBasket(b2);
    for (Popup p : pops) txtO(p.s, p.x, p.y, 34, p.c, color(0));
    // HUD
    noStroke();
    fill(0, 0, 0, 140);
    rect(0, 0, width, 56);
    txtL("1P  " + b1.score + " 点", 30, 28, 34, color(255));
    textAlign(RIGHT, CENTER);
    textSize(34);
    fill(130, 190, 255);
    text("2P  " + b2.score + " 点", width - 30, 28);
    int remain = max(0, TOTAL - playT);
    int sec = ceil(remain / 60.0);
    txt("残り時間", width / 2, 13, 15, color(220));
    txt(str(sec), width / 2, 37, 38, sec <= 10 ? color(255, 90, 90) : color(255));
    if (spurtT > 0 && (spurtT / 8) % 2 == 0) {
      txtO("ラストスパート！", width / 2, 230, 72, color(255, 230, 60), color(120, 40, 0));
    }
  }

  void drawResult2() {
    gradBG(color(40, 110, 90), color(20, 50, 80));
    String head;
    color hc;
    int sc;
    if (b1.score > b2.score) {
      head = "1Pの勝利！";
      hc = color(255);
      sc = b1.score;
    } else if (b2.score > b1.score) {
      head = "2Pの勝利！";
      hc = color(130, 190, 255);
      sc = b2.score;
    } else {
      head = "引き分け！";
      hc = color(255, 230, 60);
      sc = b1.score;
    }
    txtO(head, width / 2, 110, 92, hc, color(10, 30, 40));
    if (b1.score == b2.score) txt("両者 " + sc + " 点", width / 2, 220, 60, color(255));
    else txt("点数： " + sc + " 点", width / 2, 220, 60, color(255));
    txt("1P  " + b1.score + " 点      2P  " + b2.score + " 点", width / 2, 305, 30, color(220, 235, 255));
    for (int t = 0; t < 6; t++) {
      drawFruit(t, 250 + t * 92, 400, RADII[t] * 1.3, 0);
    }
    drawResultMenu();
  }
}

// ============================================================
//  3. 刹那の早撃ち
// ============================================================
class Game3 extends MiniGame {
  final int G_MODE = 2, G_DIFF = 3, G_NOTE = 4, G_COUNT = 5, G_WAIT = 6, G_SIGNAL = 7, G_SHOT = 8;
  final int GROUND = 450;
  final int[] ENEMY_FRAMES = {100, 48, 18};   // 初級・中級・上級
  Menu modeMenu, diffMenu, noteMenu;
  int mode = 0, diff = 0;
  int cdT, waitT, waitTarget, sigFrames, shotT, winner, shownFrames, foulBy;
  boolean foul;

  Game3() {
    super("刹那の早撃ち", new String[] {
      "画面中央に『！』が出た瞬間に、すばやくスペースキーで撃て。",
      "先に撃った方の勝ち。",
      "『！』が出る前に撃つと『フライング』で負けだ。",
      "ひとりで遊ぶ時は、難易度（初級・中級・上級）を選べる。",
      "ふたりで遊ぶ時は、1Pがスペース、2Pがエンター。",
      "『！』が出てから撃つまでのフレーム数を競おう。",
      "真のガンマンはどちらになるか...本当の戦いが幕を上げる。"
    }, 255, 150, 60, 120, 40, 60);
    modeMenu = new Menu(new String[] {"1人で遊ぶ", "2人で遊ぶ", "もどる"}, 1, width / 2, 230, 380, 64, 0, 18);
    diffMenu = new Menu(new String[] {"初級", "中級", "上級", "もどる"}, 1, width / 2, 200, 380, 64, 0, 18);
    noteMenu = new Menu(new String[] {"はじめる", "もどる"}, 1, width / 2, 380, 380, 64, 0, 18);
  }

  void onStart() {
    phase = G_MODE;
    modeMenu.sel = 0;
  }

  void restart() {
    startRound();
  }

  void startRound() {
    phase = G_COUNT;
    cdT = 0;
    waitT = 0;
    sigFrames = 0;
    shotT = 0;
    winner = 0;
    shownFrames = 0;
    foul = false;
    foulBy = 0;
  }

  void startShot() {
    phase = G_SHOT;
    shotT = 0;
  }

  void show() {
    if (phase == PH_MENU) {
      showMenuScreen();
      return;
    }
    if (phase == PH_HELP) {
      showHelpScreen();
      return;
    }
    if (phase == G_MODE) {
      gradBG(c1, c2);
      txtO("遊ぶ人数を選んでください", width / 2, 120, 44, color(255), color(40, 10, 30));
      modeMenu.display(28);
      return;
    }
    if (phase == G_DIFF) {
      gradBG(c1, c2);
      txtO("難易度を選んでください", width / 2, 110, 44, color(255), color(40, 10, 30));
      diffMenu.display(28);
      return;
    }
    if (phase == G_NOTE) {
      gradBG(c1, c2);
      txtO("ふたりで遊ぶ", width / 2, 100, 48, color(255), color(40, 10, 30));
      txt("1Pの人はスペースキーを、2Pの人はエンターキーを使って遊びます", width / 2, 210, 26, color(255));
      txt("『！』が出る前に撃つとフライングで負けです", width / 2, 270, 24, color(255, 230, 120));
      noteMenu.display(28);
      return;
    }

    // ---- ここから対戦中 ----
    if (phase == G_COUNT) {
      cdT++;
      if (cdT >= 240) {
        phase = G_WAIT;
        waitT = 0;
        waitTarget = (int) random(480, 901);   // 8〜15秒
      }
    } else if (phase == G_WAIT) {
      waitT++;
      if (waitT >= waitTarget) {
        phase = G_SIGNAL;
        sigFrames = 0;
      }
    }
    if (phase == G_SIGNAL) {
      sigFrames++;
      if (mode == 0 && sigFrames > ENEMY_FRAMES[diff]) {
        winner = 2;
        foul = false;
        shownFrames = ENEMY_FRAMES[diff];
        startShot();
      }
    }
    if (phase == G_SHOT) {
      shotT++;
      if (shotT >= 110) startResult();
    }

    if (phase == PH_RESULT) {
      drawResult3();
    } else {
      drawDuel();
      drawOverlay();
    }
  }

  // ---------- 入力 ----------
  void onKeyDown(int kc) {
    if (menuPhaseKey(kc)) return;
    if (phase == G_MODE) chooseMode(modeMenu.keyNav(kc));
    else if (phase == G_DIFF) chooseDiff(diffMenu.keyNav(kc));
    else if (phase == G_NOTE) chooseNote(noteMenu.keyNav(kc));
    else if (phase == G_COUNT || phase == G_WAIT || phase == G_SIGNAL) shootKey(kc);
    else if (phase == PH_RESULT) resultKey(kc);
  }

  void onMouse() {
    if (menuPhaseMouse()) return;
    if (phase == G_MODE) chooseMode(modeMenu.click());
    else if (phase == G_DIFF) chooseDiff(diffMenu.click());
    else if (phase == G_NOTE) chooseNote(noteMenu.click());
    else if (phase == PH_RESULT) resultMouse();
  }

  void chooseMode(int c) {
    if (c == 0) {
      mode = 0;
      phase = G_DIFF;
      diffMenu.sel = 0;
    } else if (c == 1) {
      mode = 1;
      phase = G_NOTE;
      noteMenu.sel = 0;
    } else if (c == 2) {
      phase = PH_MENU;
    }
  }

  void chooseDiff(int c) {
    if (c >= 0 && c <= 2) {
      diff = c;
      startRound();
    } else if (c == 3) {
      phase = G_MODE;
    }
  }

  void chooseNote(int c) {
    if (c == 0) startRound();
    else if (c == 1) phase = G_MODE;
  }

  void shootKey(int kc) {
    int who = 0;
    if (kc == K_SPACE) who = 1;
    else if (kc == K_ENTER && mode == 1) who = 2;
    if (who == 0) return;
    if (phase == G_COUNT && cdT < 180) return;   // 3,2,1の間は無効
    if (phase == G_SIGNAL) {
      if (winner != 0) return;
      winner = who;
      foul = false;
      shownFrames = sigFrames;
      startShot();
    } else {
      // 『！』が出る前に撃った → フライング
      foul = true;
      foulBy = who;
      winner = (who == 1) ? 2 : 1;
      startShot();
    }
  }

  // ---------- 描画 ----------
  void drawFighter(int side, color col, float fall, String label, boolean hat) {
    float cx = (side == 1) ? 190 : 770;
    float dir = (side == 1) ? 1 : -1;
    pushMatrix();
    translate(cx, GROUND);
    rotate(-dir * fall);
    noStroke();
    fill(col);
    rect(-32, -64, 64, 64);
    fill(60);
    if (dir > 0) rect(24, -40, 36, 10);
    else rect(-60, -40, 36, 10);
    fill(255);
    rect(dir > 0 ? 8 : -20, -50, 12, 12);
    fill(0);
    rect(dir > 0 ? 14 : -20, -48, 6, 8);
    if (hat) {
      fill(90, 50, 30);
      rect(-38, -72, 76, 8);
      rect(-22, -94, 44, 24);
    }
    popMatrix();
    if (fall == 0 && label.length() > 0) {
      txtO(label, cx, GROUND - 92, 30, color(255), color(0));
    }
  }

  void drawDuel() {
    boolean flash = (phase == G_SIGNAL && sigFrames <= 3);
    gradBG(flash ? color(255, 255, 255) : color(255, 205, 120), flash ? color(255, 240, 200) : color(240, 120, 90));
    noStroke();
    fill(255, 240, 190, 220);
    ellipse(width / 2, 270, 170, 170);
    fill(150, 70, 60);
    triangle(40, GROUND, 170, 320, 300, GROUND);
    triangle(620, GROUND, 760, 300, 900, GROUND);
    fill(130, 55, 55);
    triangle(330, GROUND, 430, 360, 540, GROUND);
    fill(190, 130, 80);
    rect(0, GROUND, width, height - GROUND);
    fill(160, 105, 60);
    rect(0, GROUND, width, 6);
    fill(70, 140, 70);
    rect(500, GROUND - 60, 14, 60, 6);
    rect(484, GROUND - 42, 14, 10, 4);
    rect(484, GROUND - 42, 8, 24, 4);
    rect(516, GROUND - 36, 14, 10, 4);
    rect(522, GROUND - 36, 8, 22, 4);

    float fall1 = 0, fall2 = 0;
    if ((phase == G_SHOT || phase == PH_RESULT) && winner != 0) {
      float f = (phase == PH_RESULT) ? HALF_PI : min(HALF_PI, max(0, shotT - 16) * 0.08);
      if (winner == 1) fall2 = f;
      else fall1 = f;
    }
    color col2 = (mode == 0) ? color(150, 40, 40) : color(50, 90, 230);
    drawFighter(1, color(0), fall1, mode == 1 ? "1P" : "", false);
    drawFighter(2, col2, fall2, mode == 1 ? "2P" : "", mode == 0);

    if (phase == G_SHOT && winner != 0) {
      float dir = (winner == 1) ? 1 : -1;
      float sx = ((winner == 1) ? 190 : 770) + dir * 62;
      float sy = GROUND - 35;
      noStroke();
      if (shotT < 8) {
        fill(255, 240, 100);
        drawStar(sx + dir * 10, sy, 12, 30, shotT);
      }
      if (shotT >= 3 && shotT <= 18) {
        float t = (shotT - 3) / 15.0;
        float tx = ((winner == 1) ? 770 : 190) - dir * 32;
        fill(30);
        ellipse(lerp(sx, tx, t), sy, 14, 9);
      }
    }
  }

  void drawOverlay() {
    if (phase == G_COUNT) {
      if (cdT < 60) txtO("3", width / 2, 200, 150, color(255), color(80, 20, 20));
      else if (cdT < 120) txtO("2", width / 2, 200, 150, color(255), color(80, 20, 20));
      else if (cdT < 180) txtO("1", width / 2, 200, 150, color(255), color(80, 20, 20));
      else txtO("発砲準備...", width / 2, 200, 90, color(255, 240, 120), color(80, 20, 20));
    } else if (phase == G_SIGNAL) {
      txtO("！", width / 2, height / 2 - 40, 300, color(255, 40, 40), color(255));
    } else if (phase == G_SHOT) {
      if (foul) {
        txtO("フライング！", width / 2, 190, 90, color(255, 120, 60), color(60, 0, 0));
      } else if (shotT < 60) {
        txtO("ズドン！", width / 2, 190, 90, color(255, 240, 120), color(80, 20, 20));
      }
    }
    // フレームタイマー（右上）
    if (phase == G_SIGNAL || (phase == G_SHOT && !foul)) {
      int tv = (phase == G_SIGNAL) ? sigFrames : shownFrames;
      noStroke();
      fill(255, 255, 255, 215);
      rect(width - 270, 14, 250, 56, 12);
      txt("フレーム： " + tv, width - 145, 42, 30, color(40, 20, 20));
    }
  }

  void drawResult3() {
    drawDuel();
    noStroke();
    fill(0, 0, 0, 150);
    rect(0, 0, width, height);
    if (mode == 0) {
      if (winner == 1) {
        txtO("勝利！", width / 2, 100, 90, color(255, 230, 60), color(90, 40, 0));
        txtO(shownFrames + " フレーム", width / 2, 250, 110, color(255), color(40, 20, 20));
        txt("（" + nf(shownFrames / 60.0, 1, 3) + " 秒）", width / 2, 350, 36, color(255));
      } else {
        if (foul) txtO("フライング！", width / 2, 170, 90, color(255, 120, 60), color(60, 0, 0));
        txtO("敗北…", width / 2, foul ? 300 : 230, 110, color(130, 170, 255), color(0, 0, 50));
      }
    } else {
      String w = (winner == 1) ? "1P" : "2P";
      if (foul) {
        txtO(foulBy + "Pのフライング！", width / 2, 110, 64, color(255, 120, 60), color(60, 0, 0));
        txtO(w + "の勝利！", width / 2, 250, 100, color(255, 230, 60), color(90, 40, 0));
      } else {
        txtO(w + "の勝利！", width / 2, 100, 100, color(255, 230, 60), color(90, 40, 0));
        txtO(shownFrames + " フレーム", width / 2, 250, 110, color(255), color(40, 20, 20));
        txt("（" + nf(shownFrames / 60.0, 1, 3) + " 秒）", width / 2, 350, 36, color(255));
      }
    }
    drawResultMenu();
  }
}

// ============================================================
//  4. 春風スターグライド
// ============================================================
class Game4 extends MiniGame {
  final int G_COUNT = 2, G_PLAY = 3, G_GOAL = 4;
  final int N = 32;                    // 赤いレールの数（30個以上）
  final float RAIL_LEN = 110;          // 赤いレールの長さ（約3cm）
  final float HERO = 40;
  final float ACC = 0.07, GRAV = 0.08, VMAX = 13.5, VCAP = 22;
  float[] rs = new float[N];
  float[] re = new float[N];
  float goalX, wx, v, camFrozen;
  int cdT, playT, finishT, exitT, nextRail, armed, misses, greats, boostT, greatT, missT, goT;
  boolean wasOnRed, onRed;
  ArrayList<Particle> stars = new ArrayList<Particle>();
  float[] ppx = new float[50];
  float[] ppy = new float[50];
  float[] pps = new float[50];
  float[] ppp = new float[50];

  Game4() {
    super("春風スターグライド", new String[] {
      "エンターキーを押している間、主人公は加速していくよ。",
      "赤いレールの上でエンターキーを押したままだと減速！",
      "赤いレールの上ではキーを離して、慣性で進もう。",
      "赤いレールに入る直前でキーを離し、",
      "出た直後に押し直すと『great!』でさらに加速！",
      "ミス ＝ 赤いレールの上でエンターキーを押した回数。",
      "ゴールまでのタイムをきそおう！",
      "己に打ち勝ち、タイム更新をねらえ！"
    }, 255, 170, 200, 120, 190, 150);
    buildTrack();
    for (int i = 0; i < 50; i++) {
      ppx[i] = random(width);
      ppy[i] = random(height);
      pps[i] = random(0.3, 1.2);
      ppp[i] = random(TWO_PI);
    }
  }

  void onStart() {
    startGame();
  }
  void restart() {
    startGame();
  }

  void buildTrack() {
    java.util.Random rnd = new java.util.Random(20240501);
    float x = 900;
    for (int i = 0; i < N; i++) {
      rs[i] = x;
      re[i] = x + RAIL_LEN;
      x = re[i] + 380 + rnd.nextFloat() * 260;
    }
    goalX = re[N - 1] + 700;
  }

  float trackY(float x) {
    float amp = min(sstep(500, 1100, x), 1 - sstep(goalX - 1000, goalX - 400, x));
    float h = sin(x * 0.0022) * 46 + sin(x * 0.0051 + 1.7) * 24 + sin(x * 0.0011 + 0.6) * 30;
    return 380 - h * amp;
  }

  float heroY() {
    return trackY(wx) - 4 - HERO / 2;
  }

  float win() {
    return max(40, v * 9);
  }

  float camX() {
    return (phase == G_GOAL) ? camFrozen : wx - width / 2;
  }

  void startGame() {
    phase = G_COUNT;
    cdT = 0;
    playT = 0;
    wx = 0;
    v = 0;
    nextRail = 0;
    armed = -1;
    misses = 0;
    greats = 0;
    boostT = 0;
    greatT = 0;
    missT = 0;
    goT = 0;
    exitT = 0;
    finishT = 0;
    wasOnRed = false;
    onRed = false;
    stars.clear();
  }

  void show() {
    if (phase == PH_MENU) {
      showMenuScreen();
      return;
    }
    if (phase == PH_HELP) {
      showHelpScreen();
      return;
    }
    if (phase == G_COUNT) {
      cdT++;
      if (cdT >= 180) {
        phase = G_PLAY;
        goT = 60;
      }
      updatePetals();
      drawWorld();
      String s = "";
      if (cdT < 60) s = "3";
      else if (cdT < 120) s = "2";
      else if (cdT < 180) s = "1";
      drawCountdownText(s, 150);
      txtO("エンターキーで加速！  赤いレールの上では離す！", width / 2, height - 40, 24, color(255), color(60, 40, 80));
    } else if (phase == G_PLAY) {
      updatePlay();
      updatePetals();
      drawWorld();
      drawHUD();
    } else if (phase == G_GOAL) {
      updateGoal();
      updatePetals();
      if (phase == PH_RESULT) {
        drawResult4();
      } else {
        drawWorld();
        drawHUD();
        txtO("GOAL!", width / 2, 150, 110, color(255, 235, 60), color(160, 60, 0));
      }
    } else if (phase == PH_RESULT) {
      drawResult4();
    }
  }

  // ---------- 入力 ----------
  void onKeyDown(int kc) {
    if (menuPhaseKey(kc)) return;
    if (phase == PH_RESULT) {
      resultKey(kc);
      return;
    }
    if (phase == G_PLAY && kc == K_ENTER) {
      if (onRed) {
        misses++;
        missT = 40;
        armed = -1;
        return;
      }
      int i = nextRail - 1;
      if (i >= 0 && armed == i && wx - re[i] <= win()) {
        doGreat();
        armed = -1;
        return;
      }
      armed = -1;
    }
  }

  void onKeyUp(int kc) {
    if (phase == G_PLAY && kc == K_ENTER && nextRail < N && !onRed) {
      float d = rs[nextRail] - wx;
      if (d > 0 && d <= win()) armed = nextRail;
    }
  }

  void onMouse() {
    if (menuPhaseMouse()) return;
    if (phase == PH_RESULT) resultMouse();
  }

  void doGreat() {
    greats++;
    greatT = 60;
    v = min(VCAP, v + 2.8);
    boostT = 70;
    for (int k = 0; k < 14; k++) {
      float a = random(TWO_PI);
      float sp = random(1.5, 5);
      stars.add(new Particle(wx, heroY(), cos(a) * sp - 1, sin(a) * sp, 0.05, random(7, 14), 40, color(255, 235, 90)));
    }
  }

  // ---------- 更新 ----------
  void updatePlay() {
    playT++;
    if (goT > 0) goT--;
    if (greatT > 0) greatT--;
    if (missT > 0) missT--;
    if (boostT > 0) boostT--;
    updateParts(stars);

    float sl = (trackY(wx + 3) - trackY(wx - 3)) / 6.0;
    v += GRAV * sl / sqrt(1 + sl * sl);
    boolean enter = keys[K_ENTER];
    float vmax = VMAX + (boostT > 0 ? 4 : 0);
    if (enter) {
      if (onRed) v -= 0.22;                    // 赤いレールで押すと減速
      else v += ACC * (1 - v / vmax);         // 黄色いレールで押すと加速
    }
    if (boostT > 0) v *= 0.999;
    else v *= 0.9955;
    v = constrain(v, 0, VCAP);
    wx += v;

    wasOnRed = onRed;
    while (nextRail < N && wx > re[nextRail]) nextRail++;
    onRed = (nextRail < N && wx >= rs[nextRail] && wx <= re[nextRail]);
    if (onRed && !wasOnRed && enter) {        // 押したまま赤に入った
      misses++;
      missT = 40;
      armed = -1;
    }

    if (v > 3 && playT % 3 == 0) {
      stars.add(new Particle(wx - 22, heroY() + random(-6, 10), -0.3, random(-0.4, 0.4), 0, random(5, 9), 28, color(255, 225, 80)));
    }
    if (wx >= goalX) {
      finishT = playT;
      phase = G_GOAL;
      camFrozen = goalX - width / 2;
      exitT = 0;
    }
  }

  void updateGoal() {
    updateParts(stars);
    if (v < 6) v = 6;
    v += 0.05;
    wx += v;
    if (frameCount % 3 == 0) {
      stars.add(new Particle(wx - 22, heroY() + random(-6, 10), -0.3, random(-0.4, 0.4), 0, random(5, 9), 28, color(255, 225, 80)));
    }
    float sx = wx - camFrozen;
    if (sx > width + 60) {
      exitT++;
      if (exitT >= 120) startResult();
    }
  }

  void updatePetals() {
    for (int i = 0; i < 50; i++) {
      ppy[i] += 0.6 + pps[i];
      ppx[i] += sin(frameCount * 0.03 + ppp[i]) * 0.5;
      if (ppy[i] > height + 10) {
        ppy[i] = -10;
        ppx[i] = random(width);
      }
    }
  }

  // ---------- 描画 ----------
  void drawWorld() {
    float cam = camX();
    gradBG(color(170, 215, 255), color(255, 235, 245));
    noStroke();
    fill(255, 245, 200, 200);
    ellipse(780, 110, 90, 90);
    // 遠くの山
    fill(165, 215, 160);
    beginShape();
    vertex(0, height);
    for (float sx = 0; sx <= width; sx += 20) {
      vertex(sx, 400 + sin((sx + cam * 0.25) * 0.006) * 45 + sin((sx + cam * 0.25) * 0.015) * 12);
    }
    vertex(width, height);
    endShape(CLOSE);
    fill(120, 190, 125);
    beginShape();
    vertex(0, height);
    for (float sx = 0; sx <= width; sx += 20) {
      vertex(sx, 455 + sin((sx + cam * 0.5) * 0.008 + 2) * 30 + sin((sx + cam * 0.5) * 0.02) * 8);
    }
    vertex(width, height);
    endShape(CLOSE);
    // 地面
    fill(90, 160, 95);
    rect(0, 520, width, height - 520);

    // 支柱
    stroke(130, 100, 70);
    strokeWeight(3);
    float first = floor(cam / 80.0) * 80;
    for (float xx = first; xx < cam + width + 80; xx += 80) {
      float sx = xx - cam;
      line(sx, trackY(xx) + 5, sx, 520);
    }
    // 枕木
    stroke(150, 110, 0);
    strokeWeight(3);
    float first2 = floor(cam / 24.0) * 24;
    for (float xx = first2; xx < cam + width + 24; xx += 24) {
      float sx = xx - cam;
      float yy = trackY(xx);
      line(sx, yy + 3, sx, yy + 10);
    }
    // 黄色いレール
    noFill();
    stroke(255, 205, 0);
    strokeWeight(8);
    beginShape();
    for (float sx = -10; sx <= width + 10; sx += 8) {
      vertex(sx, trackY(sx + cam));
    }
    endShape();
    // 赤いレール
    for (int i = 0; i < N; i++) {
      if (re[i] < cam - 20 || rs[i] > cam + width + 20) continue;
      stroke(235, 40, 40);
      strokeWeight(9);
      noFill();
      beginShape();
      for (float xx = rs[i]; xx < re[i]; xx += 6) {
        vertex(xx - cam, trackY(xx));
      }
      vertex(re[i] - cam, trackY(re[i]));
      endShape();
      // 目印の看板
      float sgx = rs[i] - cam - 36;
      float sgy = trackY(rs[i] - 36);
      noStroke();
      fill(235, 40, 40);
      triangle(sgx - 9, sgy - 52, sgx + 9, sgy - 52, sgx, sgy - 38);
      stroke(120, 80, 60);
      strokeWeight(2);
      line(sgx, sgy - 38, sgx, sgy - 4);
    }
    // スタートとゴール
    drawGate(0, "START", color(255, 255, 255), cam);
    drawGate(goalX, "GOAL", color(255, 235, 60), cam);

    // 星のエフェクト
    noStroke();
    for (Particle p : stars) {
      float a = 255.0 * p.life / p.maxLife;
      fill(255, 225, 80, a);
      drawStar(p.x - cam, p.y, p.sz * 0.45, p.sz, p.rot);
    }

    // 主人公
    float hsx = wx - cam;
    float ang = atan2(trackY(wx + 3) - trackY(wx - 3), 6);
    pushMatrix();
    translate(hsx, heroY());
    rotate(ang);
    noStroke();
    fill(0, 255, 255);
    rect(-HERO / 2, -HERO / 2, HERO, HERO);
    popMatrix();

    // 桜の花びら
    noStroke();
    fill(255, 185, 205, 210);
    for (int i = 0; i < 50; i++) {
      float sx = ((ppx[i] - cam * 0.6) % width + width) % width;
      ellipse(sx, ppy[i], 9, 6);
    }
    strokeWeight(1);
  }

  void drawGate(float gx, String label, color col, float cam) {
    float sx = gx - cam;
    if (sx < -120 || sx > width + 120) return;
    float ty = trackY(gx);
    stroke(110, 80, 60);
    strokeWeight(5);
    line(sx - 62, ty, sx - 62, ty - 200);
    line(sx + 62, ty, sx + 62, ty - 200);
    noStroke();
    fill(col);
    rect(sx - 62, ty - 200, 124, 40, 6);
    txt(label, sx, ty - 180, 26, color(60, 30, 20));
    strokeWeight(1);
  }

  void drawHUD() {
    txtO("TIME " + nf(playT / 60.0, 1, 2), 100, 30, 30, color(255), color(70, 40, 90));
    txtO("MISS " + misses, 100, 66, 24, color(255, 200, 200), color(120, 20, 20));
    // 進行バー
    float bx0 = 300, bw = 360;
    noStroke();
    fill(0, 0, 0, 90);
    rect(bx0, 20, bw, 10, 5);
    fill(235, 40, 40);
    for (int i = 0; i < N; i++) {
      rect(bx0 + rs[i] / goalX * bw, 20, 2, 10);
    }
    fill(255, 255, 255);
    ellipse(bx0 + constrain(wx / goalX, 0, 1) * bw, 25, 16, 16);
    fill(0);
    ellipse(bx0 + constrain(wx / goalX, 0, 1) * bw, 25, 9, 9);
    // 速度メーター
    txtO("SPEED", width - 130, 22, 20, color(255), color(70, 40, 90));
    fill(0, 0, 0, 100);
    rect(width - 230, 40, 200, 14, 7);
    fill(255, 150, 60);
    rect(width - 230, 40, 200 * constrain(v / VCAP, 0, 1), 14, 7);
    if (goT > 0) txtO("GO!", width / 2, 150, 120, color(255, 255, 255), color(230, 80, 120));
    if (greatT > 0) txtO("great!", width / 2, 120 + (greatT > 50 ? (greatT - 50) : 0), 76, color(255, 235, 60), color(190, 90, 0));
    if (missT > 0) txtO("MISS", width / 2, 210, 48, color(255, 70, 70), color(90, 0, 0));
  }

  void drawResult4() {
    gradBG(color(255, 190, 215), color(150, 210, 255));
    noStroke();
    fill(255, 255, 255, 150);
    for (int i = 0; i < 24; i++) {
      float px = (i * 83 + frameCount * 0.6) % width;
      float py = (i * 59 + frameCount * 1.0) % height;
      ellipse(px, py, 10, 7);
    }
    txtO("ゴール！", width / 2, 95, 80, color(255, 235, 60), color(160, 60, 0));
    txt("タイム", width / 2, 180, 32, color(60, 40, 90));
    txtO(nf(finishT / 60.0, 0, 2) + " 秒", width / 2, 255, 96, color(255), color(70, 40, 90));
    txt("ミス： " + misses + " 回", width / 2, 345, 44, color(120, 20, 20));
    txt("great!： " + greats + " 回", width / 2, 405, 30, color(60, 40, 90));
    drawResultMenu();
  }
}
