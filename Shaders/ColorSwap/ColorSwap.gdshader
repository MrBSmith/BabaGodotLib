shader_type canvas_item;

uniform sampler2D palette_texture;
uniform bool inverted = false;

void fragment(){
	vec4 color = texture(TEXTURE, UV);
	
	if(color.a == 0.0){
		discard;
	}
	
	float alpha = COLOR.a;
	float value = (color.r + color.g + color.b) / 3.0;
	int color_index = 0;
	
	if (inverted){
		value = 1.0 - value;
	}
	
	COLOR = vec4(texture(palette_texture, vec2(float(value), 0.0)).rgb, alpha);
}

