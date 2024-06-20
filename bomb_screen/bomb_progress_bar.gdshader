shader_type canvas_item;

uniform sampler2D noise_tex: repeat_enable;

uniform vec4 color : source_color;

// Overlay blending mode from: https://godotshaders.com/snippet/blending-modes/
vec4 overlay(vec4 base, vec4 blend) {
	vec4 limit = step(0.5, base);
	
	return mix(2.0 * base * blend, 1.0 - 2.0 * (1.0 - base) * (1.0 - blend), limit);
}

void fragment() {
	// Read the colormap and use the greyscale value
	float noise_value = clamp(texture(noise_tex, UV - vec2(TIME/2.0, 0.0)).x, 0.0, 1.0);
	
	COLOR =  vec4(overlay(color, vec4(noise_value)).rgb, COLOR.w);
}