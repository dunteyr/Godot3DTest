shader_type spatial;

uniform sampler2D grass_albedo;
uniform sampler2D grass_normal;
uniform sampler2D grass_roughness;

uniform sampler2D stone_albedo;
uniform sampler2D stone_normal;
uniform sampler2D stone_roughness;

uniform float grass_uv_scale;
uniform float dirt_uv_scale;
uniform float stone_uv_scale;

uniform float thresh : hint_range(0.0, 1.0, 0.01);
uniform float smoothness : hint_range(0.0, 0.3, 0.001);

void fragment() {
	
	vec2 grass_uv = UV * grass_uv_scale;
	vec2 dirt_uv = UV * dirt_uv_scale;
	vec2 stone_uv = UV * stone_uv_scale;
	
	vec3 grass_col = texture(grass_albedo, grass_uv).rgb;
	vec3 stone_col = texture(stone_albedo, stone_uv).rgb;
	
	vec3 grass_norm = texture(grass_normal, grass_uv).rgb;
	vec3 stone_norm = texture(stone_normal, stone_uv).rgb;
	
	vec3 grass_rough = texture(grass_roughness, grass_uv).rgb;
	vec3 stone_rough = texture(stone_roughness, stone_uv).rgb;	
	
	vec3 normalized = stone_norm * 2.0 - 1.0;
	normalized.z = sqrt(1.0 - normalized.x * normalized.x - normalized.y * normalized.y);
	vec3 stone_applied_norm = normalized.x * TANGENT + normalized.y * BINORMAL + normalized.z * NORMAL;
	
	vec3 view_up = vec3(0.0, 1.0, 0.0) * mat3(INV_VIEW_MATRIX);	
	float dot_prod_det = dot(view_up, stone_applied_norm);
	float dot_prod = dot(view_up, NORMAL);
	float steep_mask_det = smoothstep(thresh, thresh + smoothness, dot_prod_det);
	float steep_mask = smoothstep(thresh, thresh + smoothness, dot_prod);
	float combined_mask = steep_mask * steep_mask_det;
	float mask_mask = smoothstep(thresh + smoothness, thresh + smoothness + (smoothness + 0.01), dot_prod);
	combined_mask *= (1.0 - mask_mask);
	
	ALBEDO = mix(stone_col, grass_col, combined_mask + mask_mask);
	//ALBEDO = vec3(bleh);
	NORMAL_MAP = mix(stone_norm, grass_norm, combined_mask + mask_mask);
	ROUGHNESS = mix(stone_rough, grass_rough, combined_mask + mask_mask).g;
}
