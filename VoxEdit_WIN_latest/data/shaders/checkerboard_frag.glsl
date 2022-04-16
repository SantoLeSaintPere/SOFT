#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform vec3 cellColor1;
uniform vec3 cellColor2;

varying vec2 fragCoord;

void main()
{
	float total = floor(fragCoord.x) + floor(fragCoord.y);
    float evenCell = mod(total, 2.0);
    gl_FragColor = vec4(evenCell * cellColor1 + (1.0 - evenCell) *  cellColor2, 1.0);
}
