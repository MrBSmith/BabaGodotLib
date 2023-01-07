shader_type canvas_item;

uniform sampler2D n: repeat_enable;
uniform float intensity = 0.0;
uniform float speed = 0.0;
uniform float threshold : hint_range(0.0, 1.0, 0.01);
uniform vec4 color : source_color = vec4(1.0);

void fragment(){
	vec4 tex = texture(TEXTURE, UV);
	vec4 noise = texture(n, UV + TIME * speed);
	
	COLOR = color;
	float alpha = clamp(mix(tex.a, noise.r, intensity), 0.0, 1.0);
	if(alpha < threshold){
		alpha = 0.0;
	}
	
	COLOR.a = pow(alpha, 2.0) * color.a;
}