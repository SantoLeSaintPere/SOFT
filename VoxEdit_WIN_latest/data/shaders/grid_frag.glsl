#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform float thickness;
uniform vec4 lineColor;
uniform vec4 bgColor;
uniform float cameraNear;
uniform float cameraFar;
uniform float depthThreshold; // as normalized value, from near to far

varying vec2 fragCoord;
varying vec4 viewPos;

void main()
{
	float depth = -viewPos.z / (cameraFar * depthThreshold - cameraNear);
	depth = clamp(depth, 0.0f, 1.0f);
	depth = 1.0 - pow(depth * (1.0 / depthThreshold), 3.0);

	vec2 grid = abs(fract(fragCoord - 0.5) - 0.5) / (fwidth(fragCoord) * thickness);
	float line = min(grid.x, grid.y);
	line = 1.0 - min(line, 1.0);
	float a = (lineColor.a * line + bgColor.a * (1.0 - line)) * depth;

	if (a < 0.001)
		discard;

	gl_FragColor = vec4(lineColor.rgb * line + bgColor.rgb * (1.0 - line), a);
}
