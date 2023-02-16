use lib "$*HOME/.local/src/ogl-raku/lib/";
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

constant $vertex-shader-source   = "7.1.camera.vs".IO.slurp;
constant $fragment-shader-source = "7.1.camera.fs".IO.slurp;

constant @vertices = 
  -0.5, -0.5, -0.5,  0.0, 0.0,
   0.5, -0.5, -0.5,  1.0, 0.0,
   0.5,  0.5, -0.5,  1.0, 1.0,
   0.5,  0.5, -0.5,  1.0, 1.0,
  -0.5,  0.5, -0.5,  0.0, 1.0,
  -0.5, -0.5, -0.5,  0.0, 0.0,

  -0.5, -0.5,  0.5,  0.0, 0.0,
   0.5, -0.5,  0.5,  1.0, 0.0,
   0.5,  0.5,  0.5,  1.0, 1.0,
   0.5,  0.5,  0.5,  1.0, 1.0,
  -0.5,  0.5,  0.5,  0.0, 1.0,
  -0.5, -0.5,  0.5,  0.0, 0.0,

  -0.5,  0.5,  0.5,  1.0, 0.0,
  -0.5,  0.5, -0.5,  1.0, 1.0,
  -0.5, -0.5, -0.5,  0.0, 1.0,
  -0.5, -0.5, -0.5,  0.0, 1.0,
  -0.5, -0.5,  0.5,  0.0, 0.0,
  -0.5,  0.5,  0.5,  1.0, 0.0,

   0.5,  0.5,  0.5,  1.0, 0.0,
   0.5,  0.5, -0.5,  1.0, 1.0,
   0.5, -0.5, -0.5,  0.0, 1.0,
   0.5, -0.5, -0.5,  0.0, 1.0,
   0.5, -0.5,  0.5,  0.0, 0.0,
   0.5,  0.5,  0.5,  1.0, 0.0,

  -0.5, -0.5, -0.5,  0.0, 1.0,
   0.5, -0.5, -0.5,  1.0, 1.0,
   0.5, -0.5,  0.5,  1.0, 0.0,
   0.5, -0.5,  0.5,  1.0, 0.0,
  -0.5, -0.5,  0.5,  0.0, 0.0,
  -0.5, -0.5, -0.5,  0.0, 1.0,

  -0.5,  0.5, -0.5,  0.0, 1.0,
   0.5,  0.5, -0.5,  1.0, 1.0,
   0.5,  0.5,  0.5,  1.0, 0.0,
   0.5,  0.5,  0.5,  1.0, 0.0,
  -0.5,  0.5,  0.5,  0.0, 0.0,
  -0.5,  0.5, -0.5,  0.0, 1.0
;

my @cube-positions =
    GLM::vec3( 0.0,  0.0,  0.0),
    GLM::vec3( 2.0,  5.0, -15.0),
    GLM::vec3(-1.5, -2.2, -2.5),
    GLM::vec3(-3.8, -2.0, -12.3),
    GLM::vec3( 2.4, -0.4, -3.5),
    GLM::vec3(-1.7,  3.0, -7.5),
    GLM::vec3( 1.3, -2.0, -2.5),
    GLM::vec3( 1.5,  2.0, -2.5),
    GLM::vec3( 1.5,  0.2, -1.5),
    GLM::vec3(-1.3,  1.0, -1.5)
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
    my uint32 ($vbo, $vao);
    GL::genVertexArrays 1, $vao;
    GL::genBuffers 1, $vbo;

    GL::bindVertexArray $vao;
    GL::bindBuffer GL::ARRAY_BUFFER, $vbo;
    GL::bufferData GL::ARRAY_BUFFER, 4*@vertices.elems, CArray[num32].new(@vertices».Num), GL::STATIC_DRAW;

    GL::vertexAttribPointer 0, 3, GL::FLOAT, GL::FALSE, 5 * 4, Pointer.new;
    GL::enableVertexAttribArray 0;
    GL::vertexAttribPointer 1, 2, GL::FLOAT, GL::FALSE, 5 * 4, Pointer.new(3*4);
    GL::enableVertexAttribArray 1;

    GL::bindBuffer GL::ARRAY_BUFFER, 0;
    GL::bindVertexArray 0;

    my uint32 ($texture1, $texture2);
    { # Texture 1
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
    { # Texture 2
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
    GL::enable GL::DEPTH_TEST;
    GL::uniform1i GL::getUniformLocation($program, "texture1"), 0;
    GL::uniform1i GL::getUniformLocation($program, "texture2"), 1;

    until GLFW::windowShouldClose($window) {
      GL::clearColor .2e0, .3e0, .3e0, 1e0;
      GL::clear GL::COLOR_BUFFER_BIT +| GL::DEPTH_BUFFER_BIT;

      GL::activeTexture GL::TEXTURE0;
      GL::bindTexture GL::TEXTURE_2D, $texture1;
      GL::activeTexture GL::TEXTURE1;
      GL::bindTexture GL::TEXTURE_2D, $texture2;

      GL::useProgram $program;

      my $view        = GLM::mat4 1;
      my $radius = 10e0;
      my $now = now;
      my $cam-x = sin($now)*$radius;
      my $cam-z = cos($now)*$radius;
      my $projection  = GLM::mat4 1;
      $view = GLM::lookAt
	eye => GLM::vec3($cam-x, 0, $cam-z),
	center => GLM::vec3(0, 0, 0),
	up => GLM::vec3(0, 1, 0);
      $projection = GLM::perspective 45°, SCR::WIDTH / SCR::HEIGHT, 0.1..100;

      GL::bindVertexArray $vao;

      for ^@cube-positions -> $i {
	my $model       = GLM::mat4 1;
	$model = GLM::translate $model, @cube-positions[$i];
	$model = GLM::rotate $model, $i*20°, GLM::vec3 1, .3, .5;
	#$model = GLM::rotate $model, now*-55.0°, GLM::vec3(0.5e0, 1.0e0, 0.0e0);
	for :$model, :$view, :$projection {
	  GL::uniformMatrix4fv
	    GL::getUniformLocation($program, .key),
	    1, GL::FALSE, CArray[num32].new(.value.flat».Num)
	}
	GL::drawArrays GL::TRIANGLES, 0, 36;
      }

      process-input($window);
      GLFW::swapBuffers $window;
      GLFW::pollEvents;
    }

  } else { fail "could not initialize GLFW" }

}
