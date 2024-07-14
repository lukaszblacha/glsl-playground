precision highp float;

attribute vec3 aPosition;
attribute vec2 aTexCoord;

varying vec2 vPos;

void main() {
  vPos = aTexCoord.yx;

  gl_Position = vec4(aPosition, 1.0);
}
