use lib <../../../lib>;
use GL;
use GLFW;

package SCR {
  our constant WIDTH  = 800;
  our constant HEIGHT = 600;
}

sub process-input($window) {
  GLFW::setWindowShouldClose($window, True) if
    GLFW::getKey($window, GLFW::KEY_ESCAPE) == GLFW::PRESS;
}

sub MAIN {

  if GLFW::init() {
    LEAVE { note "terminating GLFW"; GLFW::terminate; }
    GLFW::windowHint GLFW::CONTEXT_VERSION_MAJOR, 3;
    GLFW::windowHint GLFW::CONTEXT_VERSION_MINOR, 3;
    GLFW::windowHint GLFW::OPENGL_PROFILE, GLFW::OPENGL_CORE_PROFILE;
    fail "could not create window" unless
      my $window = GLFW::createWindow SCR::WIDTH, SCR::HEIGHT, "LearnOpenGL", Nil, Nil;
    GLFW::makeContextCurrent $window;
    GLFW::setFramebufferSizeCallback $window, sub ($, uint32 $w, uint32 $h) { GL::viewport 0, 0, $w, $h };
    GLFW::setErrorCallback( sub (int32 $n, Str $s) { fail "$n: $s" } );
    until GLFW::windowShouldClose($window) {
      process-input($window);
      GLFW::swapBuffers $window;
      GLFW::pollEvents;
    }
  } else { fail "could not initialize GLFW" }

}
