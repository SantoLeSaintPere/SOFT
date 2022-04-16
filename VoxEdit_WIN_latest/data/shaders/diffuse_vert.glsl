uniform mat4 transform;
uniform mat4 texMatrix;
uniform mat4 modelview;
uniform mat3 normalMatrix;

// Light direction in world space
uniform vec3 lightsWorldDirection0;

attribute vec4 position;
attribute vec3 normal;
attribute vec2 texCoord;

varying vec4 vertColor;
varying vec4 vertTexCoord;

void main()
{
  gl_Position = transform * position;
  vec3 vertNormal = normalize(normalMatrix * normal);// Get normal direction in model view space
  float intensityA = max(0.3, dot(lightsWorldDirection0, vertNormal));
  float intensityB = max(0.3, dot(-lightsWorldDirection0, vertNormal));
  float intensity = max(intensityA, intensityB);
  vertColor = vec4(intensity, intensity, intensity, 1.0);
  vertTexCoord = texMatrix * vec4(texCoord, 1.0, 1.0);
}
