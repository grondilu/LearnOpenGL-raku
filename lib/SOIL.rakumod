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

enum HDR (
  RGBE => 0,
  RGBdivA => 1,
  RGBdivA2 => 2
);

