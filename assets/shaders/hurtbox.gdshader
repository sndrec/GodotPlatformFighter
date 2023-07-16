shader_type spatial;
render_mode unshaded, blend_add, depth_test_disabled;

instance uniform vec3 bubbleColor = vec3(0.1, 0.1, 0.0);

void fragment() {
	if (bubbleColor != vec3(0.0, 0.0, 0.0)){
		ALBEDO = bubbleColor;
	}
	else{
		ALBEDO = vec3(0.1, 0.1, 0.0);
	}
}
