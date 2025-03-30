#version 150

#moj_import <light.glsl>
#moj_import <fog.glsl>
#moj_import <ortho_utils.glsl>
#moj_import <entity_utils.glsl>
#moj_import <../config.txt>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in vec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler0;
uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform float GameTime;
uniform int FogShape;
uniform mat3 IViewRotMat;
uniform float FogStart;
uniform float FogEnd;

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec2 texCoord1;
out vec2 texCoord2;
flat out vec4 tint;

#define potion_types 21
vec3[potion_types] testColor = vec3[potion_types] (
    vec3(194, 255, 102), //Night vision
    vec3(246, 246, 246), //Invisibility
    vec3(253, 255, 132), //Jump boost
    vec3(255, 153,   0), //Fire resistance
    vec3( 51, 235, 255), //Speed
    vec3(139, 175, 224), //Slowness
    vec3(141, 130, 230), //Turtle master I (Slowness IV + Resistance III)
    vec3(141, 133, 230), //Turtle master II (Slowness VI + Resistance IV)
    vec3(152, 218, 192), //Water breathing
    vec3(248,  36,  35), //Instant health
    vec3(169, 101, 106), //Instant damage
    vec3(135, 163,  99), //Poison
    vec3(205,  92, 171), //Regeneration
    vec3(255, 199,   0), //Strength
    vec3( 72,  77,  72), //Weakness
    vec3( 89, 193,   6), //Luck
    vec3(243, 207, 185), //Slow falling
    vec3(189, 201, 255), //Wind Charging
    vec3(120, 105,  90), //Weaving 
    vec3(153, 255, 163), //Oozing 
    vec3(140, 155, 140)  //Infestation 
);

void main() {
    texCoord0 = UV0; 
	texCoord1 = UV1; 
	texCoord2 = UV2;
    vec3 position = Position;
	
	vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color) * texelFetch(Sampler2, UV2 / 16, 0);
	
	float controlV = textureLod(Sampler0, UV0, 0).a;
	if (MODELGAPFIX == false && controlV != 0.0 && controlV != 1.0) {
		int alpha = int(controlV * 255 + 0.5);
		
		//switch (alpha) {
		//case 25: 
			int red = int(textureLod(Sampler0, UV0, 0).r * 255 + 0.5);
			switch (red) {
			case 1: if (Potion_Variants) {
					vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, vec4(1));
					ivec2 texSize = textureSize(Sampler0, 0);
					tint = Color;
					//if (floor(texture(Sampler0, UV0).rgb * 255) == vec3(1, 0, 0)) {
						vec3 potionColor = floor(Color.rgb * 255);
						vec2 offset = ivec2(16, 0);
						for (int i = 0; i < potion_types; i++) {
							if (potionColor == testColor[i]) {
								i += 2; 
								offset = vec2(i % 32, i / 32 % 32) * 16;
								break;
							}
						}
						texCoord0 += offset / texSize;
						tint.a = 2;
					//} 
				} break;
			}
		//}
	}
	
    vertexDistance = fog_distance(position, FogShape);
    gl_Position = ProjMat * ModelViewMat * vec4(position, 1.0);
}
