#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;

varying vec4 vertColor;
varying vec4 vertTexCoord;

void main()
{
	vec4 rgbColor = texture2D(texture, vertTexCoord.st) * vertColor;
	float grey = 0.3 * rgbColor.r + 0.59 * rgbColor.g + 0.11 * rgbColor.b;
	gl_FragColor = vec4(grey, grey, grey, rgbColor.a);
}
