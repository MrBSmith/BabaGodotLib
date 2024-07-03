/*
	放射状ブラーエフェクト by あるる（きのもと　結衣） @arlez80
	Radial Blur Effect by Yui Kinomoto

	MIT License
*/
shader_type canvas_item;

uniform vec2 blur_center = vec2( 0.5, 0.5 );
uniform float blur_power : hint_range( -1.0, 1.0 ) = 0.0;
uniform int sampling_count : hint_range( 1, 64 ) = 6;

void fragment( )
{
	vec2 direction = UV - blur_center;
	vec3 c = vec3(0.0, 0.0, 0.0);
	float f = 1.0 / float(sampling_count);
	float dist = length(direction);
	for(int i = 0; i < sampling_count; i++) {
		c += texture(TEXTURE, UV - blur_power * direction * float(i) * dist).rgb * f;
	}
	COLOR.rgb = c;
}
