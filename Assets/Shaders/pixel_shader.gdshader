shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	// Called for every pixel the material is visible on.
	
	vec2 screen_pixels = vec2(432, 224);
	vec2 uv = SCREEN_UV;
	uv.x = floor(SCREEN_UV.x * screen_pixels.x) / screen_pixels.x;
	uv.y = floor(SCREEN_UV.y * screen_pixels.y) / screen_pixels.y;
	COLOR = texture(screen_texture, uv, 0.0);
}