shader_type canvas_item;
render_mode unshaded;

uniform bool apply = false;

uniform sampler2D displace_texture : hint_albedo;
uniform int displace_amount = 1;
uniform float aberation_amount = 1.0;

void fragment(){
	vec4 texture_color = texture(TEXTURE, UV);
	vec4 color = texture_color;
	if(apply == true){
		float diplacement = float(displace_amount) * texture(displace_texture, UV).r / 100.0;
		color = texture(TEXTURE, vec2(UV.x + diplacement, UV.y));
		
		float aberation = aberation_amount / 100.0;
		color.r = texture(TEXTURE, vec2(UV.x + aberation, UV.y)).r;
		color.b = texture(TEXTURE, vec2(UV.x - aberation, UV.y)).b;
	}
	
	COLOR = color;
}
