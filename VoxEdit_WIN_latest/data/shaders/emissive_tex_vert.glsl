uniform mat4 transformMatrix;
uniform mat4 texMatrix;

attribute vec4 position;
attribute vec2 texCoord;
attribute vec4 color;

uniform bool withoutTexture;
uniform sampler2D paletteTex;
uniform float paletteSize;

varying vec4 vertTexCoord;
varying vec4 vertColor;

void main()
{
  if(withoutTexture)
  {
    if (color.a < 0.001f)
    {
      float mat = (color.r * 255.0 + 0.5) / paletteSize;
      vertColor = texture2D(paletteTex, vec2(mat, 0.75));
    }
    else
      vertColor = color;
  }
  else
  {
    vertColor = vec4(1.0f, 1.0f, 1.0f, 1.0f);
  }

  vertTexCoord = texMatrix * vec4(texCoord, 1.0, 1.0);
  gl_Position = transformMatrix * position;                              
}
