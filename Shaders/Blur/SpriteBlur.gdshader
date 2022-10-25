shader_type canvas_item;

uniform float SAMPLES = 11.0;
const float WIDTH = 0.04734573810584494679397346954847;

uniform vec2 blur_scale = vec2(1, 0);

float gaussian(float x) {
    float x_squared = x*x;

    return WIDTH * exp((x_squared / (2.0 * SAMPLES)) * -1.0);
}

void fragment() {
	vec2 scale = TEXTURE_PIXEL_SIZE * blur_scale;
	
	float weight = 0.0;
	float total_weight = 0.0;
	vec4 color = vec4(0.0);
	
	for(int i=-int(SAMPLES)/2; i < int(SAMPLES)/2; ++i) {
		weight = gaussian(float(i));
		color.rgb += texture(SCREEN_TEXTURE, SCREEN_UV + scale * vec2(float(i))).rgb * weight;
		total_weight += weight;
	}
	
	COLOR.rgb = color.rgb / total_weight;
}