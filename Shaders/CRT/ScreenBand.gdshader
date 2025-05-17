shader_type canvas_item;

const vec2 mask_size = vec2(2.0);
const vec4 WHITE = vec4(0.0, 0.0, 0.0, 1.0);
const vec4 BLACK = vec4(1.0);

uniform float masked_opacity : hint_range(0.0, 1.0) = 0.4;
uniform vec4 render_mask_color : source_color = vec4(1.0);
uniform float frequency = 6.0;
uniform sampler2D mask_texture : repeat_enable, filter_nearest;

uniform float deform_speed = 0.0;
uniform float deform_freq = 4.0;
uniform vec2 deform_amp = vec2(0.1, 0.0);

void fragment(){
	vec4 color = texture(TEXTURE, UV);
	vec2 texture_size = vec2(1.0) / TEXTURE_PIXEL_SIZE;
	vec2 text_to_mask_ratio = texture_size / mask_size;
	
	vec4 mask_texture_color = texture(mask_texture, UV * text_to_mask_ratio);
	vec4 mask_color;
	
	if (sin(2.0 * PI * frequency * float(TIME)) > 0.0){
		mask_color = WHITE;
	} else {
		mask_color = BLACK;
	}
	
	if (mask_texture_color == mask_color || color.a == 0.0) {
		COLOR = vec4(0.0);
	} else {
		COLOR = mix(vec4(0.0), render_mask_color, masked_opacity);
	}
}