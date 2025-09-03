shader_type canvas_item;

uniform float tolerance : hint_range(0.0, 1.0) = 0.1;
uniform sampler2D picker_ramp : filter_nearest;
uniform sampler2D color_ramp : filter_nearest;
uniform bool disabled = false;

vec4 map_ramp_color(vec4 color) {
	float ramp_size = float(textureSize(picker_ramp, 0).x);
	float uv_offset = 1.0 / float(ramp_size);
	float result_offset = 0.0;

	for (float i = 0.0; i < ramp_size; i++) {
		result_offset = uv_offset * (i + 0.5);
		vec4 picker_color = texture(picker_ramp, vec2(result_offset, 0.0));
		if (distance(picker_color, color) < tolerance) {
			return vec4(texture(color_ramp, vec2(result_offset, 0.0)).rgb, color.a);
		}
	}
	return color;
}

void fragment() {
	if (disabled) {
		COLOR = texture(TEXTURE, UV);
	} else {
		COLOR = map_ramp_color(texture(TEXTURE, UV));
	}
}