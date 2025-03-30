#version 150

float combinedWave(float i, float waveStrength) {
    float base = sin(i) + sin(2.0 * i) + sin(3.0 * i) + 2.0 * sin(3.0 * i - 3.0);
    return (base * sin(i / 2.71) * waveStrength) / 2.0;
}

vec3 wave_render(vec3 position, float waveStrength, float GameTime) {
    float waveOffset = (position.x + position.y + position.z + GameTime) / 3.0;
    
    float xs = combinedWave(waveOffset, waveStrength) * -1.0;
    float ys = combinedWave(waveOffset - position.z, waveStrength) * 0.5;
    float zs = combinedWave(waveOffset + position.y, waveStrength) * -1.0;
    
    vec3 waveEffect = vec3(xs, ys, zs) / 32.0;
    waveEffect.y -= (waveStrength * 0.6) / 32.0;
    
    position += waveEffect;
    return position;
}

vec3 liquid_render(vec3 position, float waveStrength, float GameTime, float waveHeight) {
    float waveOffset = (position.x + position.z + GameTime) / 2.0;
    float ys = combinedWave(waveOffset, waveStrength) * waveHeight;
    position.y += ys / 32.0;
    return position;
}