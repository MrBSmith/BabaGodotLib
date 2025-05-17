shader_type canvas_item;

uniform vec4 transparent_color : source_color = vec4(0.0, 1.0, 0.0, 1.0);

void fragment(){
	vec4 color = texture(TEXTURE, UV, 0.0);
	
	if (color == transparent_color){
		COLOR = vec4(0.0);
	} else {
		COLOR = color;
	}
}