unit class glTF does Positional;

has IO::Path $.path;
has (
  @.accessors,
  @.buffers,
  @.bufferViews,
  @.nodes,
  @.meshes,
  @.scenes
);
has $.scene;

enum Facingness <BACK-FACING FRONT-FACING>;

submethod BUILD(:$!path, :%json) {
  temp $*CWD = $!path.dirname.IO;
  fail "no asset property" unless %json<asset>:exists;
  fail "no asset version" unless %json<asset><version>:exists;
  if %json<asset><minVersion>:exists {...}
  else { fail "unexepected asset version" unless %json<asset><version> == 2; }
  for |%json<buffers> {
    if .<uri> ~~ /^'data:'/ {...}
    else { @!buffers.push: .<uri>.IO }
    fail "unexpected size" unless @!buffers.tail.s == .<byteLength>;
  }
  @!nodes = |%json<nodes>;
  @!scenes = |%json<scenes>;
  $!scene = %json<scene>.Int if %json<scene>:exists;
  @!bufferViews = |%json<bufferViews>;
  @!accessors = |%json<accessors>;
  @!meshes = |%json<meshes>;
}
multi method new(IO::Path $path where /'.gltf'$/) {
  use JSON::Tiny;
  self.bless: :$path, json => from-json $path.slurp(:enc<utf8>);
}

method AT-POS(UInt $n) {
  fail "no such accessor" unless $n ~~ ^@!accessors;
  my $accessor = @!accessors[$n];
  my $bufferView = @!bufferViews[$accessor<bufferView>];
  my $buffer = @!buffers[$bufferView<buffer>].open: :bin;
  LEAVE $buffer.close;
  $buffer.seek: $bufferView<byteOffset> // 0, SeekFromBeginning;
  $buffer.seek: $accessor<byteOffset>   // 0, SeekFromCurrent;
  my $component-count = $accessor<count> *
    my $type-size = %(
      SCALAR => 1,
      VEC2   => 2,
      VEC3   => 3,
      VEC4   => 4,
      MAT2   => 4,
      MAT3   => 9,
      MAT4   => 16
    ){$accessor<type>};
  (do given $accessor<componentType> {
    when 5120 { $buffer.read(1).read-int8:   0 }
    when 5121 { $buffer.read(1).read-uint8:  0 }
    when 5122 { $buffer.read(2).read-int16:  0 }
    when 5123 { $buffer.read(2).read-uint16: 0 }
    when 5125 { $buffer.read(4).read-uint32: 0 }
    when 5126 { $buffer.read(4).read-num32:  0 }
  } xx $component-count).rotor: $type-size;
}
