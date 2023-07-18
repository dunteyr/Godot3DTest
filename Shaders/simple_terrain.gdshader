shader_type spatial;

uniform sampler2D grass_albedo;
uniform sampler2D grass_normal;
uniform sampler2D grass_roughness;

uniform sampler2D stone_albedo;
uniform sampler2D stone_normal;
uniform sampler2D stone_roughness;

uniform float grass_uv_scale;
uniform float stone_uv_scale;

uniform float steep_thresh : hint_range(0.0, 1.0, 0.01);
uniform float steep_smooth : hint_range(0.0, 1.0, 0.01);

float steep_mask(mat4 inv_view_mat, vec3 normal){
	
	vec3 up = vec3(0.0, 1.0, 0.0);
	up = up * mat3(inv_view_mat);
	float steep_mask = dot(up, normal);
	steep_mask = smoothstep(steep_thresh, steep_thresh + steep_smooth, steep_mask);
	
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
	
	vec2 grass_uv = UV * grass_uv_scale;
	vec2 stone_uv = UV * stone_uv_scale;
	
	float steep_mask = steep_mask(INV_VIEW_MATRIX, NORMAL);
	
	vec3 albedo = mask_blend(grass_albedo, grass_uv, stone_albedo, stone_uv, steep_mask);
	vec3 normal = mask_blend(grass_normal, grass_uv, stone_normal, stone_uv, steep_mask);
	vec3 roughness = mask_blend(grass_roughness, grass_uv, stone_roughness, stone_uv, steep_mask);
	
	ALBEDO = albedo;
	NORMAL_MAP = normal;
	ROUGHNESS = roughness.g;
}


