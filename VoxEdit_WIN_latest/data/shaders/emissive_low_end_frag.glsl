#ifdef GL_ES
precision highp float;
precision highp int;
#endif

varying vec4 vertColor;

void main()
{
	gl_FragColor = vertColor;
}
