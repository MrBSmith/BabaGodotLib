shader_type canvas_item;

// The shader search for colors in the sprites that match colors in the picker palette
// If it find one, replace the color with the corresponding one in the dest_palette
// If it doesn't the original color is used
// The two palettes must be textures of the same size 
uniform sampler2D picked_palette;
uniform sampler2D dest_palette;

uniform bool invert_dest_palette = false;
uniform float tolerance : hint_range(0.0, 1.0, 0.001) = 0.1;  

bool are_same_color(vec4 a, vec4 b) {
	vec4 sub = abs(a - b);
	
	return (sub.r < tolerance && sub.g < tolerance && sub.b < tolerance && sub.a < tolerance);
}

// Get the u component representing the x position of the given color in the picked_palette
vec2 get_color_picker_uv(vec4 color) {
	ivec2 picked_palette_size = textureSize(picked_palette, 0);
	
	for (int i = 0; i < picked_palette_size.x; i++) {
		for (int j = 0; j < picked_palette_size.y; j++) {
			vec2 uv = vec2(
				(float(i) + 0.5) / float(picked_palette_size.x),
				(float(j) + 0.5) / float(picked_palette_size.y)
			);
			vec4 picker_color = texture(picked_palette, uv);
			
			if (are_same_color(color, picker_color)) {
				return uv;
			}
		}
	}
	
	return vec2(-1.0);
}

void fragment() {
	vec4 texture_color = texture(TEXTURE, UV);
	ivec2 dest_palette_size = textureSize(dest_palette, 0);
	
	vec2 picker_uv = get_color_picker_uv(texture_color);
	
	if (picker_uv == vec2(-1.0) || dest_palette_size == ivec2(1)) {
		COLOR = texture_color;
	} else {
		if (invert_dest_palette) {
			picker_uv = vec2(1.0 - picker_uv.x, 1.0 - picker_uv.y);
		}
		
		COLOR = texture(dest_palette, picker_uv);
	}
}
