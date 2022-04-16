uniform mat4 transform;
uniform mat4 texMatrix;
uniform mat3 normalMatrix;

uniform bool lightsEnabled0;
uniform bool lightsEnabled1;

// Light direction in view space
uniform vec3 lightsViewDirection0;
uniform vec3 lightsViewDirection1;

uniform float attenuation = 1.0;

attribute vec4 position;
attribute vec3 normal;
attribute vec2 texCoord;
attribute float aoValue;

varying vec4 vertColor;
varying vec4 vertTexCoord;

void main()
{
float intensity;
  if(lightsEnabled0 || lightsEnabled1)
  {  
    vec3 cameraNormal = normalize(normalMatrix * vec3(normal.x, normal.y, normal.z));
    vec3 lightsCam0 = lightsViewDirection0;
    vec3 lightsCam1 = lightsViewDirection1;

    lightsCam0.y = - lightsCam0.y;
    lightsCam1.y = - lightsCam1.y;
    cameraNormal.y = - cameraNormal.y;
    float intensityA = max(0.0, dot(-lightsCam0, cameraNormal)) * (lightsEnabled0? 1.0f: 0.0f);
    float intensityB = max(0.0, dot(-lightsCam1, cameraNormal)) * (lightsEnabled1? 1.0f: 0.0f);
    intensity = min(intensityA + intensityB, 1.0) * aoValue;
  }
  else
  {
    intensity = attenuation;
  }
  
  vertColor = vec4(intensity, intensity, intensity, 1.0);
  vertTexCoord = texMatrix * vec4(texCoord, 1.0, 1.0);
  gl_Position = transform * position;
}
