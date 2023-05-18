shader_type spatial;

uniform float tile_size : hint_range(0.1, 10.0) = 1.0;
uniform vec3 main_color : source_color;
uniform vec3 secondary_color : source_color;

uniform sampler2D main_noise;
uniform sampler2D secondary_noise;

//make this the same as the main_noise
uniform sampler2D main_normal;

vec2 tile(vec2 to_tile){
	return vec2(fract(to_tile.x * tile_size), fract(to_tile.y * tile_size));
}

void fragment() {
	float grass_noise = texture(main_noise, tile(UV)).r;
	vec3 alb = grass_noise * main_color;
	vec3 edo = (1.0 - grass_noise) * secondary_color;
	vec3 albedo = alb + edo;
	
	ALBEDO = albedo;
	ROUGHNESS = 1.0;
	SPECULAR = 0.2;
	NORMAL_MAP = texture(main_normal, tile(UV)).rgb;
}
