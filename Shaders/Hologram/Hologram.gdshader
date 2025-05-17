shader_type canvas_item;

const vec2 MASK_SIZE = vec2(2.0);
const vec4 WHITE = vec4(0.0, 0.0, 0.0, 1.0);
const vec4 BLACK = vec4(1.0);

uniform float masked_opacity : hint_range(0.0, 1.0) = 0.4;
uniform float frequency = 6.0;
uniform sampler2D mask_texture: repeat_enable, filter_nearest;

uniform float deform_speed = 0.0;
uniform float deform_freq = 4.0;
uniform vec2 deform_amp = vec2(0.1, 0.0);

void fragment(){
	vec2 sin_movement = deform_amp * vec2(sin(TIME * vec2(deform_speed, 0.0) * 2.0 * PI));
	vec2 offset = sin_movement * sin(UV.y * deform_freq * 2.0 * PI);
	vec2 texture_size = vec2(1.0) / TEXTURE_PIXEL_SIZE;
	vec2 aspect_ratio = texture_size / MASK_SIZE;
	
	vec4 color = texture(TEXTURE, offset + UV);
	vec4 mask_texture_color = texture(mask_texture, UV * aspect_ratio);
	vec4 mask_color;
	
	if (sin(2.0 * PI * frequency * float(TIME)) > 0.0){
		mask_color = WHITE;
	} else {
		mask_color = BLACK;
	}
	
	if (mask_texture_color == mask_color){
		COLOR = color;
	} else {
		if (color.a != 0.0){
			COLOR = vec4(color.r, color.g, color.b, masked_opacity);
		} else {
			discard;
		}
	}
}