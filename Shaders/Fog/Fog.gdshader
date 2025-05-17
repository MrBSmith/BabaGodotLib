shader_type canvas_item;

uniform sampler2D noise1: repeat_enable;
uniform sampler2D noise2: repeat_enable;

uniform vec4 fog_color : source_color = vec4(0.7, 0.0, 0.5, 1);
uniform vec2 speed = vec2(0.5);
uniform float opacity = 0.5;

uniform float vertical_fade : hint_range(0.0, 1.0) = 0.0;
uniform float border_fade : hint_range(0.0, 1.0) = 0.0;

uniform float vertical_crop : hint_range(-1.0, 1.0) = 0.0;

uniform vec2 texture_size = vec2(0.0);
uniform vec2 region_rect = vec2(0.0);

float dist_to_point(vec2 p1, vec2 p2){
	return sqrt(pow(p2.x - p1.x, 2.0) + pow(p2.y - p1.y, 2.0));
}

void fragment(){
	vec2 bottom_right = region_rect / texture_size;
	vec2 region_UV = UV / bottom_right;

	float current_noise_level = texture(noise1, UV + TIME * speed).r;
	vec2 motion = vec2(current_noise_level);

	float surface = (region_UV.x + motion.x);
	float final = texture(noise2, UV + motion).r / 2.0;

	vec4 color = vec4(vec3(fog_color.r, fog_color.g, fog_color.b), final * opacity);

	// Vertical fade
	float v_fade_amount = region_UV.y;
	color.a *= mix(v_fade_amount, 1.0, 1.0 - vertical_fade);

	// Border fade
	float dist_to_center = dist_to_point(region_UV, vec2(0.5));
	float border_fade_amount = mix(1.0 - dist_to_center * 2.0, 1.0, 1.0 - border_fade);
	color.a *= clamp(border_fade_amount, 0.0, 1.0);

	if(region_UV.y > 1.0 - vertical_crop){
		color.a = 0.0;
	}

	COLOR = color;
}