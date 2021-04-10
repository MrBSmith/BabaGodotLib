shader_type canvas_item;

uniform sampler2D noise;
uniform float disolve_value : hint_range(0, 1) = 0.0;

void fragment() {
	float noise_color = texture(noise, UV).r;
	
	if(noise_color < disolve_value){
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);
	} else{
		COLOR = texture(TEXTURE, UV);
	}
}