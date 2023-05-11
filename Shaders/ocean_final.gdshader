shader_type spatial;

uniform sampler2D depth_buffer : hint_depth_texture, repeat_disable, filter_nearest;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D texture_normal;
uniform sampler2D texture_normal2;
uniform sampler2D wave_disp;
uniform vec2 wave_direction = vec2(1.5, 0.0);
uniform vec2 wave_direction2 = vec2(0.0, 1.0);
uniform float time_scale : hint_range(0.0, 0.2, 0.005) = 0.02;
uniform float disp_time_scale : hint_range(0.0, 0.1, 0.0025) = 0.008;
uniform float normal_scale = 20.0;
uniform float noise_scale = 500.0;
uniform float height_scale = 0.002;

varying float height;
varying vec3 world_pos;

uniform vec4 deep_col : source_color;
uniform vec4 shallow_col : source_color;
uniform float beers_law = 2.0;
uniform float depth_offset = -0.75;

uniform float edge_scale = 0.1;
uniform float near = 0.1;
uniform float far = 1000.0;
uniform vec3 edge_color : source_color;

uniform vec3 albedo : source_color;
uniform vec3 fresnel_col : source_color;
uniform float roughness : hint_range(0.0, 1.0) = 0.0;
uniform float metallic : hint_range(0.0, 1.0) = 0.02;

float fresnel(float amount, vec3 normal, vec3 view){
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0)), amount);
}

float edge(float depth){
	depth = 2.0 * depth - 1.0;
	return near * far / (far + depth * (near - far));
}

void vertex(){
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	height = texture(wave_disp, world_pos.xz / noise_scale + TIME * disp_time_scale).r;
	VERTEX.y += height * height_scale;
}

void fragment() {
	float depth_texture = texture(depth_buffer, SCREEN_UV).r * 2.0 - 1.0;
	float depth = PROJECTION_MATRIX[3][2] / (depth_texture + PROJECTION_MATRIX[2][2]);
	float depth_blend = exp((depth + VERTEX.z + depth_offset) * -beers_law);
	depth_blend = clamp(1.0 - depth_blend, 0.0, 1.0);
	float depth_blend_power = clamp(pow(depth_blend, 2.5), 0.0, 1.0);
	
	vec3 screen_color = textureLod(screen_texture, SCREEN_UV, depth_blend_power * 2.5).rgb;
	vec3 depth_color = mix(shallow_col.rgb, deep_col.rgb, depth_blend_power);
	vec3 db_color = mix(screen_color * depth_color, depth_color * 0.25, depth_blend_power * 0.5);
	
	float z_depth = edge(texture(depth_buffer, SCREEN_UV).x);
	float z_pos = edge(FRAGCOORD.z);
	float z_diff = z_depth - z_pos;
	
	vec2 time = TIME * wave_direction * time_scale;
	vec2 time2 = TIME * wave_direction2 * time_scale;
	
	vec3 normal_blend = mix(texture(texture_normal, world_pos.xz / normal_scale + time).rgb, texture(texture_normal2, world_pos.xz / normal_scale + time2).rgb, 0.5);
	
	float fresnel_val = fresnel(5.0, NORMAL, VIEW);
	vec3 albedo_blend = mix(albedo, fresnel_col, fresnel_val);
	
	vec3 depth_color_adj = mix(edge_color, db_color, step(edge_scale, z_diff));
	
	ALBEDO = clamp(albedo_blend + depth_color_adj, vec3(0.0), vec3(1.0));
	ROUGHNESS = roughness;
	METALLIC = metallic;
	NORMAL_MAP = normal_blend;
}
