shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest_mipmap;
uniform bool apply = false;
uniform bool uses_screen_texture = false;

uniform sampler2D displace_texture;
uniform int displace_amount = 1;
uniform float aberation_amount = 1.0;

void fragment(){ 
	vec4 texture_color = uses_screen_texture ? texture(screen_texture, SCREEN_UV) : texture(TEXTURE, UV);
	vec4 color = texture_color;
	
	if (!apply) {
		COLOR = texture_color;
	} else {
		if (uses_screen_texture) {
			float diplacement = float(displace_amount) * texture(displace_texture, SCREEN_UV).r / 100.0;
			color = texture(screen_texture, vec2(SCREEN_UV.x + diplacement, SCREEN_UV.y));
			
			float aberation = aberation_amount / 100.0;
			color.r = texture(screen_texture, vec2(SCREEN_UV.x + aberation, SCREEN_UV.y)).r;
			color.b = texture(screen_texture, vec2(SCREEN_UV.x - aberation, SCREEN_UV.y)).b;
		} else {
			float diplacement = float(displace_amount) * texture(displace_texture, UV).r / 100.0;
			color = texture(TEXTURE, vec2(UV.x + diplacement, UV.y));
			
			float aberation = aberation_amount / 100.0;
			color.r = texture(TEXTURE, vec2(UV.x + aberation, UV.y)).r;
			color.b = texture(TEXTURE, vec2(UV.x - aberation, UV.y)).b;
		}
		
		COLOR = color;
	}
}
