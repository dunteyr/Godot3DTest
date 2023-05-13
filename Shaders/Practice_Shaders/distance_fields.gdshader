shader_type spatial;

uniform float val : hint_range(0.01, 1.0);

void fragment(){
	vec2 uva = UV * 2. - 1.;
	
	//float d = length(abs(uva) - .3);
	//float d = length(min(abs(uva) - .3, 0.));
	float d = length(max(abs(uva) - .3, 0.));
	
	vec3 final_color = vec3(fract(d * 10.0));
	//final_color = vec3( step(val,d) );
	//final_color = vec3( step(val, d) * step(d, val + .1));
	//final_color = vec3(step(val, d) * step(d, val + .1) + step(val + .15, d) * step(d, val + .2));
	//final_color = vec3( smoothstep(val, val + .1, d) * smoothstep(val + .3, val + .2, d));
	ALBEDO = final_color;
	
}
