shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0);
uniform vec4 texture_tint : source_color = vec4(vec3(1.0), 0.0);
uniform vec4 transparant_color : source_color = vec4(0.0);
uniform float opacity : hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float width : hint_range(0, 10) = 1.0;
uniform int pattern : hint_range(0, 2) = 0; // diamond, circle, square
uniform bool inside = false;

bool hasContraryNeighbour(vec2 uv, vec2 texture_pixel_size, sampler2D texture) {
	for (float i = -ceil(width); i <= ceil(width); i++) {
		float x = abs(i) > width ? width * sign(i) : i;
		float offset;

		if (pattern == 0) {
			offset = width - abs(x);
		} else if (pattern == 1) {
			offset = floor(sqrt(pow(width + 0.5, 2) - x * x));
		} else if (pattern == 2) {
			offset = width;
		}

		for (float j = -ceil(offset); j <= ceil(offset); j++) {
			float y = abs(j) > offset ? offset * sign(j) : j;
			vec2 xy = uv + texture_pixel_size * vec2(x, y);

			if ((xy != clamp(xy, vec2(0.0), vec2(1.0)) || texture(texture, xy).a <= 0.0) == inside) {
				return true;
			}
		}
	}

	return false;
}

void fragment() {
	vec2 uv = UV;
	vec4 texture_color = texture(TEXTURE, uv);
	if (texture_tint.a > 0.0) {
		texture_color *= texture_tint;
	}

	vec4 result_color = vec4(1.0);
	if ((texture_color.a > 0.0) == inside && hasContraryNeighbour(uv, TEXTURE_PIXEL_SIZE, TEXTURE)) {
		result_color = outline_color;
	} else {
		result_color = texture_color;
	}
	float alpha = min(opacity, result_color.a);
	COLOR = vec4(result_color.rgb, alpha);
}