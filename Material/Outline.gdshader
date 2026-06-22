shader_type canvas_item;

uniform float outline_width: hint_range(1.0, 5.0) = 2.0;
uniform vec4 outline_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec2 texture_size = vec2(256.0, 256.0);
uniform bool enabled = true;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	float alpha = col.a;

	if (enabled) {
		float outline = 0.0;
		float w = outline_width / texture_size.x;
		float h = outline_width / texture_size.y;

		for (float x = -1.0; x <= 1.0; x += 1.0) {
			for (float y = -1.0; y <= 1.0; y += 1.0) {
				if (x == 0.0 && y == 0.0) continue;
				vec2 sample_uv = UV + vec2(x * w, y * h);
				vec4 sample = texture(TEXTURE, sample_uv);
				outline = max(outline, sample.a);
			}
		}

		if (alpha < 0.5 && outline > 0.5) {
			COLOR = outline_color;
		} else {
			COLOR = col;
		}
	} else {
		COLOR = col;
	}
}
