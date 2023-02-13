use lib "$*HOME/.local/src/ogl-raku/lib/";
use GL;
use GLFW;
use Shaders;
use SOIL;

package SCR {
  our constant WIDTH  = 800;
  our constant HEIGHT = 600;
}

sub process-input($window) {
  GLFW::setWindowShouldClose($window, True) if
    GLFW::getKey($window, GLFW::KEY_ESCAPE) == GLFW::PRESS;
}

constant $vertex-shader-source   = "4.1.texture.vs".IO.slurp;
constant $fragment-shader-source = "4.1.texture.fs".IO.slurp;

constant @vertices = 
  # positions          # colors           # texture coords
   0.5,  0.5, 0.0,     1.0, 0.0, 0.0,     1.0, 1.0, # top right
   0.5, -0.5, 0.0,     0.0, 1.0, 0.0,     1.0, 0.0, # bottom right
  -0.5, -0.5, 0.0,     0.0, 0.0, 1.0,     0.0, 0.0, # bottom let
  -0.5,  0.5, 0.0,     1.0, 1.0, 0.0,     0.0, 1.0  # top let 
;
constant @indices = 
  0, 1, 3, # first triangle
  1, 2, 3  # second triangle
;

sub MAIN {

  if GLFW::init() {
    use NativeCall;

    LEAVE { note "terminating GLFW"; GLFW::terminate; }
    GLFW::windowHint GLFW::CONTEXT_VERSION_MAJOR, 3;
    GLFW::windowHint GLFW::CONTEXT_VERSION_MINOR, 3;
    GLFW::windowHint GLFW::OPENGL_PROFILE, GLFW::OPENGL_CORE_PROFILE;
    fail "could not create window" unless
      my $window = GLFW::createWindow SCR::WIDTH, SCR::HEIGHT, "LearnOpenGL", Nil, Nil;
    GLFW::makeContextCurrent $window;
    GLFW::setFramebufferSizeCallback $window, sub ($, uint32 $w, uint32 $h) { GL::viewport 0, 0, $w, $h };
    GLFW::setErrorCallback( sub (int32 $n, Str $s) { fail "$n: $s" } );

    GL::viewport 0, 0, SCR::WIDTH, SCR::HEIGHT;

    my $program = Shaders::Load :$vertex-shader-source, :$fragment-shader-source;
    my uint32 ($vbo, $vao, $ebo);
    GL::genVertexArrays 1, $vao;
    GL::genBuffers 1, $vbo;
    GL::genBuffers 1, $ebo;

    GL::bindVertexArray $vao;
    GL::bindBuffer GL::ARRAY_BUFFER, $vbo;
    GL::bufferData GL::ARRAY_BUFFER, 4*@vertices.elems, CArray[num32].new(@vertices».Num), GL::STATIC_DRAW;

    GL::bindBuffer GL::ELEMENT_ARRAY_BUFFER, $ebo;
    GL::bufferData GL::ELEMENT_ARRAY_BUFFER, 4*@indices.elems, CArray[uint32].new(@indices), GL::STATIC_DRAW;

    GL::vertexAttribPointer 0, 3, GL::FLOAT, GL::FALSE, 8 * 4, Pointer.new;
    GL::enableVertexAttribArray 0;
    GL::vertexAttribPointer 1, 3, GL::FLOAT, GL::FALSE, 8 * 4, Pointer.new(3*4);
    GL::enableVertexAttribArray 1;
    GL::vertexAttribPointer 2, 2, GL::FLOAT, GL::FALSE, 8 * 4, Pointer.new(6*4);
    GL::enableVertexAttribArray 2;

    GL::bindBuffer GL::ARRAY_BUFFER, 0;
    GL::bindVertexArray 0;

    GL::genTextures 1, my uint32 $texture;
    GL::bindTexture GL::TEXTURE_2D, $texture;
    GL::texParameteri GL::TEXTURE_2D, GL::TEXTURE_WRAP_S, GL::REPEAT;
    GL::texParameteri GL::TEXTURE_2D, GL::TEXTURE_WRAP_T, GL::REPEAT;

    if my $image = SOIL::load-image
      "../../../resources/textures/container.jpg",
      my int32 $width,
      my int32 $height,
      my int32 $channels,
      0
    {
      GL::texImage2D GL::TEXTURE_2D, 0, GL::RGB, $width, $height, 0, GL::RGB, GL::UNSIGNED_BYTE, $image;
      GL::generateMipmap(GL::TEXTURE_2D);

      SOIL::free-image-data $image;
    } else { fail "could not load image" }

    until GLFW::windowShouldClose($window) {
      GL::clearColor .2e0, .3e0, .3e0, 1e0;
      GL::clear GL::COLOR_BUFFER_BIT;

      GL::bindTexture GL::TEXTURE_2D, $texture;

      GL::useProgram $program;
      GL::bindVertexArray $vao;

      GL::drawElements GL::TRIANGLES, 6, GL::UNSIGNED_INT, 0;

      process-input($window);
      GLFW::swapBuffers $window;
      GLFW::pollEvents;
    }

  } else { fail "could not initialize GLFW" }

}
