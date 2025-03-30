#version 150

float chunk_translate(vec3 chunkOffset, float fogEnd, mat4 modelViewMat) {
    return pow(max(length((modelViewMat * vec4(chunkOffset.x + 8.0, 0.0, chunkOffset.z + 8.0, 1.0)).xyz) / fogEnd - 1.0, 0.0) * 5.0, 2.0);
}

mat3 rotationMatrix(vec3 axis, float angle) {
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    return mat3(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,
                oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,
                oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c);
}

vec3 chunk_vertex_fade(vec3 position, vec3 Normal, vec3 Position, vec3 ChunkOffset, mat4 ProjMat, mat4 ModelViewMat, float FogEnd) {
    vec4 normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);
    float vertexId = mod(gl_VertexID, 4.0);
    vec3 fractPosition = fract(Position), absNormal = abs(Normal);
    
    if (absNormal.x == 1.0) { fractPosition *= rotationMatrix(Normal.zxy, -1.570796); 
    } else if (absNormal.y == 1.0) { fractPosition *= rotationMatrix(Normal.yzx, 1.570796); 
    } else if (Normal.z == -1.0) { fractPosition *= rotationMatrix(Normal.yzx, -3.14159); }
    
    vec3 originOffset = vec3(
        (fractPosition.x > 0.001 && fractPosition.x < 0.999) ? 0.5 - fractPosition.x : 0.5,
        (fractPosition.y > 0.001 && fractPosition.y < 0.999) ? 0.5 - fractPosition.y : 0.5,
        0.0
    );

    if ((vertexId == 0.0 && originOffset.y == 0.5) || (vertexId == 3.0 && originOffset.y == 0.5)) originOffset.y *= -1.0;
    if ((vertexId == 2.0 && originOffset.x == 0.5) || (vertexId == 3.0 && originOffset.x == 0.5)) originOffset.x *= -1.0;

    if (absNormal.x == 1.0) { originOffset *= rotationMatrix(Normal.zxy, 1.570796);
    } else if (absNormal.y == 1.0) { originOffset *= rotationMatrix(Normal.yzx, -1.570796);
    } else if (Normal.z == -1.0) { originOffset *= rotationMatrix(Normal.yzx, 3.14159); }
    
    float fadeAmount = pow(max(0.0, length((ModelViewMat * vec4(Position + originOffset + ChunkOffset, 1.0)).xyz) - (FogEnd - 16.0)), 2.0);
    float scale = clamp(fadeAmount * 0.075 / 16.0, 0.0, 1.0);

    return position + scale * originOffset;
}

float combinedWave(float i, float waveStrength) {
    float base = sin(i) + sin(2.0 * i) + sin(3.0 * i) + 2.0 * sin(3.0 * i - 3.0);
    return (base * sin(i / 2.71) * waveStrength) / 2.0;
}

vec3 wave_render(vec3 position, float waveStrength, float GameTime) {
    float waveOffset = (position.x + position.y + position.z + GameTime * 4000) / 3.0;
    
    float xs = combinedWave(waveOffset, waveStrength) * 1.0;
    float ys = combinedWave(waveOffset - position.z, waveStrength) * 0.5;
    float zs = combinedWave(waveOffset + position.y, waveStrength) * 1.0;
    
    vec3 waveEffect = vec3(xs, ys, zs) / 32.0;
    waveEffect.y -= (waveStrength * 0.6) / 32.0;
    
    position += waveEffect;
    return position;
}

vec3 liquid_render(vec3 position, vec3 Position, float GameTime) {
    float fracY = fract(Position.y);
    float amplitude = (fracY == 0.0) ? 1.5 : 1.5 * fracY; 
    vec3 offset = vec3(
        sin(position.x + GameTime * 4000) * cos(GameTime * 300) * amplitude,
        cos(distance(Position.xz, vec2(8, 8)) * 10 + GameTime * 4000) * 0.8 * amplitude,
        cos(position.z + GameTime * 4000) * sin(GameTime * 300) * amplitude
    );
    position += offset / vec3(32.0, 16.0, 32.0);
    return position;
}

vec3 sway_render(vec3 position, vec3 Position, float GameTime, vec3 ChunkOffset) {
    float dotPos = dot(floor(Position), vec3(1.0));
    float lanternTime = (1.0 + fract(dotPos) / 2.0) * GameTime * 1200.0 + dotPos * 1234.0;

    vec3 newForward = normalize(vec3(
        sin(lanternTime) * 0.1 * Waving_Objects,
        sin(lanternTime * 1.61803398875) * 0.1 * Waving_Objects,
        -1.0 + sin(lanternTime * 3.14) * 0.1 * Waving_Objects
    ));
    
    vec3 relativePos = fract(Position);
    if (relativePos.y > 0.001) {
        relativePos -= vec3(0.5, 1.0, 0.5);
        vec3 tangent = normalize(cross(vec3(0, 1, 0), newForward));
        vec3 bitangent = cross(newForward, tangent);
        mat3 tbnMatrix = mat3(tangent, bitangent, newForward);
        relativePos = tbnMatrix * relativePos;
        position = floor(Position) + relativePos + vec3(0.5, 1.0, 0.5) + ChunkOffset;
    }
    return position;
}

vec3 bouncing_render(vec3 position, float GameTime) {
    position.y += 0.005 * sin(GameTime * 4000 * 2.0 * 3.14159);
    return position;
}

vec3 pulsing_render(vec3 position, vec3 Position, float GameTime) {
    vec3 blockPos = mod(Position, 1.0) - 0.5;
    position -= blockPos;
    blockPos *= 1.0 + max(0.0, sin(GameTime * 14800.0) - 0.8) * 0.25;
    position += blockPos;
    return position;
}

vec3 orbital_render(vec3 position, vec3 Position, float GameTime) {
    vec3 blockPos = mod(Position, 1.0) - 0.5;
    position -= blockPos;
    blockPos *= 1.0 + max(0.0, sin(GameTime * 20000.0) - 0.8) * 0.25;

    float thetaY = GameTime * 1000.0;
    float sinThetaX = sin(thetaY * 4.0);
    float cosThetaX = cos(thetaY * 4.0);
    float cosThetaZ = cos(thetaY * 4.0);

    mat3 rot = mat3(
        vec3(1.0, 0.0, 0.0), 
        vec3(0.0, cosThetaX, -sinThetaX), 
        vec3(0.0, sinThetaX, cosThetaX)) *
        mat3(vec3(cos(thetaY), 0.0, sin(thetaY)), vec3(0.0, 1.0, 0.0), vec3(-sin(thetaY), 0.0, cos(thetaY))) *
        mat3(vec3(cosThetaZ, -sinThetaX, 0.0), vec3(sinThetaX, cosThetaX, 0.0), vec3(0.0, 0.0, 1.0));

    blockPos = rot * blockPos;
    position += blockPos;
    position.y += 0.07;
    
    return position;
}

vec3 rotational_render(vec3 position, vec3 Position, float GameTime) {
    vec3 blockPos = mod(Position, 1.0) - 0.5;
    position -= blockPos;
    float thetaY = GameTime * 4000.0;  
    mat3 rot = mat3(
        vec3(cos(thetaY), 0.0, sin(thetaY)),
        vec3(0.0, 1.0, 0.0),
        vec3(-sin(thetaY), 0.0, cos(thetaY))
    );
    blockPos = rot * blockPos;
    position += blockPos;
    return position;
}

vec3 slope_side(vec3 Position, vec3 ChunkOffset, vec4 Color, vec3 Normal, sampler2D Sampler0, inout vec2 texCoord0) {
    vec3 position = Position;
    if (Normal.y > 0.0) {
        float color = Color.r;
        float slope_offset = clamp((1.0 - color), 0.0, ceil(Position.y) - Position.y);
        float elevation = 1.0 - slope_offset - fract(Position.y);
        texCoord0.y -= elevation * 16.0 / textureSize(Sampler0, 0).y;
        position += vec3(0.0, 1.0, 0.0) * slope_offset;
    } else { position.y = floor(position.y); }
    return position + ChunkOffset;
}

vec3 slope_top(vec3 Position, vec3 ChunkOffset, vec4 Color, vec3 Normal) {
    vec3 position = Position;
    if (Normal.y > 0.0) {
        float color = Color.r;
        float slope_offset = clamp((1.0 - color), 0.0, ceil(Position.y) - Position.y);
        position += vec3(0.0, 1.0, 0.0) * slope_offset;
    } else { position.y = floor(position.y); }
    return position + ChunkOffset;
}

vec3 slope_bottom(vec3 Position, vec3 ChunkOffset) {
    vec3 position = Position;
    position.y = floor(position.y);
    return position + ChunkOffset;
}

vec3 grass_displacement(vec3 position, mat4 ModelViewMat) {
    vec3 offset = position - vec3(ModelViewMat[3].x, position.y, ModelViewMat[3].z);
    float horizDist = length(offset.xz);
    float vertDist = abs(position.y - ModelViewMat[3].y);
    if (horizDist < 1.0 && vertDist < 1.5) {
        float smoothFactor = smoothstep(0.8, 0.3, horizDist);
        vec3 camDir = normalize(vec3(ModelViewMat[2].x, 0.0, -ModelViewMat[2].z));
        position.y = max(position.y - smoothFactor * 2.5, -0.9);
        position += camDir * smoothFactor * 0.8;
    }
    return position;
}