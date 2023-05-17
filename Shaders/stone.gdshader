shader_type spatial;

uniform vec3 main_color : source_color;
uniform vec3 secondary_color : source_color;

uniform sampler2D voro;
uniform sampler2D voro_no;

uniform sampler2D main_normal;
uniform sampler2D second_normal;

uniform sampler2D roughness_noise;
uniform float roughness_edge : hint_range(0.0, 1.0)= 0.165;
uniform float specular : hint_range(0.0, 1.0)= 0.1;

uniform float main_noise_strength : hint_range(0.0, 1.0) = 0.4;
uniform float normal_strength : hint_range(0.0, 1.0) = 0.4;
uniform float tile_size : hint_range(0.1, 4.0) = 1.0;

vec2 tile(vec2 to_tile){
	return vec2(fract(to_tile.x * tile_size), fract(to_tile.y * tile_size));
}

vec3 create_main_albedo(vec2 uv){
	float mn_str = main_noise_strength - 0.5;
	
	float voronoi = texture(voro, tile(uv)).r;
	float voro_noise = texture(voro_no, tile(uv)).r;
	float main_noise = clamp((voronoi + voro_noise) - mn_str, 0.0, 1.0);
	vec3 alb = main_noise * main_color;
	vec3 edo = (1.0 - main_noise) * secondary_color;
	return alb + edo;
}

vec3 create_normal_map(vec2 uv){
	float norm_str = normal_strength - 0.5;
	
	vec3 normal1 = texture(main_normal, tile(uv)).rgb;
	vec3 normal2 = texture(second_normal, tile(uv)).rgb;
	
	vec3 normal_map = clamp((normal1 + normal2) - norm_str, 0.0, 1.0);
	
	return normal_map;
}

void fragment() {
	
	float rough_raw = texture(roughness_noise, tile(UV)).r;
	float roughness = step(roughness_edge, rough_raw);
	roughness = smoothstep(roughness_edge, roughness_edge + 0.3, rough_raw);
	
	ALBEDO = create_main_albedo(UV);
	ROUGHNESS = roughness;
	SPECULAR = specular;
	METALLIC = 0.0;
	NORMAL_MAP = create_normal_map(UV);
}
