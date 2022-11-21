shader_type canvas_item;
uniform float progress : hint_range(0, 1);
const float QSRT_2 = 0.70710678;

void fragment() {
	float rx = (UV.x - 0.5) * (UV.x - 0.5);
	float ry = (UV.y - 0.5) * (UV.y - 0.5);
	if(rx + ry <= QSRT_2 * progress * progress) { COLOR = vec4(0.0); }
}