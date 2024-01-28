shader_type spatial;

uniform sampler2D grass_albedo;
uniform sampler2D grass_normal;
uniform sampler2D grass_roughness;

uniform sampler2D dirt_albedo;
uniform sampler2D dirt_normal;
uniform sampler2D dirt_roughness;

uniform sampler2D stone_albedo;
uniform sampler2D stone_normal;
uniform sampler2D stone_roughness;

uniform float grass_uv_scale;
uniform float dirt_uv_scale;
uniform float stone_uv_scale;

uniform float grass_thresh : hint_range(0.0, 1.0, 0.01);
uniform float grass_smooth : hint_range(0.0, 1.0, 0.01);

uniform float dirt_thresh : hint_range(0.0, 1.0, 0.01);
uniform float dirt_smooth : hint_range(0.0, 1.0, 0.01);

struct NormalInfo{
	vec3 normal;
	vec3 binormal;
	vec3 tangent;
};

vec3 get_applied_normals(NormalInfo normal, vec3 normal_map){
	
	//convert to -1 to 1
	normal_map *= vec3(2.0);
	normal_map -= vec3(1.0);
	
	//calculate z normal because godot doesn't store it for some reason
	normal_map.z = sqrt(1.0 - normal_map.x * normal_map.x - normal_map.y * normal_map.y);
	
	vec3 applied_normal = normal_map.x * normal.tangent + normal_map.y * normal.binormal + normal_map.z * normal.normal;
	
	return applied_normal;
}

float steep_mask(mat4 inv_view_mat, vec3 normal, float thresh, float smoothness){
	
	vec3 up = vec3(0.0, 1.0, 0.0);
	up = up * mat3(inv_view_mat);
	float steep_mask = dot(up, normal);
	steep_mask = smoothstep(thresh, thresh + smoothness, steep_mask);
	
	return steep_mask;
}

vec3 mask_blend(sampler2D texture1, vec2 uv1, sampler2D texture2, vec2 uv2, float steep_mask) {
	
	vec3 whiteTex = texture(texture1, uv1).rgb;
	vec3 blackTex = texture(texture2, uv2).rgb;
	
	whiteTex *= steep_mask;
	blackTex *= (1.0 - steep_mask);
	
	
	return whiteTex + blackTex;
}

void fragment() {
	
	NormalInfo normal_info;
	normal_info.normal = NORMAL;
	normal_info.binormal = BINORMAL;
	normal_info.tangent = TANGENT;
	
	vec2 grass_uv = UV * grass_uv_scale;
	vec2 dirt_uv = UV * dirt_uv_scale;
	vec2 stone_uv = UV * stone_uv_scale;
	
	vec3 dirt_app_norm = get_applied_normals(normal_info, texture(stone_normal, stone_uv).rgb);
	vec3 grass_app_norm = get_applied_normals(normal_info, texture(grass_normal, grass_uv).rgb);
	
	float dirt_mask = steep_mask(INV_VIEW_MATRIX, NORMAL, grass_thresh, grass_smooth);
	float grass_mask = steep_mask(INV_VIEW_MATRIX, NORMAL, dirt_thresh, dirt_smooth);
	
	vec3 dirtStoneA = mask_blend(dirt_albedo, dirt_uv, stone_albedo, stone_uv, dirt_mask);
	vec3 dirtStoneN = mask_blend(dirt_normal, dirt_uv, stone_normal, stone_uv, dirt_mask);
	vec3 dirtStoneR = mask_blend(dirt_roughness, dirt_uv, stone_roughness, stone_uv, dirt_mask);
	
	vec3 grassDirtA = mask_blend(grass_albedo, grass_uv, dirt_albedo, dirt_uv, grass_mask);
	vec3 grassDirtN = mask_blend(grass_normal, grass_uv, dirt_normal, dirt_uv, grass_mask);
	vec3 grassDirtR = mask_blend(grass_roughness, grass_uv, dirt_roughness, dirt_uv, grass_mask);
	
	grassDirtA *= dirt_mask;
	grassDirtN *= dirt_mask;
	grassDirtR *= dirt_mask;
	
	vec3 finalAlbedo = grassDirtA + (dirtStoneA * (1.0 - dirt_mask));
	vec3 finalNormal = grassDirtN + (dirtStoneN * (1.0 - dirt_mask));
	vec3 finalRoughness = grassDirtR + (dirtStoneR * (1.0 - dirt_mask));
	
	ALBEDO = finalAlbedo;
	NORMAL_MAP = finalNormal;
	ROUGHNESS = finalRoughness.g;
}

