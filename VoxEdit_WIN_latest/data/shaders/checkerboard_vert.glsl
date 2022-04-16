uniform mat4 transform;

attribute vec4 position;
attribute vec4 color;

uniform vec2 size;
uniform vec2 cellSize;

varying vec2 fragCoord;

void main()
{
	fragCoord = color.xy * (size / cellSize);
  	gl_Position = transform * position;
}
