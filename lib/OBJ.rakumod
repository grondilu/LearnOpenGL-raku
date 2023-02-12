unit module OBJ;

our sub parse(Str $obj) {

  my token integer { 0 | <.+digit-[0]><.digit>* }
  my token decimal { <[+-]>? <integer> ['.' <.digit>+]? }
  my token vertex { <integer>**0..3 % '/' <?{ .<integer>».elems.unique == 1 }> }
  my token face { 'f ' <vertex>**3 % ' ' }

  my (@vertices, @uvs, @normals, @faces);

  for $obj.lines {

    when /^'v ' <decimal>**3 % ' '/ { push @vertices, $<decimal>>>.Num; }
    when /^'vt ' <decimal>**2 % ' '/ { push @uvs, $<decimal>».Num; }
    when /^'vn ' <decimal>**2 % ' '/ { push @normals, $<decimal>».Num; }
    when /^<face> / { push @faces, $<face><vertex>»<integer>».Int; }

  }

  %(
    :@vertices,
    :@uvs,
    :@normals,
    :@faces
  );

}

