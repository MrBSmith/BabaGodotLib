shader_type canvas_item;

uniform float warp_amount = 1.0;
uniform float blur_factor = 0.1;

float get_wrap_delta(vec2 uv) {
	vec2 delta = uv - 0.5;
	float delta2 = dot(delta.xy, delta.xy);
	float delta4 = delta2 * delta2;
	return delta4 * warp_amount;
}

// Takes in the UV and warps the edges, creating the spherized effect
vec2 warp(vec2 uv, float delta_offset) {
	vec2 delta = uv - 0.5;
	return clamp(uv + delta * delta_offset, vec2(0.0), vec2(1.0));
}

vec4 blur(vec2 uv, float amount, sampler2D text) {
	vec4 color = vec4(0.0);
	
	for(int i = 0; i < 10; i++) {
		float offset = amount * float(i);
		color += texture(text, uv * (1.0 - offset) + 0.5 * offset);
	}
	return color / 10.0;
}


void fragment() {
	float delta_offset = get_wrap_delta(UV);
	vec2 uv = warp(UV, delta_offset);
	float blur_amount = delta_offset * blur_factor;
	
	COLOR = blur(uv, blur_amount, TEXTURE);
}