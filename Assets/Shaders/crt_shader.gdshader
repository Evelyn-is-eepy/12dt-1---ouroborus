shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, filter_nearest, repeat_disable;
uniform float warp_amount : hint_range(0.0, 0.5) = 0.05;
uniform float scanline_darkness : hint_range(0.0, 0.5) = 0.25;

void fragment() {
	vec2 screen_pixels = vec2(432, 224);
	// Called for every pixel the material is visible on
	// Distort uv
	vec2 uv = SCREEN_UV;
	vec2 delta = SCREEN_UV - vec2(0.5, 0.5);
	float warp_factor = dot(delta, delta) * warp_amount;
	uv += delta * warp_factor;
	// Add scanlines
	float scanline_darkening = cos(screen_pixels.y * 2.0 * PI * (uv.y));
	scanline_darkening *= scanline_darkness;
	scanline_darkening += scanline_darkness;
	COLOR = texture(screen_texture, uv, 0.0) - scanline_darkening;
	COLOR.a = 1.0;
}
