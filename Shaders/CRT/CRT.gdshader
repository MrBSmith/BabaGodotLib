shader_type canvas_item;

uniform bool apply = false;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D displace_texture : source_color;
uniform int displace_amount = 1;
uniform float aberation_amount = 1.0;
uniform float warp_amount = 1.0;


// Takes in the UV and warps the edges, creating the spherized effect
vec2 warp(vec2 uv){
	vec2 delta = uv - 0.5;
	float delta2 = dot(delta.xy, delta.xy);
	float delta4 = delta2 * delta2;
	float delta_offset = delta4 * warp_amount;
	
	return uv + delta * delta_offset;
}

void fragment(){ 
	vec2 uv = warp(SCREEN_UV);
	vec4 texture_color = texture(screen_texture, uv);
	vec4 color = texture_color;
	
	if(apply == true){
		float diplacement = float(displace_amount) * texture(displace_texture, uv).r / 100.0;
		color = texture(screen_texture, vec2(uv.x + diplacement, uv.y));
		
		float aberation = aberation_amount / 100.0;
		color.r = texture(screen_texture, vec2(uv.x + aberation, uv.y)).r;
		color.b = texture(screen_texture, vec2(uv.x - aberation, uv.y)).b;
	}
	
	COLOR = color;
}
