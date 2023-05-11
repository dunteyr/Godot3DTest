shader_type spatial;

uniform float height_scale = 0.5;
uniform sampler2D noise;
uniform sampler2D normalmap;
uniform sampler2D depth_texture : hint_depth_texture;

varying vec2 tex_position;

float height(vec2 position, float time){
	vec2 offset = 0.015 * cos(position + time);
	return texture(noise, position - offset).r;
}

void vertex(){
	tex_position = VERTEX.xz;
	float vert_height = height(tex_position, TIME);
	VERTEX.y = vert_height * height_scale;
	
	vec3 disp_normals = normalize(vec3(vert_height - height(VERTEX.xz + vec2(0.01, 0.0), TIME), 0.1, vert_height - height(VERTEX.xz + vec2(0.0, 0.01), TIME)));
	
	NORMAL = disp_normals;
}

void fragment() {
	float depth = texture(depth_texture, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;
	
	ALBEDO = vec3(0.1, 0.3, 0.5) * texture(depth_texture, SCREEN_UV).r;
	ROUGHNESS = 0.0;
	METALLIC = 0.0;
	
	
}
