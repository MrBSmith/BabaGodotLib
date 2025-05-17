shader_type canvas_item;

uniform vec2 offset = vec2(-1.0, 1.0);
uniform float scale : hint_range(0.0, 100.0, 0.01);
uniform sampler2D mask: repeat_enable, filter_nearest;
uniform vec4 shine_color: source_color;
uniform float opacity : hint_range(0.0, 1.0, 0.01) = 1.0;

void fragment() {
	vec4 mask_color = shine_color;
	ivec2 mask_size = textureSize(mask, 0);
	ivec2 text_size = textureSize(TEXTURE, 0);
	vec2 aspect_ratio = (vec2(mask_size) / vec2(text_size)) * scale;
	
	mask_color.a = texture(mask, (UV / aspect_ratio) + offset).a;
	
	vec4 origin_color = texture(TEXTURE, UV);
	vec4 result_color = origin_color;
	
	if (origin_color.a != 0.0 && mask_color.a != 0.0){
		vec4 glow_result_color = shine_color * mask_color;
		result_color = mix(origin_color, glow_result_color, opacity * mask_color.a);
	}
	
	COLOR = result_color;
}
