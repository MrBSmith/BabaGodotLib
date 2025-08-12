shader_type canvas_item;

uniform sampler2D noise: repeat_enable;
uniform float intensity = 0.0;
uniform float speed = 0.0;
uniform float threshold : hint_range(0.0, 1.0, 0.01);
uniform vec4 color : source_color = vec4(1.0);
uniform float opacity : hint_range(0.0, 1.0);

void fragment(){
	vec4 tex = texture(TEXTURE, UV);
	vec4 noise_color = texture(noise, UV + TIME * speed);
	
	COLOR = color;
	
	float noise_value = noise_color.r;
	if (noise_value < threshold) {
		noise_value = 0.0;
	}
	
	float alpha = clamp(tex.a * intensity * noise_value * opacity, 0.0, 1.0);
	COLOR.a = pow(alpha, 2.0) * color.a;
}