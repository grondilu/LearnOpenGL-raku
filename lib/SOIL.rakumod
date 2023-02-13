unit module SOIL;
use NativeCall;

constant $soil = 'SOIL';

our enum LOAD <
  AUTO
  L
  LA
  RGB
  RGBA
>;

our enum FLAG (
  POWER_OF_TWO => 1,
  MIPMAPS => 2,
  TEXTURE_REPEATS => 4,
  MULTIPLY_ALPHA => 8,
  INVERT_Y => 16,
  COMPRESS_TO_DXT => 32,
  DDS_LOAD_DIRECT => 64,
  NTSC_SAFE_RGB => 128,
  CoCg_Y => 256,
  TEXTURE_RECTANGLE => 512
);

our enum HDR (
  RGBE => 0,
  RGBdivA => 1,
  RGBdivA2 => 2
);

our enum SAVE-TYPE <TGA BMP DDS>;

our constant DDS-CUBEMAP-FACE-ORDER = "EWUDNS";

our sub load-ogl-texture(
  Str $filename,
  int32 $force-channels,
  uint32 $reuse-texture-id,
  uint32 $flags
  --> uint32
) is native($soil) is symbol('SOIL_load_OGL_texture') {*}


our sub load-image(Str, int32 is rw, int32 is rw, int32 is rw, int32 --> Pointer) is native($soil) is symbol('SOIL_load_image') {*}

our sub free-image-data(Pointer) is native($soil) is symbol('SOIL_free_image_data') {*}
