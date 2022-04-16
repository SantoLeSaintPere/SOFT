#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform mat4 transform;

uniform sampler2D paletteTex;
uniform float paletteSize;

attribute vec4 position;
attribute vec3 normal;
attribute vec4 color;

varying vec4 vertColor;

void main()
{
	float mat = (color.r * 255.0 + 0.5) / paletteSize;
	vertColor = texture2D(paletteTex, vec2(mat, 0.75));

	gl_Position = transform * position;
}
