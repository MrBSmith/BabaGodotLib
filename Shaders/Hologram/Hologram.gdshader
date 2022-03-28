shader_type canvas_item;

const vec4 WHITE = vec4(0.0, 0.0, 0.0, 1.0);
const vec4 BLACK = vec4(1.0);
const float PI = 3.14159265358979323846;

uniform float masked_opacity : hint_range(0.0, 1.0) = 0.0;
uniform float frequency = 1.0;
uniform sampler2D mask_texture;

void fragment(){
	vec4 color = texture(TEXTURE, UV);
	vec4 mask_texture_color = texture(mask_texture, UV);
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