shader_type spatial;

uniform vec3 outer_color : source_color;
uniform vec3 inner_color : source_color;

uniform float edge_blur_amount : hint_range(0.0, 1.0) = 0.05;

uniform float roughness : hint_range(0.0, 1.0);
uniform float metallic : hint_range(0.0, 1.0);

uniform float square_size : hint_range(0.0, 1.0) = 0.75;

float make_square(vec2 uv){
	
	float edge_blur = (1.0 - square_size) + edge_blur_amount;
	
	float top = smoothstep(1.0 - square_size, edge_blur, uv.y);
	float bottom = 1.0 - smoothstep(1.0 - edge_blur, square_size, uv.y);
	float left = smoothstep(1.0 - square_size, edge_blur, uv.x);
	float right = 1.0 - smoothstep(1.0 - edge_blur, square_size, uv.x);
	
	return top * bottom * left * right;
}

void vertex(){
	
}

void fragment() {
	
	float square = make_square(UV);
	vec3 inner = square * inner_color;
	vec3 outer = (1.0 - square) * outer_color;
	
	ALBEDO = inner + outer;
	
	ROUGHNESS = roughness;
	METALLIC = metallic;
	
}
