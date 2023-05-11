shader_type spatial;

uniform vec3 outer_color : source_color;
uniform vec3 inner_color : source_color;

uniform float circle_size : hint_range(0.0, 1.0) = 0.3;
uniform float edge_blur : hint_range(0.0, 1.0) = 0.2;

uniform bool pulse = true;
uniform float pulse_speed : hint_range(0.1, 10.0) = 2.0;
uniform float pulse_amount : hint_range(0.1, 100.0) = 90.0;

uniform float roughness : hint_range(0.0, 1.0) = 1.0;
uniform float metallic : hint_range(0.0, 1.0) = 0.0;

float circle(vec2 uv, float time){
	float pulse_amount_mod = 100.1 - pulse_amount;
	float edge_blur_amount;
	
	if(pulse){
		edge_blur_amount = circle_size + edge_blur + (abs(cos(time * pulse_speed)) / pulse_amount_mod);
	}
	else{
		edge_blur_amount = circle_size + edge_blur;
	}
	
	float circ = distance(uv, vec2(0.5));
	return 1.0 - smoothstep(circle_size, edge_blur_amount, circ);
}

void fragment() {
	
	float stepped_circle = circle(UV, TIME);
	vec3 colored_circle = (1.0 - stepped_circle) * outer_color;
	
	ALBEDO = clamp(inner_color - (1.0 - stepped_circle), 0.0, 1.0) + colored_circle;
	
	ROUGHNESS = roughness;
	METALLIC = metallic;
}
