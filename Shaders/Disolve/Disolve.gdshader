shader_type canvas_item;

uniform sampler2D noise;
uniform float amount : hint_range(0, 1) = 0.0;

void fragment() {
	float noise_color = texture(noise, UV).r;
	
	if(noise_color < amount){
		COLOR.a = 0.0;
	} else {
		COLOR.a = texture(TEXTURE, UV).a;
	}
}