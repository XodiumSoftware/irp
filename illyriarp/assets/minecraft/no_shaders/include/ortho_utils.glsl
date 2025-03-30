#version 150

mat4 getOrthoMat(mat4 ProjMat, float Zoom) {
    vec4 distProbe = inverse(ProjMat) * vec4(0.0, 0.0, 1.0, 1.0);
    float far = length(distProbe.xyz / distProbe.w);
    
    float near = -1000.0; 
    float fixed_near = 0.05; 
    
    float left = -(0.5 / (ProjMat[0][0] / (2.0 * fixed_near))) / Zoom;
    float right = -left;
    float top = (0.5 / (ProjMat[1][1] / (2.0 * fixed_near))) / Zoom;
    float bottom = -top;

    return mat4(2.0 / (right - left),               0.0,                                0.0,                            0.0,
                0.0,                                2.0 / (top - bottom),               0.0,                            0.0,
                0.0,                                0.0,                                -2.0 / (far - near),            0.0,
                -(right + left) / (right - left),   -(top + bottom) / (top - bottom),   -(far + near) / (far - near),   1.0);
}

float getPlayerYaw(mat4 modelViewMat) {
    vec3 forward = normalize(vec3(modelViewMat[2][0], 0.0, modelViewMat[2][2]));
    return degrees(atan(forward.z, forward.x));
}

mat4 getIsometricViewMat(mat4 modelViewMat) {
    float playerYaw = getPlayerYaw(modelViewMat);

    float snappedYaw;
    float angle45 = 45.0;
    float angle225 = 225.0;

    if (abs(playerYaw - 45.0) < 180.0) {
        snappedYaw = 45.0;
    } else if (abs(playerYaw - 45.0) >= 180.0) {
        snappedYaw = 225.0;
    }

    float angleY = radians(snappedYaw);

    mat4 rotY = mat4(
        cos(angleY), 0.0, sin(angleY), 0.0,
        0.0, 1.0, 0.0, 0.0,
        -sin(angleY), 0.0, cos(angleY), 0.0,
        0.0, 0.0, 0.0, 1.0
    );

    float angleX = radians(-35.264);
    mat4 rotX = mat4(
        1.0, 0.0, 0.0, 0.0,
        0.0, cos(angleX), -sin(angleX), 0.0,
        0.0, sin(angleX), cos(angleX), 0.0,
        0.0, 0.0, 0.0, 1.0
    );

    mat4 isometricViewMat = rotX * rotY;
    isometricViewMat[3] = modelViewMat[3];
    return isometricViewMat;
}