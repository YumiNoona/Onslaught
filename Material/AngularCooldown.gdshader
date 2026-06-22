shader_type canvas_item;

group_uniforms setup;
uniform vec2 border_width = vec2(2,2);
uniform vec2 panel_size = vec2(200, 20);
uniform bool flip_h = false;

uniform float fill_progress : hint_range(0.0, 1.0) = 1.0;
uniform float edge_smooth : hint_range(0.0, 0.3) = 0.1;

group_uniforms colour_settings;
uniform vec4 solid_colour : source_color = vec4(0.278, 0.675, 0.949,1.0);
uniform vec4 smooth_colour : source_color = vec4(0.278, 0.675, 0.949, 0.5);
uniform vec4 empty_colour : source_color = vec4(1.0, 1.0, 1.0, 0.196);

uniform bool change_colour_with_progress = true;
uniform vec4 solid_low_colour : source_color = vec4(1.0, 0.247, 0.349,1.0);
uniform vec4 smooth_low_colour : source_color = vec4(1.0, 0.247, 0.349,0.5);

vec4 get_progress_colour(vec2 uv){
	float test_value = flip_h ? abs(uv.x+uv.y-1.0) : 1.0 - abs(uv.x+uv.y-1.0);

	if (test_value > 1.0-fill_progress){
		if (change_colour_with_progress){
			return mix(solid_low_colour, solid_colour, fill_progress);
		}
		return solid_colour;
	}

	if (test_value > 1.0-fill_progress-edge_smooth){
		if (change_colour_with_progress){
			return mix(smooth_low_colour, smooth_colour, fill_progress);
		}
		return smooth_colour;
	}

	return empty_colour;
}

bool is_border(vec2 uv){
	vec2 min_border_uv = border_width/panel_size;
	return (uv.x >= 1.0-min_border_uv.x) || (uv.y >= 1.0-min_border_uv.y)||(uv.x<min_border_uv.x)||(uv.y<min_border_uv.y);
}

vec2 uv_to_pixel_coordinate(vec2 uv){
	vec2 pixel_step = vec2(1.0) / panel_size;
	return floor((uv) / pixel_step) * pixel_step;
}

void fragment(){
	vec2 pixel_uv = uv_to_pixel_coordinate(UV);

	COLOR = vec4(0.0);
	if (is_border(pixel_uv)){
		COLOR = get_progress_colour(UV);
	}
}
