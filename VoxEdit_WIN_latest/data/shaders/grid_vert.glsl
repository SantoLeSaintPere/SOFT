uniform mat4 transform;
uniform mat4 modelview;

attribute vec4 position;
attribute vec4 color;

uniform vec2 size;
uniform vec2 cellSize;
uniform vec2 offset;

varying vec2 fragCoord;
varying vec4 viewPos;

void main()
{
	fragCoord = (color.xy - vec2(0.5, 0.5)) * (size / cellSize) + offset;
  	viewPos = modelview * position;
	gl_Position = transform * position;
}
