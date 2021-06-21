shader_type canvas_item;

uniform vec4 outline_color : hint_color; 
uniform vec2 uv_origin = vec2(0.0); 
uniform vec2 uv_part_size = vec2(1);
uniform vec2 region_size = vec2(32.0, 16.0);
uniform vec2 region_pos = vec2(0.0); 

bool has_empty_neighbour(sampler2D text, vec2 coord){
	vec2 text_size = vec2(textureSize(text, 0));
	
	for(int i = -1; i < 2; i += 2){
		for(int j = 0; j < 2; j++){
			vec2 point = coord + vec2(float(i)) * vec2(float(j == 0), float(j == 1));
			vec2 point_uv = point / text_size;
			
			if (point_uv.x <= 0.0 || point_uv.y <= 0.0 || point_uv.x >= 1.0 || point_uv.y >= 1.0){
				return true;
			}
			
			vec4 point_color = texture(text, point_uv);
			if(point_color.a == 0.0){
				return true;
			}
		}
	}
	return false;
}


void fragment(){
	vec2 text_size = vec2(textureSize(TEXTURE, 0));
	vec2 uv_rect_origin = region_pos / text_size + uv_origin / (text_size / region_size); 
	
	vec2 uv_region_size = uv_part_size;
	if (region_size != vec2(0)){
		uv_region_size = (region_size / text_size) * uv_part_size;
	}
	
	vec2 current_pixel = UV * text_size;
	vec2 uv_part_max = uv_rect_origin + uv_region_size;
	vec4 color = texture(TEXTURE, UV);
	
	if(UV.x <= uv_rect_origin.x || UV.y <= uv_rect_origin.y ||
		UV.x >= uv_part_max.x || UV.y >= uv_part_max.y 
		|| color.a == 0.0 || !has_empty_neighbour(TEXTURE, current_pixel)){
		COLOR = color;
	} else COLOR = outline_color;
}