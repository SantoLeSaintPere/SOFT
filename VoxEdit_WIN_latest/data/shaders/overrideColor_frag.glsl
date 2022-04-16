#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform vec3 overrideColor;

void main()
{
  gl_FragColor = vec4(overrideColor, 1.0);
}