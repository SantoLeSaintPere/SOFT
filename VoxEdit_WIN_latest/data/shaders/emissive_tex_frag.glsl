#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;
uniform bool withoutTexture;

varying vec4 vertTexCoord;
varying vec4 vertColor;

void main()
{	
	if(withoutTexture)
	{
		gl_FragColor = vertColor;
	}
	else
	{
		gl_FragColor = texture2D(texture, vertTexCoord.st);
	}
}