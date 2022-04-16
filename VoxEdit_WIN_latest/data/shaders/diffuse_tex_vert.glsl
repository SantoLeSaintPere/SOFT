#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform mat4 transform;
uniform mat4 texMatrix;
uniform mat4 modelview;
uniform mat3 normalMatrix;

// Light direction in view space
uniform vec3 lightsViewDirection0;
uniform vec3 lightsViewDirection1;

uniform mat4 shadowTransform0;
uniform mat4 shadowTransform1;

uniform sampler2D paletteTex;
uniform float paletteSize;

uniform float minAmbient;
uniform bool withoutTexture;

attribute vec4 position;
attribute vec3 normal;
attribute vec4 color;
attribute vec2 texCoord;

varying vec4 vertColor;
varying vec4 vertTexCoord;
varying vec4 normPos;
varying vec4 shadowCoord0;
varying vec4 shadowCoord1;
varying vec3 cameraNormal;
varying vec3 lightsCam0;
varying vec3 lightsCam1;
varying vec4 vertPosition;

void main()
{
  vertPosition = modelview * position; // Get vertex position in model view space
  vec3 vertNormal = normalize(normalMatrix * normal);// Get normal direction in model view space

  shadowCoord0 = shadowTransform0 * (vertPosition);
  shadowCoord1 = shadowTransform1 * (vertPosition);

  cameraNormal = normalMatrix * vec3(normal.x, normal.y, normal.z);

  lightsCam0 = lightsViewDirection0;
  lightsCam1 = lightsViewDirection1;

  cameraNormal.y = -cameraNormal.y;
  lightsCam0.y = - lightsCam0.y;
  lightsCam1.y = - lightsCam1.y;
  
  if (withoutTexture)
  {
    if (color.a < 0.001f)
    {
      float mat = (color.r * 255.0 + 0.5) / paletteSize;
      vertColor = texture2D(paletteTex, vec2(mat, 0.25));
    }
    else
      vertColor = color;
  }
  else
  {
    vertColor = vec4(1.0f, 1.0f, 1.0f, 1.0);
  }

  normPos = transform * position;
  gl_Position = normPos;
  vertTexCoord = texMatrix * vec4(texCoord, 1.0, 1.0);
}
