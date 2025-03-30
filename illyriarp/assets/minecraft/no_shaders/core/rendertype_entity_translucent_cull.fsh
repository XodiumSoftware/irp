#version 150

#moj_import <fog.glsl>
#moj_import <../config.txt>

uniform sampler2D Sampler0;

uniform vec4 FogColor;
uniform float FogStart;
uniform float FogEnd;

in float vertexDistance;
in vec4 vertexColor;
in vec4 lightColor;
in vec2 texCoord0;
flat in vec4 tint;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0);
    if (color.a < 0.1) discard; 
	
	if (color.a != 1) { 
		int alpha = int(color.a * 255.0);
    
		switch (alpha) {
		case 252: if (tint.a == 2 && Potion_Variants && MODELGAPFIX == false && OPTIFINE == false)  color *= vec4(tint.rgb, 1); break;
		case 251: if (Potion_Variants && MODELGAPFIX == false && OPTIFINE == false) discard; break;
		case 250: if (Emissives) color = mix(color, vec4(color.rgb, 1.0), color.a); break;
		case 239: color *= vertexColor; color.a = 1; break;
		default: color *= vertexColor;
		}
	} else { color *= vertexColor; }
	
	switch (Colorblindness) {
	case 1: color.rgb = mat3(		
		0.170556992, 0.170556991,-0.004517144,
		0.829443014, 0.829443008, 0.004517144,
		0          , 0          , 1          ) * color.rgb; break;
	case 2: color.rgb = mat3(	
		0.33066007 , 0.33066007 ,-0.02785538 ,
		0.66933993 , 0.66933993 , 0.02785538 ,
		0          , 0          , 1          ) * color.rgb; break;
	case 3: color.rgb = mat3(	
		1          , 0          , 0          ,
		0.1273989  , 0.8739093  , 0.8739093  ,
	   -0.1273989  , 0.1260907  , 0.1260907  ) * color.rgb; break;
	case 4: color.rgb = color.rgb * mat3(	
		0.2126     , 0.7152     , 0.0722     ,
		0.2126     , 0.7152     , 0.0722     ,
		0.2126     , 0.7152     , 0.0722     ); break;
	}
	
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}
