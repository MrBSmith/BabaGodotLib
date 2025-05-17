shader_type canvas_item;
//render_mode light_only;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest_mipmap;
uniform float strength: hint_range(0.0, 0.1, 0.001) = 0.08;
uniform vec2 center = vec2(0.5, 0.5);
uniform float radius: hint_range(0.0, 1.0, 0.001) = 0.25;

uniform float aberration: hint_range(0.0, 1.0, 0.001) = 0.425;
uniform float width: hint_range(-1.0, 1.0, 0.0001) = 0.04;
uniform float feather: hint_range(0.0, 1.0, 0.001) = 0.135;

void fragment() {
	float aspect_ratio = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	vec2 scaled_suv = (UV - vec2(0.0, 0.5)) / vec2(1.0, aspect_ratio) + vec2(0.0, 0.5);
	vec2 dist_center = UV - center;
	float mask = (1.0 - smoothstep(radius - feather, radius, length(dist_center))) * smoothstep(radius - width - feather, radius - width , length(dist_center));
	vec2 offset = normalize(dist_center) * strength * mask;
	vec2 biased_suv = UV - offset;

	vec2 abber_vec = offset * aberration * mask;

	vec2 final_suv = SCREEN_UV * (1.0 - mask) + biased_suv * mask;

	vec4 red = texture(screen_texture, final_suv + abber_vec);
	vec4 blue = texture(screen_texture, final_suv - abber_vec);
	vec4 ori = texture(screen_texture, final_suv);
	COLOR = vec4(red.r, ori.g, blue.b, 1.0);
}