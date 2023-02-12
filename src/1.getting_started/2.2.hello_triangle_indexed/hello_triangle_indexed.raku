use lib <../../../lib>;
use GL;
use GLFW;
use Shaders;

package SCR {
  our constant WIDTH  = 800;
  our constant HEIGHT = 600;
}

sub process-input($window) {
  GLFW::setWindowShouldClose($window, True) if
    GLFW::getKey($window, GLFW::KEY_ESCAPE) == GLFW::PRESS;
}

constant $vertex-shader-source = q:to/EOF/;
#version 330 core
layout (location = 0) in vec3 aPos;
void main()
{
   gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
}
EOF

constant $fragment-shader-source = q:to/EOF/;
#version 330 core
out vec4 FragColor;
void main()
{
   FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);
}
EOF

constant @vertices = 
  +.5, +.5, 0,
  +.5, -.5, 0,
  -.5, -.5, 0,
  -.5, +.5, 0,
;

constant @indices = 0, 1, 3,   1, 2, 3;

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
    GL::genBuffers      1, my uint32 $vbo;
    GL::genBuffers      1, my uint32 $ebo;
    GL::genVertexArrays 1, my uint32 $vao;
    GL::bindVertexArray $vao;
    GL::bindBuffer(GL::ARRAY_BUFFER, $vbo);
    GL::bufferData(GL::ARRAY_BUFFER, 4*@vertices.elems, CArray[num32].new(@vertices».Num), GL::STATIC_DRAW);
    GL::bindBuffer(GL::ELEMENT_ARRAY_BUFFER, $ebo);
    GL::bufferData(GL::ELEMENT_ARRAY_BUFFER, 4*@indices.elems, CArray[uint32].new(@indices), GL::STATIC_DRAW);

    GL::vertexAttribPointer 0, 3, GL::FLOAT, GL::FALSE, 3 * 4, Pointer.new;
    GL::enableVertexAttribArray 0;

    GL::bindBuffer GL::ARRAY_BUFFER, 0;
    GL::bindVertexArray 0;

    until GLFW::windowShouldClose($window) {
      GL::clearColor .2e0, .3e0, .3e0, 1e0;
      GL::clear GL::COLOR_BUFFER_BIT;

      GL::useProgram $program;
      GL::bindVertexArray $vao;

      GL::bindBuffer GL::ELEMENT_ARRAY_BUFFER, $ebo;
      GL::drawElements GL::TRIANGLES, 6, GL::UNSIGNED_INT, 0;

      process-input($window);
      GLFW::swapBuffers $window;
      GLFW::pollEvents;
    }

  } else { fail "could not initialize GLFW" }

}
