uniform mat4 transform;
uniform mat3 normalMatrix;
uniform mat4 modelViewInv; 

attribute vec4 position;
attribute vec3 normal;

varying vec3 vertNormal;
varying vec3 vertWorldNormal;

void main()
{
  gl_Position = transform * position;
  vec4 f_normal = position * modelViewInv;
  vertNormal = f_normal.xyz;
  vertWorldNormal = normalize(normalMatrix * normal);
}
