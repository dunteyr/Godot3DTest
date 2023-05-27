shader_type spatial;

uniform vec3 main_color : source_color;
uniform vec3 secondary_color : source_color;

uniform float tile_size = 1.0;

uniform sampler2D noise;
uniform float noise_height_scale = 0.5;

uniform sampler2D normal_map;

vec2 tile(vec2 to_tile){
	return vec2(fract(to_tile.x * tile_size), fract(to_tile.y * tile_size));
}

void fragment() {	
	vec2 scaled_uv = vec2(UV.x, UV.y * noise_height_scale);
	
	vec3 normal = texture(normal_map, tile(scaled_uv)).rgb;
	vec3 main_noise = texture(noise, tile(scaled_uv)).rgb;
	vec3 alb = main_noise * main_color;
	vec3 edo = (1.0 - main_noise) * secondary_color;
	
	ALBEDO = alb + edo;
	ROUGHNESS = 1.0;
	NORMAL_MAP = normal;
}
