uniform mat4 transform;
uniform mat4 modelview;
uniform mat3 normalMatrix;
uniform mat4 projection;

attribute vec4 position;
attribute vec3 normal;
attribute vec2 texcoords;
attribute float aoValue;

uniform float zNear;
uniform float zFar;

varying vec4 viewPos;
varying vec3 viewNormal;
varying vec2 uvs;

void main()
{
  gl_Position = transform * position;
  viewPos = modelview * position;
  viewNormal = normalMatrix * normal;
  uvs = texcoords;
}