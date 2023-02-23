use lib "../../../lib/";
use GL;
use GLM;
use GLFW;
use Shaders;
use SOIL;
use Camera;

constant size-of-float = 4;
package SCR {
  our constant WIDTH  = 800;
  our constant HEIGHT = 600;
}

my Camera $camera .= new:
		     position => GLM::vec3(0, 0, 3),
		     yaw => -90°
;

my GLM::Vec3 $light-pos = GLM::vec3(1.2, 1, 2);

sub process-input($window) {
  my $speed = $camera.speed;
  subset Pressed of UInt where -> $k { GLFW::getKey($window, $k) == GLFW::PRESS }
  GLFW::setWindowShouldClose($window, True)  if GLFW::KEY_ESCAPE ~~ Pressed;
  $camera.move: $speed*$*delta-time*$camera.front if GLFW::KEY_W ~~ Pressed;
  $camera.move: $speed*$*delta-time*$camera.back  if GLFW::KEY_S ~~ Pressed;
  $camera.move: $speed*$*delta-time*$camera.left  if GLFW::KEY_A ~~ Pressed;
  $camera.move: $speed*$*delta-time*$camera.right if GLFW::KEY_D ~~ Pressed;
}

constant %shader-sources =
  cube     => %( <vertex fragment> Z=> map *.IO.slurp, "2.1.basic_lighting." «~« <vs fs> ),
  lighting => %( <vertex fragment> Z=> map *.IO.slurp, "2.1.light_cube." «~« <vs fs> )
;

constant @vertices = (
  -0.5, -0.5, -0.5,  0.0,  0.0, -1.0,
   0.5, -0.5, -0.5,  0.0,  0.0, -1.0,
   0.5,  0.5, -0.5,  0.0,  0.0, -1.0,
   0.5,  0.5, -0.5,  0.0,  0.0, -1.0,
  -0.5,  0.5, -0.5,  0.0,  0.0, -1.0,
  -0.5, -0.5, -0.5,  0.0,  0.0, -1.0,

  -0.5, -0.5,  0.5,  0.0,  0.0,  1.0,
   0.5, -0.5,  0.5,  0.0,  0.0,  1.0,
   0.5,  0.5,  0.5,  0.0,  0.0,  1.0,
   0.5,  0.5,  0.5,  0.0,  0.0,  1.0,
  -0.5,  0.5,  0.5,  0.0,  0.0,  1.0,
  -0.5, -0.5,  0.5,  0.0,  0.0,  1.0,

  -0.5,  0.5,  0.5, -1.0,  0.0,  0.0,
  -0.5,  0.5, -0.5, -1.0,  0.0,  0.0,
  -0.5, -0.5, -0.5, -1.0,  0.0,  0.0,
  -0.5, -0.5, -0.5, -1.0,  0.0,  0.0,
  -0.5, -0.5,  0.5, -1.0,  0.0,  0.0,
  -0.5,  0.5,  0.5, -1.0,  0.0,  0.0,

   0.5,  0.5,  0.5,  1.0,  0.0,  0.0,
   0.5,  0.5, -0.5,  1.0,  0.0,  0.0,
   0.5, -0.5, -0.5,  1.0,  0.0,  0.0,
   0.5, -0.5, -0.5,  1.0,  0.0,  0.0,
   0.5, -0.5,  0.5,  1.0,  0.0,  0.0,
   0.5,  0.5,  0.5,  1.0,  0.0,  0.0,

  -0.5, -0.5, -0.5,  0.0, -1.0,  0.0,
   0.5, -0.5, -0.5,  0.0, -1.0,  0.0,
   0.5, -0.5,  0.5,  0.0, -1.0,  0.0,
   0.5, -0.5,  0.5,  0.0, -1.0,  0.0,
  -0.5, -0.5,  0.5,  0.0, -1.0,  0.0,
  -0.5, -0.5, -0.5,  0.0, -1.0,  0.0,

  -0.5,  0.5, -0.5,  0.0,  1.0,  0.0,
   0.5,  0.5, -0.5,  0.0,  1.0,  0.0,
   0.5,  0.5,  0.5,  0.0,  1.0,  0.0,
   0.5,  0.5,  0.5,  0.0,  1.0,  0.0,
  -0.5,  0.5,  0.5,  0.0,  1.0,  0.0,
  -0.5,  0.5, -0.5,  0.0,  1.0,  0.0
  );

sub MAIN {

    note "not ready";

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

    my %programs = do for <lighting cube> {
	$_ => Shaders::Load
	vertex-shader-source => %shader-sources{$_}<vertex>,
	fragment-shader-source => %shader-sources{$_}<fragment>;
    }
	

    my uint32 ($vbo, $cube-vao);
    GL::genVertexArrays 1, $cube-vao;
    GL::genBuffers 1, $vbo;

    GL::bindVertexArray $cube-vao;
    GL::bindBuffer GL::ARRAY_BUFFER, $vbo;
    GL::bufferData GL::ARRAY_BUFFER, 4*@vertices.elems, CArray[num32].new(@vertices».Num), GL::STATIC_DRAW;

    GL::vertexAttribPointer 0, 3, GL::FLOAT, GL::FALSE, 6*size-of-float, Pointer.new;
    GL::enableVertexAttribArray 0;
    GL::vertexAttribPointer 1, 3, GL::FLOAT, GL::FALSE, 6*size-of-float, Pointer.new(3*size-of-float);
    GL::enableVertexAttribArray 1;


    GL::bindBuffer GL::ARRAY_BUFFER, 0;
    GL::bindVertexArray 0;

    my uint32 $lighting-vao;
    GL::genVertexArrays 1, $lighting-vao;

    GL::bindVertexArray $lighting-vao;
    GL::bindBuffer GL::ARRAY_BUFFER, $vbo;
    
    GL::vertexAttribPointer 0, 3, GL::FLOAT, GL::FALSE, 6*4, Pointer.new;
    GL::enableVertexAttribArray 0;
    
    GL::enable GL::DEPTH_TEST;

    GLFW::setInputMode $window, GLFW::CURSOR, GLFW::CURSOR_DISABLED;

    GLFW::setCursorPosCallback
      $window,
      sub ($w, $xpos, $ypos) {
	state ($last-X, $last-Y) = SCR::WIDTH/2, SCR::HEIGHT/2;
	my ($x-offset, $y-offset) = $xpos - $last-X, $last-Y - $ypos;
	($last-X, $last-Y) = $xpos, $ypos;
	$camera.pitch: $y-offset*$camera.sensitivity;
	$camera.yaw:   $x-offset*$camera.sensitivity;
      }
    ;

    until GLFW::windowShouldClose($window) {
	
      my $*delta-time = now - state $now = now;
      $now = now;

      GL::clearColor .2e0, .3e0, .3e0, 1e0;
      GL::clear GL::COLOR_BUFFER_BIT +| GL::DEPTH_BUFFER_BIT;

      my $projection = GLM::perspective $camera.zoom, SCR::WIDTH / SCR::HEIGHT, 0.1..100;
      my $view = $camera.matrix;
      
      {
	  GL::useProgram %programs<cube>;
	  GL::uniform3f(GL::getUniformLocation(%programs<cube>, "objectColor"), 1e0, .5e0, .31e0);
	  GL::uniform3f(GL::getUniformLocation(%programs<cube>, "lightColor" ), 1e0,  1e0,   1e0);
	  GL::uniform3f(GL::getUniformLocation(%programs<cube>, "lightPos" ), |$light-pos.xyz».Num);
	  my $model = GLM::mat4 1;

	  for :$projection, :$view, :$model {
	      GL::uniformMatrix4fv(
		  GL::getUniformLocation(%programs<cube>, .key),
		  1,
		  GL::FALSE,
		  CArray[num32].new: .value.flat».Num
	      );
	  }
	  GL::bindVertexArray($cube-vao);
	  GL::drawArrays(GL::TRIANGLES, 0, 36);
      }

      {
	  GL::useProgram %programs<lighting>;
	  GL::uniform3f(GL::getUniformLocation(%programs<lighting>, "objectColor"), 1e0, .5e0, .31e0);
	  GL::uniform3f(GL::getUniformLocation(%programs<lighting>, "lightColor" ), 1e0,  1e0,   1e0);
	  my $model = GLM::mat4 1;
	  $model = GLM::translate $model, $light-pos;
	  $model = GLM::scale $model, GLM::vec3 .2, .2, .2;
	  
  	  for :$projection, :$view, :$model {
	      GL::uniformMatrix4fv(
		  GL::getUniformLocation(%programs<lighting>, .key),
		  1,
		  GL::FALSE,
		  CArray[num32].new: .value.flat».Num
	      );
	  }

	  GL::bindVertexArray($lighting-vao);
	  GL::drawArrays(GL::TRIANGLES, 0, 36);

      }
      

      process-input($window);
      GLFW::swapBuffers $window;
      GLFW::pollEvents;
    }

  } else { fail "could not initialize GLFW" }

}

