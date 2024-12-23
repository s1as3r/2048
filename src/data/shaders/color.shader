extern vec4 scale;

vec4 effect(vec4 _, Image texture, vec2 tc, vec2 __) {
  vec4 pixel = Texel(texture, tc);
  return pixel * scale;
}
