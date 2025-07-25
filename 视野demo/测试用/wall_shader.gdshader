shader_type canvas_item;
varying vec2 canvas_pos;


void vertex() {
	vec2 world_pos = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xy; // 世界坐标
	canvas_pos = (CANVAS_MATRIX * vec4(world_pos, 0.0, 1.0)).xy;
}

void fragment() {
	vec2 shadow_uv = SHADOW_VERTEX;
	COLOR = texture(TEXTURE, UV);
}


void light() {
	float light_y_world = LIGHT_POSITION.y;
	bool is_light_above_tile = light_y_world > canvas_pos.y; //  + 8.0 / 320.0 * 720.0
	float light_intensity = is_light_above_tile ? 1.0 : 0.0; // 当灯光在Tile上方时，设置光照强度为1，否则为0
	LIGHT = vec4(light_intensity * LIGHT_COLOR.rgb * COLOR.rgb * LIGHT_ENERGY, LIGHT_COLOR.a);
}
