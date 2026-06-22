shader_type canvas_item;

uniform vec4 color_gap : source_color = vec4(0.15, 0.0, 0.0, 0.3);
uniform vec4 color_stripe : source_color = vec4(1.0, 0.3, 0.0, 0.5);
uniform float divisions = 6.0;
uniform float speed = 0.05;
uniform float angle = 0.7854;
uniform float stripe_width : hint_range(0.01, 1.0) = 0.4;

void fragment() {
	float w = cos(angle) * UV.x + sin(angle) * UV.y;
	w -= TIME * speed;

	float pattern = fract(w * divisions);
	float inside_stripe = step(pattern, stripe_width);
	float gradient_alpha = 1.0 - clamp(pattern / stripe_width, 0.0, 1.0);
	float stripe_mask = inside_stripe * gradient_alpha;

	COLOR = mix(color_gap, color_stripe, stripe_mask);
	COLOR.a = mix(color_gap.a, color_stripe.a, stripe_mask);
}
