unit class Camera;
use GLM;

has Real $.speed = 3;
has Real $.sensitivity = .001;
has Real $.yaw = 90°;
has Real $.pitch = 0°;

has GLM::Vec3 $.position = GLM::vec3(0,0,0);
has GLM::Vec3 $.up       = GLM::vec3(0,1,0);

method attitude { %(:$!pitch, :$!yaw) }
method move(GLM::Vec3 $motion) { $!position += $motion; }
method front returns GLM::Vec3 {
  GLM::vec3
    cos($!yaw)*cos($!pitch),
    sin($!pitch),
    sin($!yaw)*cos($!pitch);
}
method back  returns GLM::Vec3 { -self.front }
method left  returns GLM::Vec3 { GLM::normalized(self.front × self.up) }
method right returns GLM::Vec3 { -self.left }

method pitch(Real $pitch) {
  $!pitch += $pitch;
  $!pitch min= +89°;
  $!pitch max= -89°;
}

method yaw(Real $yaw) { $!yaw += $yaw; }

method matrix returns GLM::Mat4 {
  GLM::lookAt
    eye => self.position,
    center => self.position - self.front,
    up => self.up;
}
