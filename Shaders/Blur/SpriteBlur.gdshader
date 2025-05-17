shader_type canvas_item;

uniform int bleed_distance : hint_range(1, 100) = 5;
uniform float blur_amount : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform int nb_samples = 1;

vec4 getBlurredPixel(sampler2D text, vec2 uv, vec2 offset) {
	vec4 color = vec4(0.0);
	
	if (nb_samples < 1) {
		return texture(text, uv);
	}
	
	
	// Accumulate nearby pixel color
	for (int i = -nb_samples; i < nb_samples + 1; i++) {
		for (int j = -nb_samples; j < nb_samples + 1; j++) {
			color += texture(text, uv + vec2(float(i), float(j)) * (offset / float(nb_samples)));
		}
	}
	
	// Calculate the average color
	float total_samples = pow(float(1 + nb_samples * 2), 2);
	color /= vec4(float(total_samples));
	
	// Mix the result with the original color by blur_amount
	return mix(texture(text, uv), color, blur_amount);
}


void fragment() {
	vec2 bleeding_offset = TEXTURE_PIXEL_SIZE * float(bleed_distance);
	COLOR = getBlurredPixel(TEXTURE, UV, bleeding_offset);
}