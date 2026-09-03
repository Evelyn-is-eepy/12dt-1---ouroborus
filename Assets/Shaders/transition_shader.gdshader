shader_type canvas_item;

uniform sampler2D transition_effect;
uniform float progress: hint_range(0.0, 1.0) = 0.0;
uniform bool invert = false;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float transition_value = texture(transition_effect,UV).r;
	COLOR.a = float(transition_value <= progress) * float(!invert) + float(transition_value > progress) * float(invert);
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
