void main() {

	vec2 coord = vec2(
					  (gl_FragCoord.x)/u_point_size/u_scale + u_offset.x,
					  (gl_FragCoord.y)/u_point_size/u_scale - u_offset.y);
	if (coord.x < 0.0) {
		coord.x = - coord.x;
	}
	if (coord.y < 0.0) {
		coord.y = - coord.y;
	}
	
	// Wave
	vec2 wave_pos = coord/25.0 + u_time;
	float x = wave_pos.x;
	float y = wave_pos.y;
	vec2 wave_delta = vec2(sin(x/4.0)*sin(y), sin(y));
	float bright = (2.0+wave_delta.x+wave_delta.y)/2.0;
	
	// Texture
	vec2 texture_origin = 4.0 * coord / u_fixed_size.xy;
	texture_origin = texture_origin + (wave_delta * 30.0) / u_fixed_size.xy;
	vec2 texture_pos = mod(texture_origin, 1.0);
	vec4 texture_color = texture2D(u_texture, texture_pos);
	
	vec4 water_color = vec4(0.25, 0.5, 1.0, 1.0);
	
	vec4 final_color = 0.25*texture_color + 0.8 * water_color + 0.1 * vec4(1.0,1.0,1.0,1.0) * bright;
	gl_FragColor = vec4(final_color.r, final_color.g, final_color.b, 1.0);

}