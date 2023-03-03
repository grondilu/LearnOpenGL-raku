This is a fork of the [learnopengl.com](https://learnopengl.com) code repository.  See [parent repo](https://github.com/JoeyDeVries/LearnOpenGL) for details.

This fork contains Raku code (using NativeCall libraries in ./lib) attempting to replicate the tutorials.

# Status

I did the bare minimum, so the tasks below may be marked as
completed even though the exercises are not.

- [x] getting started
- [ ] lighting
- [ ] model loading
- [ ] advanced opengl
- [ ] advanced lighting
- [ ] pbr
- [ ] in practice


# Dependencies

Lots of: OpenGL, GLFW, SOIL ...   You need to install these libraries on your system,
likely along with their development versions (`-devel`).  I will eventually write
more details for at least Fedora and Debian.

## Fedora toolbox 37

You probably want the latest rakudo version, which is not available in the toolbox.  So first, instal that, either in the toolbox or your host system.  Then, in your toolbox:

```sh
sudo dnf install {mesa-libGL,glfw,SOIL}{,-devel}
```

