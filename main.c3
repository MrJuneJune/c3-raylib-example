import std::io;
import std::math::random;
import libc;

extern fn void init_window(CInt width, CInt height, char* title) @extern("InitWindow");
extern fn void close_window() @extern("CloseWindow");
extern fn bool window_should_close() @extern("WindowShouldClose");
extern fn void begin_drawing() @extern("BeginDrawing") ;
extern fn void end_drawing() @extern("EndDrawing") ; 
extern fn Texture load_texture(char* filename) @extern("LoadTexture");
extern fn void draw_texture(Texture texture, int posX, int posY, Color tint) @extern("DrawTexture");
extern fn bool is_mouse_button_down(int button) @extern("IsMouseButtonDown");
extern fn bool is_mouse_button_pressed(int button) @extern("IsMouseButtonPressed");

extern fn Vector2 get_mouse_position() @extern("GetMousePosition");
extern fn void clear_background(Color color) @extern("ClearBackground");
extern fn void draw_fps(int posX, int posY) @extern("DrawFPS");
extern fn void draw_text(char* text, int posX, int posY, int fontSize, Color color) @extern("DrawText");


struct Texture {
    int id;        // OpenGL texture id
    int width;              // Texture base width
    int height;             // Texture base height
    int mipmaps;            // Mipmap levels, 1 by default
    int format;             // Data format (PixelFormat type)
} 

struct Vector2 {
    float x;
    float y;
}

struct Color {
    char r;
    char g;
    char b;
    char a;
}

struct Bunny { 
    Vector2 position;
    Vector2 velocity;
    Color color;
}

fn Vector2 generate_random_vector2() {
    return { (float)random::rand(10), (float)random::rand(10)};
}

fn Color generate_random_vector4() {
    return { 
      (char)random::rand(255),
      (char)random::rand(255),
      (char)random::rand(255),
      255
    };
}

fn void main() {
  const int WINDOW_WIDTH = 1000;
  const int WINDOW_HEIGHT = 800;

  init_window(WINDOW_WIDTH, WINDOW_HEIGHT, "From c3");
  defer close_window();

  Texture bunny_texture = load_texture("./wabbit_alpha.png");
  const int MAX_BUNNIES = 10000;
  Bunny[MAX_BUNNIES] bunnies = {};
  int bunny_number = 0;
  char[100] title;

  while (!window_should_close()) {
      if (is_mouse_button_pressed(0 /*mouse button left*/) && bunny_number < MAX_BUNNIES) {
          for (int i=0; i<10; i++) {
            Vector2 position = get_mouse_position();
            bunnies[bunny_number] = {
                position,
                generate_random_vector2(),
                generate_random_vector4(),
            };
            bunny_number += 1;
          }
      }
      
      begin_drawing();
      defer end_drawing();
      clear_background({245, 245, 245, 255});
      foreach (index, &bunny : bunnies[0 .. bunny_number]) {
        draw_texture(bunny_texture, (int)bunny.position.x, (int)bunny.position.y, bunny.color);
        bunny.position.x += bunny.velocity.x;
        bunny.position.y += bunny.velocity.y;

        if (bunny.position.x > WINDOW_WIDTH || bunny.position.x < 0) {
            bunny.velocity.x *= -1;
        } 
        if (bunny.position.y > WINDOW_HEIGHT || bunny.position.y < 0) {
            bunny.velocity.y *= -1;
        }
      }

      libc::sprintf(&title, "Number of Bunnies: %d", bunny_number);

      draw_text(&title, 400, 10, 20, { 0, 0, 0, 255 });
      draw_fps(260, 10);
  }
}
