uniform mat4 transform;
uniform mat4 modelview;
uniform mat3 normalMatrix;

attribute vec4 position;
attribute vec3 normal;
attribute vec4 color;
attribute float aoValue;

void main()
{
  gl_Position = transform * position;
}