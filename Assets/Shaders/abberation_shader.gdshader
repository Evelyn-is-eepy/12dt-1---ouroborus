shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear, repeat_disable;
uniform float displacement_x : hint_range(0.0, 1.0);
uniform float displacement_y : hint_range(0.0, 1.0);

void fragment() {
	// Called for every pixel the material is visible on.
	float pixel_size = SCREEN_UV.x / 432.0;
	vec2 displacement = vec2(displacement_x, displacement_y) * pixel_size;
	COLOR.r = texture(screen_texture, SCREEN_UV + displacement).r;
	COLOR.g = texture(screen_texture, SCREEN_UV).g;
	COLOR.b = texture(screen_texture, SCREEN_UV - displacement).b;
}

