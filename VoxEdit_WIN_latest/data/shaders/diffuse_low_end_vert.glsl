#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform mat4 transform;
uniform mat3 normalMatrix;

uniform float ambient;
uniform float lightsEnabled0;
uniform float lightsEnabled1;
uniform vec3 lightDir0;
uniform vec3 lightDir1;

uniform sampler2D paletteTex;
uniform float paletteSize;

attribute vec4 position;
attribute vec3 normal;
attribute vec4 color;

varying vec4 vertColor;

void main()
{
	float intensity = 1.0 - max(lightsEnabled0, lightsEnabled1);

	// Processing box() primitives have their normal inverted in the Y axis
	// Once we unify previews with normal voxel rendering, this can be removed
	vec3 correctedNormal = normal;
	if (color.a < 0.001f)
	{
		float mat = (color.r * 255.0 + 0.5) / paletteSize;
		vertColor = texture2D(paletteTex, vec2(mat, 0.25));
	}
	else
	{
		vertColor = color;
		correctedNormal.y *= -1.0;
	}

	intensity += max(0.0, lightsEnabled0 * -dot(lightDir0, correctedNormal));
	intensity += max(0.0, lightsEnabled1 * -dot(lightDir1, correctedNormal));
	intensity = clamp(intensity, ambient, 1.0);

    vertColor = vec4(vertColor.rgb * intensity, vertColor.a);

	gl_Position = transform * position;
}
