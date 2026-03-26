shader_type canvas_item;

uniform vec4 color: source_color = vec4(1.0);
uniform float blend: hint_range(0.0, 1.0) = 0.0;

varying vec4 vertex_color;

void vertex() {
	vertex_color = COLOR;
}

void fragment(){
	vec4 text_color = texture(TEXTURE, UV) * vertex_color;
	
	if (text_color.a > 0.0){
		COLOR = mix(text_color, color, blend);
	}
	else {
		COLOR = text_color;
	}
}