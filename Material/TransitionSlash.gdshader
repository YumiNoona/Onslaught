shader_type canvas_item;
render_mode unshaded;

uniform float t = 0.5;
uniform float power = 10.0;
uniform vec4 mask_color : source_color = vec4(0.0, 0.0, 0.5, 1.0);
uniform vec4 background_color : source_color = vec4(0.0, 0.0, 0.0, 0.0);
uniform vec2 normal = vec2(1.0, 0.5);

void fragment() {
	vec2 p = UV - vec2(0.5, 0.5);
	vec2 n = normalize(normal);
	float dist = abs(dot(n, p));
	float thickness = pow(t, power);
	float line = dist <= thickness ? 1.0 : 0.0;
	COLOR = mix(background_color, mask_color, line);
}
