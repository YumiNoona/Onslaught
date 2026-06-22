shader_type canvas_item;

uniform float border_px : hint_range(2.0, 24.0) = 3.0;
uniform float speed : hint_range(0.1, 4.0) = 0.9;
uniform float glow_intensity : hint_range(1.0, 3.5) = 2.0;
uniform vec2 node_size = vec2(100.0, 120.0);

vec3 hsv_to_rgb(vec3 c) {
	vec4 k = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + k.xyz) * 6.0 - k.www);
	return c.z * mix(k.xxx, clamp(p - k.xxx, 0.0, 1.0), c.y);
}

void fragment() {
	vec2 pixel = UV * node_size;

	float dist_left   = pixel.x;
	float dist_right  = node_size.x - pixel.x;
	float dist_top    = pixel.y;
	float dist_bottom = node_size.y - pixel.y;
	float edge_dist   = min(min(dist_left, dist_right), min(dist_top, dist_bottom));

	if (edge_dist > border_px) {
		COLOR = vec4(0.0);
	} else {
		float denom  = max(node_size.x + node_size.y, 1.0);
		float phase   = (pixel.x + pixel.y) / denom;
		float hue     = fract(TIME * speed * 0.25 + phase);
		vec3  rainbow = hsv_to_rgb(vec3(hue, 1.0, 1.0));

		float alpha = 1.0 - smoothstep(0.0, border_px, edge_dist);
		alpha = pow(alpha, 0.5);

		COLOR = vec4(rainbow * glow_intensity, alpha * 0.92);
	}
}
