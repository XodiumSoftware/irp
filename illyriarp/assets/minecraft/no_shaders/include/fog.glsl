#version 150

#moj_import <../config.txt>

float linear_fog_fade(float vertexDistance, float fogStart, float fogEnd) {
    fogStart *= Fog_Distance;
	
    if (vertexDistance <= fogStart) { return 1.0; } 
	else if (vertexDistance >= fogEnd) { return 0.0; }

    return pow(smoothstep(fogEnd, fogStart, vertexDistance), max(0.0, 1.0));
}

vec4 linear_fog(vec4 inColor, float vertexDistance, float fogStart, float fogEnd, vec4 fogColor) {
    return vec4(mix(inColor.rgb, fogColor.rgb, (1.0 - linear_fog_fade(vertexDistance, fogStart, fogEnd)) * fogColor.a), inColor.a);
}

float fog_distance(vec3 pos, int shape) {
    if (shape == 0) { return length(pos); } 
	else  {
        float distXZ = length((vec4(pos.x, 0.0, pos.z, 1.0)).xyz);
        float distY = length((vec4(0.0, pos.y, 0.0, 1.0)).xyz);
        return max(distXZ, distY);
    }
}
