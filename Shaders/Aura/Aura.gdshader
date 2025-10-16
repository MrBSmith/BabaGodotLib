shader_type canvas_item;

uniform sampler2D noise: repeat_enable;
uniform float intensity = 0.0;
uniform vec2 direction = vec2(1.0);
uniform float speed = 0.0;
uniform float threshold : hint_range(0.0, 1.0, 0.01);
uniform sampler2D color_ramp: filter_nearest;
uniform float opacity : hint_range(0.0, 5.0);

// Credits to DJBob Gaming YT :D
uniform int blur_radius : hint_range(1, 32) = 8;
uniform float blur_strength : hint_range(0.1, 10.0) = 1.0;

float gaussian_weight(float i, float sigma) {
    return exp(-0.5 * (i * i) / (sigma * sigma));
}

void calculate_kernel(out float kernel[32], int radius, float sigma) {
    float sum = 0.0;
    for (int i = 0; i <= radius; i++) {
        kernel[i] = gaussian_weight(float(i), sigma);
        sum += i == 0 ? kernel[i] : 2.0 * kernel[i];
    }
    for (int i = 0; i <= radius; i++) {
        kernel[i] /= sum;
    }
}

void fragment() {
	vec2 texture_size = vec2(textureSize(TEXTURE, 0));
	vec2 noise_size = vec2(textureSize(noise, 0));
	
	vec2 aspect_ratio = vec2(1.0) - (texture_size / abs(noise_size - texture_size));
	vec2 resolution = vec2(1.0) / texture_size;
	vec4 texture_color = texture(TEXTURE, UV);
	vec2 noise_uv = UV;
	
    float kernel[32];
    calculate_kernel(kernel, blur_radius, blur_strength);

    vec4 blured_texture_color = vec4(0.0);
    float total_weight = 0.0;

    for (int x = -blur_radius; x <= blur_radius; x++) {
        for (int y = -blur_radius; y <= blur_radius; y++) {
            float weight = kernel[abs(x)] * kernel[abs(y)];
            vec2 offset = vec2(float(x), float(y)) * resolution;
            blured_texture_color += texture(TEXTURE, UV + offset) * weight;
            total_weight += weight;
        }
    }

    blured_texture_color /= total_weight;

	vec4 noise_color = texture(noise, noise_uv + TIME * speed * direction);
	float noise_value = noise_color.r;
	vec4 result_color = texture(color_ramp, vec2(noise_value));
	float alpha = noise_value * blured_texture_color.a * opacity;
	if (alpha < threshold) {
		alpha = 0.0;
	}
	COLOR = vec4(result_color.rgb, alpha);
}