#ifdef GL_ES
precision highp float;
precision highp int;
#endif

uniform mat4 texMatrix;

uniform sampler2D shadowMap0;
uniform sampler2D shadowMap1;

uniform bool withoutTexture;
uniform sampler2D indicesTex;
uniform sampler2D ssaoTex;

uniform sampler2D paletteTex;
uniform float paletteSize;
uniform float indexWidth;
uniform float indexHeight;

uniform bool lightsEnabled0;
uniform bool lightsEnabled1;

varying vec4 vertColor;
varying vec4 vertTexCoord;
varying vec4 normPos;
varying vec4 vertPosition;

varying vec4 shadowCoord0;
varying vec4 shadowCoord1;
varying vec3 cameraNormal;
varying vec3 lightsCam0;
varying vec3 lightsCam1;
uniform float minAmbient;

const vec2 poissonDisk[9] = vec2[] (
      vec2(0.95581, -0.18159), vec2(0.50147, -0.35807), vec2(0.69607, 0.35559),
      vec2(-0.0036825, -0.59150), vec2(0.15930, 0.089750), vec2(-0.65031, 0.058189),
      vec2(0.11915, 0.78449), vec2(-0.34296, 0.51575), vec2(-0.60380, -0.41527)
      );

const float minBias = 0.001;
const float maxBias = 0.009;

// Unpack the 16bit depth float from the first two 8bit channels of the rgba vector
float unpackDepth(vec4 color) 
{
 	return color.r + color.g / 255.0;
}

float GetLightInstensity(vec3 lDir, vec3 surfaceNormal, vec3 viewDir, bool lightEnabled, float diffuseStrenght, float specularStrenght, out float lCamDot)
{
  lCamDot = dot(-lDir, surfaceNormal);
  float lDiffuse = max(0.0f, lCamDot) * (lightEnabled? 1.0f: 0.0f);  
  lDiffuse = clamp(lDiffuse, 0.0f, 1.0f);

  vec3 halfVector = reflect(-lDir, surfaceNormal) ;  
  halfVector.y = -halfVector.y;

  float lSpecular = pow(max(dot(viewDir, halfVector), 0.0f), 64) * (lightEnabled? 1.0f: 0.0f);

  float lightIntensity = 0.0f;
  lightIntensity = diffuseStrenght * lDiffuse + specularStrenght * lSpecular;
  return lightIntensity;
}

float GetShadowVisiblity(bool lightsEnabled, float lCamDot, sampler2D shadowMap, vec4 shadowCoord)
{ 
  float visibility = 0.0f ;
  float faceBias = clamp(lCamDot, 0.0f, 1.0f);
  vec3 shadowCoordProj = shadowCoord.xyz / shadowCoord.w;

  if(lightsEnabled)
  {
    if(lCamDot <= 0.0f)
    {
      visibility = 0.0f;
    }
    else
    {
      float shadowBias = max(maxBias * (1.0 - faceBias), minBias);
      for(int n = 0; n < 9; ++n)
      {          
        visibility += step(shadowCoordProj.z - shadowBias, unpackDepth(texture2D(shadowMap, shadowCoordProj.xy + poissonDisk[n] / 4096.0)));
      }
    }
  }

  // Normalize Poisson kernel. The dot is needed to prevent shadow acne for perpendicular directions
  return visibility * 0.11111 * lCamDot;
}

void main()
{
    // Lights
  float specularStrenght = 0.0f;  
  float diffuseStrenght = 0.6f;
  vec3 viewDir = normalize(vertPosition.xyz);
  float l0CamDot, l1CamDot;
  float lightIntensity0 = GetLightInstensity(normalize(lightsCam0), normalize(cameraNormal), viewDir, lightsEnabled0, diffuseStrenght, specularStrenght, l0CamDot);
  float lightIntensity1 = GetLightInstensity(normalize(lightsCam1), normalize(cameraNormal), viewDir, lightsEnabled1, diffuseStrenght, specularStrenght, l1CamDot);

  // SSAO
  vec4 offset = normPos;  
  offset.xyz /= offset.w; // perspective divide
  offset.xyz = offset.xyz * 0.5 + 0.5; // transform to range 0.0 - 1.0
  float occlusion = texture(ssaoTex, offset.xy).r;	

  // Shadows
  float visibility0 = GetShadowVisiblity(lightsEnabled0, l0CamDot, shadowMap0, shadowCoord0);
  float visibility1 = GetShadowVisiblity(lightsEnabled1, l1CamDot, shadowMap1, shadowCoord1);
  float visibility = max(visibility0, visibility1);

  float resultingL = minAmbient;
  if(lightsEnabled0 || lightsEnabled1)
  {
    resultingL = (lightIntensity0 + lightIntensity1) * visibility;
  }
  else
  {
    occlusion = 1.0f;
  }

  if (withoutTexture)
    gl_FragColor = vec4 (vertColor.rgb * clamp(resultingL + minAmbient * occlusion, 0.0f, 1.0f)  , vertColor.a);
  else
  {
    // Solve indirect sampling using indices into palette
    float index = texture2D(indicesTex, vertTexCoord.st).b;
        
    // Transform to palette space  
    const float samplingOffset = 0.5f;
    index = floor(index * 255.0f) + samplingOffset;

    // We're in the first row of the palette as t<his pass is diffuse
    vec4 color = texelFetch(paletteTex, ivec2(int(index), 0),0);
    gl_FragColor = vec4 (color.rgb * clamp(resultingL + minAmbient * occlusion, 0.0f, 1.0f)  , vertColor.a);
  }
}