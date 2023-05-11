shader_type spatial;

uniform sampler2D noise;
uniform sampler2D normalMap;

varying vec2 tex_position;

const float height_scale = 1.0;

void fragment() {
	NORMAL_MAP = texture(normalMap, tex_position).xyz;
}

void vertex(){
	//VERTEX.y +=  (cos(VERTEX.x * 5.0) * 5.0) * (sin(VERTEX.z * 5.0)* 5.0);
	tex_position = vec2(VERTEX.x, VERTEX.z) / 2.0 + 0.5;
	float height = texture(noise, tex_position).r;
	
	VERTEX.y += height * height_scale;
	
	
}
