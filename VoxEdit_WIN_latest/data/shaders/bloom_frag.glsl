#define PROCESSING_TEXTURE_SHADER

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture; // diffuse
uniform sampler2D emissive;

varying vec4 vertTexCoord;

void main()
{
    vec4 emissiveColor = texture2D(emissive, vertTexCoord.xy);
	vec4 diffuseColor = texture2D(texture, vertTexCoord.xy);

	if (diffuseColor.a < emissiveColor.a)
	{
		float g = (emissiveColor.r * 0.299 + emissiveColor.g * 0.587 + emissiveColor.b * 0.114) * step(0.0, diffuseColor.a);
		gl_FragColor = vec4(clamp(diffuseColor.xyz + emissiveColor.xyz, 0.0, 1.0), g);
	}
	else
	{
		gl_FragColor = vec4(clamp(diffuseColor.xyz + emissiveColor.xyz, 0.0, 1.0), diffuseColor.a);
	}
}
