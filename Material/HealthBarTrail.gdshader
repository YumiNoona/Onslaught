shader_type canvas_item;
render_mode blend_premul_alpha;

uniform float health : hint_range(0.0, 1.0) = 1.0;
uniform float trail : hint_range(0.0, 1.0) = 1.0;
uniform float width = 1000.0;
uniform float height = 35.0;
uniform vec4 fill_color : source_color = vec4(0.2, 0.8, 0.2, 1.0);
uniform vec4 trail_color : source_color = vec4(0.8, 0.2, 0.2, 0.6);
uniform vec4 bg_color : source_color = vec4(0.1, 0.1, 0.1, 0.8);
uniform float border_px : hint_range(0.0, 8.0) = 2.0;

void fragment() {
	float fw = width;
	float fh = height;
	vec2 half_border = vec2(border_px) / vec2(fw, fh);

	if (UV.x < half_border.x || UV.x > 1.0 - half_border.x || UV.y < half_border.y || UV.y > 1.0 - half_border.y) {
		COLOR = vec4(1.0, 1.0, 1.0, 1.0);
	} else {
		vec2 inner_uv = vec2(
			(UV.x - half_border.x) / (1.0 - 2.0 * half_border.x),
			(UV.y - half_border.y) / (1.0 - 2.0 * half_border.y)
		);

		float x = inner_uv.x;
		vec4 col = bg_color;

		if (x <= trail) {
			col = trail_color;
		}
		if (x <= health) {
			col = fill_color;
		}

		float border_alpha = 1.0;
		if (inner_uv.y < 0.05) {
			border_alpha = inner_uv.y / 0.05;
		} else if (inner_uv.y > 0.95) {
			border_alpha = (1.0 - inner_uv.y) / 0.05;
		}

		COLOR = vec4(col.rgb, col.a * border_alpha);
	}
}
