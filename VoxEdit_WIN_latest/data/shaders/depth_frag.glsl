uniform float zNear;
uniform float zFar;

varying vec4 viewPos;
varying vec3 viewNormal;

vec4 packDepth(float depth) {
  float depthFrac = fract(depth * 255.0);
  return vec4(depth - depthFrac / 255.0, depthFrac, 1.0, 1.0);
}

float unpackDepth(vec4 color) {
  return color.r + color.g / 255.0;
}
void main()
{
	float depth = -viewPos.z / (zFar - zNear);
	depth = clamp(depth, 0.0f, 1.0f);
	vec4 packedDepth = packDepth(depth);
	gl_FragColor.rgba = packedDepth.rgba;
}
