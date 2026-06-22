shader_type canvas_item;

uniform float threshold : hint_range(0.0, 1.0) = 0.0;
uniform vec2 hit_uv = vec2(0.5, 0.5);
uniform float noise_scale : hint_range(0.5, 10.0) = 3.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void fragment() {
	vec2 uv = UV * noise_scale;
	float n = noise(uv + floor(TIME * 2.0));
	float dist = distance(UV, hit_uv);
	float dissolve = n * 0.7 + dist * 1.5 - threshold;

	if (dissolve < 0.0) {
		discard;
	}

	vec4 col = texture(TEXTURE, UV);
	float edge = 1.0 - smoothstep(-0.15, 0.0, dissolve);
	col.rgb = mix(col.rgb, vec3(1.0, 0.5, 0.0), edge * 0.6);
	COLOR = col;
}
