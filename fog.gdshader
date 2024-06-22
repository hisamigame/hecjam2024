shader_type canvas_item;

uniform sampler2D noise_tex: repeat_enable;
uniform float speed = 0.02;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
const float clamping = 0.6;
const float clamping0 = 0.2;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 scr = textureLod(screen_texture, SCREEN_UV, 0.0);
	vec3 clamped_noise = clamp(texture(noise_tex, UV + vec2(TIME*speed,0)).rgb,vec3(clamping0,clamping0,clamping0), vec3(clamping,clamping,clamping));
	//COLOR.rgb = mix(scr.rbg, clamped_noise, 0.5);
	COLOR.rgb = clamp(scr.rgb, vec3(0.0,0.0,0.0), clamped_noise);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
