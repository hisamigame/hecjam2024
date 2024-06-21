shader_type canvas_item;

// Mask texture. Must have the same size as the target texture.
// The effect will be applied on any opaque pixel of the mask.
// Transparent pixels in the mask texture are ignored.
uniform sampler2D mask : source_color, filter_nearest;

// Value by which to multiply the pixels covered by the mask, darkening
// the sprite. Lower means darker.
// When multiplying colors, COLOR * 1.0 results in the same color, and COLOR * 0.0 results in black color.
uniform float multiply_factor;
uniform float modulate_factor;

// Enables or disables the effect.
uniform bool can_apply;

void fragment() {
	vec4 mask_color = texture(mask, UV);
	
	if (can_apply && mask_color.a > 0.0)
	{
		COLOR.rgb = (COLOR * multiply_factor).rgb;
	}
	else
	{
		COLOR = texture(TEXTURE, UV);
	}
	if(COLOR.a>0.0){
		COLOR.a = modulate_factor;
	}
}
