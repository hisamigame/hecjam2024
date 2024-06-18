shader_type canvas_item;

uniform sampler2D pal0 : hint_default_black;
uniform sampler2D pal1 : hint_default_black;
uniform sampler2D noise_tex:repeat_enable;

uniform float lerper: hint_range(0.0, 1.0);

uniform float maxtime = 0.5;
uniform float t0 = 0.0;
uniform float delta = 0.0;
uniform float speed = 1.0;

uniform vec2 amplitutde = vec2(1.0, 0.0);
uniform vec2 wavevector = vec2(10.0, 0.0);


vec3 c_lerp(vec4 c1, vec4 c2, float pos) {
	pos = clamp (pos, 0.0, 1.0);
	return vec3(c1.x*pos + c2.x*(1.0-pos),c1.y*pos + c2.y*(1.0-pos),c1.z*pos + c2.z*(1.0-pos));
}

void fragment() {
	
	vec3 tex_uv = vec3(UV, 0.0);
	vec3 color_input;
	float alpa_input;
	
	// Get the colors from the image at specified location
	
	vec2 pos = mod((UV - amplitutde * sin(speed*(delta-t0)/maxtime + vec2(UV.y, UV.x) * wavevector)) / TEXTURE_PIXEL_SIZE,
			1.0 / TEXTURE_PIXEL_SIZE) * TEXTURE_PIXEL_SIZE;
	//COLOR = texture(TEXTURE, pos);
	
	{
		vec4 _tex_read = textureLod(TEXTURE, pos, 0.0);
		color_input = _tex_read.rgb;
		alpa_input = _tex_read.a;
	}
	
	// get the greyscale value through the highest of r, g, and b
	
	float grey_value;
	{
		vec3 c = color_input;
		float max1 = max(c.r, c.g);
		float max2 = max(max1, c.b);
		grey_value = max2;
	}
	
	// Read the colormap and use the greyscale value to map in the new colors for each palette.
	float noise_value = texture(noise_tex, UV + vec2(0.0, (delta-t0)/2.0)).x;
	float alpha1;
	if((delta - t0) < maxtime/2.0){
		alpha1 = 2.0*(delta - t0)/maxtime;
	}
	else{
		alpha1 = 1.0 - (2.0*(delta - t0)/maxtime - 1.0);
	}
	vec4 colorP0 = textureLod(pal0, vec2(grey_value + noise_value, 0.0), 0.0);
	//colorP0.a = alpha1;
	vec4 colorP1 = textureLod(pal1, vec2(grey_value + noise_value, 0.0), 0.0);
	//colorP1.a = alpha1;
	// Blend between your two color maps and...   Profit.
	
	
	COLOR = vec4(c_lerp(colorP1, colorP0, lerper), alpha1);
	COLOR.a = alpha1;
}
