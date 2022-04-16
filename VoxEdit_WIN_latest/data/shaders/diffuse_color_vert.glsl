#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform mat4 transform;
uniform mat4 modelview;
uniform mat3 normalMatrix;

// Light direction in view space
uniform vec3 lightsViewDirection0;
uniform vec3 lightsViewDirection1;

uniform bool lightsEnabled0;
uniform bool lightsEnabled1;

uniform mat4 shadowTransform0;
uniform mat4 shadowTransform1;

uniform float minAmbient;

attribute vec4 position;
attribute vec3 normal;
attribute vec4 color;

varying vec4 vertColor;
varying vec4 normPos;
varying vec4 shadowCoord0;
varying vec4 shadowCoord1;
varying vec4 shadowCoord2;
varying vec3 cameraNormal;
varying vec3 lightsCam0;
varying vec3 lightsCam1;
varying vec4 vertPosition;

void main()
{
  vertColor = color;
  vec4 vertPosition = modelview * position; // Get vertex position in model view space

  shadowCoord0 = shadowTransform0 * (vertPosition);
  shadowCoord1 = shadowTransform1 * (vertPosition);

  cameraNormal = normalMatrix * vec3(normal.x, normal.y, normal.z);
  lightsCam0 = lightsViewDirection0;
  lightsCam1 = lightsViewDirection1;

  cameraNormal.y = -cameraNormal.y;
  lightsCam0.y = - lightsCam0.y;
  lightsCam1.y = - lightsCam1.y;
  
  normPos = transform * position;
  gl_Position = normPos;
}
