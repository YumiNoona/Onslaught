shader_type canvas_item;
render_mode unshaded;

uniform float radius : hint_range(0.0, 2.0) = 0.0;
uniform vec2 center = vec2(0.5, 0.5);
uniform vec4 mask_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 bg_color : source_color = vec4(0.0, 0.0, 0.0, 0.0);
uniform float aspect : hint_range(0.1, 3.0) = 1.0;

void fragment() {
	vec2 uv = (UV - center) * vec2(aspect, 1.0);
	float dist = length(uv);
	float mask = step(dist, radius);
	COLOR = mix(bg_color, mask_color, mask);
}
