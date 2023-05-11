shader_type spatial;

uniform float height_scale = 0.5;
uniform sampler2D noise;
uniform sampler2D normalmap;

varying vec2 tex_position;

float height(vec2 position, float time){
	vec2 offset = 0.015 * cos(position + time);
	return texture(noise, position - offset).r;
}

void vertex() {
	tex_position = VERTEX.xz;
	float vert_height = height(tex_position, TIME);
	VERTEX.y = vert_height * height_scale;
	
	NORMAL = normalize(vec3(vert_height - height(VERTEX.xz + vec2(0.01, 0.0), TIME), 0.1, vert_height - height(VERTEX.xz + vec2(0.0, 0.01), TIME)));
}

void fragment() {
	float fresnel = sqrt(1.0 - dot(NORMAL, VIEW));
    //NORMAL_MAP = texture(normalmap, tex_position).xyz;
    ALBEDO = vec3(0.05, 0.15, 0.25) - (0.1 * fresnel);
    METALLIC = 0.0;
    ROUGHNESS = 0.01 * (1.0 - fresnel);
    RIM = 0.1;
}


