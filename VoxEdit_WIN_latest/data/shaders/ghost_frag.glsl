#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;
uniform float alpha;

varying vec4 vertColor;
varying vec4 vertTexCoord;

void main()
{
	vec4 rgbColor = texture2D(texture, vertTexCoord.st) * vertColor;
	gl_FragColor = vec4(rgbColor.r, rgbColor.g, rgbColor.b, rgbColor.a * alpha);

}
