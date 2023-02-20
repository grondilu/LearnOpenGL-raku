use lib "../../../lib";
use GL;
use GLM;
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

constant $vertex-shader-source   = "5.1.transform.vs".IO.slurp;
constant $fragment-shader-source = "5.1.transform.fs".IO.slurp;

constant @vertices = 
  # positions          # texture coords
   0.5,  0.5, 0.0,     1.0, 1.0, # top right
   0.5, -0.5, 0.0,     1.0, 0.0, # bottom right
  -0.5, -0.5, 0.0,     0.0, 0.0, # bottom let
  -0.5,  0.5, 0.0,     0.0, 1.0  # top let 
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

    GL::vertexAttribPointer 0, 3, GL::FLOAT, GL::FALSE, 5 * 4, Pointer.new;
    GL::enableVertexAttribArray 0;
    GL::vertexAttribPointer 1, 2, GL::FLOAT, GL::FALSE, 5 * 4, Pointer.new(3*4);
    GL::enableVertexAttribArray 1;

    GL::bindBuffer GL::ARRAY_BUFFER, 0;
    GL::bindVertexArray 0;

    my uint32 ($texture1, $texture2);
    {
      # Texture 1
      GL::genTextures 1, $texture1;
      GL::bindTexture GL::TEXTURE_2D, $texture1;
      GL::texParameteri GL::TEXTURE_2D, GL::TEXTURE_WRAP_S, GL::REPEAT;
      GL::texParameteri GL::TEXTURE_2D, GL::TEXTURE_WRAP_T, GL::REPEAT;
      GL::texParameteri GL::TEXTURE_2D, GL::TEXTURE_MIN_FILTER, GL::LINEAR;
      GL::texParameteri GL::TEXTURE_2D, GL::TEXTURE_MAG_FILTER, GL::LINEAR;

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
    }
    {
      # Texture 2
      GL::genTextures 1, $texture2;
      GL::bindTexture GL::TEXTURE_2D, $texture2;
      GL::texParameteri GL::TEXTURE_2D, GL::TEXTURE_WRAP_S, GL::REPEAT;
      GL::texParameteri GL::TEXTURE_2D, GL::TEXTURE_WRAP_T, GL::REPEAT;
      GL::texParameteri GL::TEXTURE_2D, GL::TEXTURE_MIN_FILTER, GL::LINEAR;
      GL::texParameteri GL::TEXTURE_2D, GL::TEXTURE_MAG_FILTER, GL::LINEAR;

      if my $image = SOIL::load-image(
	"../../../resources/textures/awesomeface.png",
	my int32 $width,
	my int32 $height,
	my int32 $channels,
	0) {
	  GL::texImage2D GL::TEXTURE_2D, 0, GL::RGBA, $width, $height, 0, GL::RGBA, GL::UNSIGNED_BYTE, $image;
	  GL::generateMipmap(GL::TEXTURE_2D);

	  SOIL::free-image-data $image;
	} else { fail "could not load image" }
    }

    GL::useProgram $program;
    GL::uniform1i GL::getUniformLocation($program, "texture1"), 0;
    GL::uniform1i GL::getUniformLocation($program, "texture2"), 1;

    my $vec4 = GLM::vec4 1, 0, 0, 1;

    until GLFW::windowShouldClose($window) {
      GL::clearColor .2e0, .3e0, .3e0, 1e0;
      GL::clear GL::COLOR_BUFFER_BIT;

      GL::activeTexture GL::TEXTURE0;
      GL::bindTexture GL::TEXTURE_2D, $texture1;
      GL::activeTexture GL::TEXTURE1;
      GL::bindTexture GL::TEXTURE_2D, $texture2;

      GL::useProgram $program;

      my $trans = GLM::mat4 1;
      $trans = GLM::translate $trans, GLM::vec3 .5, -.5, 0;
      $trans = GLM::rotate $trans, now, GLM::vec3 0, 0, 1;

      GL::uniformMatrix4fv(
	GL::getUniformLocation($program, "transform"),
	1,
	GL::FALSE,
	CArray[num32].new($trans.flat».Num)
      )
      ;

      GL::bindVertexArray $vao;

      GL::drawElements GL::TRIANGLES, 6, GL::UNSIGNED_INT, Pointer.new;

      process-input($window);
      GLFW::swapBuffers $window;
      GLFW::pollEvents;
    }

  } else { fail "could not initialize GLFW" }

}
