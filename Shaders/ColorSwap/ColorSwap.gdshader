shader_type canvas_item;

uniform sampler2D palette_texture;
uniform bool inverted = false;
uniform float blend : hint_range(0.0, 1.0) = 1.0;

void fragment(){
	vec4 color = texture(TEXTURE, UV);

	if(color.a == 0.0){
		discard;
	}
	
	float alpha = COLOR.a;
	float value = (COLOR.r + COLOR.g + COLOR.b) / 3.0;
	int color_index = 0;
	
	if (inverted){
		value = 1.0 - value;
	}

	vec4 result_color = vec4(texture(palette_texture, vec2(float(value), 0.0)).rgb, alpha);
	COLOR = mix(color, result_color, blend);
}

