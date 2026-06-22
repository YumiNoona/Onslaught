shader_type canvas_item;

uniform float intensity : hint_range(0.0, 0.05) = 0.0;
uniform float alpha : hint_range(0.0, 1.0) = 0.0;
uniform vec4 tint_color : source_color = vec4(1.0, 0.0, 0.0, 0.35);
uniform vec2 center = vec2(0.5, 0.5);

void fragment() {
	vec2 uv = SCREEN_UV;
	float strength = intensity * 100.0;
	vec2 dir = normalize(uv - center);
	if (length(uv - center) < 0.001) dir = vec2(1.0, 0.0);
	float offset_val = strength * 0.002;

	float r = texture(SCREEN_TEXTURE, uv + dir * offset_val * 1.5).r;
	float g = texture(SCREEN_TEXTURE, uv).g;
	float b = texture(SCREEN_TEXTURE, uv - dir * offset_val * 1.5).b;

	vec3 screen_col = vec3(r, g, b);
	vec3 final_col = mix(screen_col, tint_color.rgb, alpha);
	COLOR = vec4(final_col, max(alpha, texture(SCREEN_TEXTURE, uv).a));
}
