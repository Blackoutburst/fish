struct VSInput {
    float2 xzPos;
    float  phase;
};

struct UniformBuffer {
    float4x4 model;
    float4x4 view;
    float4x4 projection;
    float3 lightDir;
    float  time;
};
[[vk::binding(0, 0)]] ConstantBuffer<UniformBuffer> ubo;

struct VSOutput {
    float4 pos      : SV_Position;
    float3 worldPos : TEXCOORD0;
};

static const float WATER_LEVEL = 6.0;
static const float WATER_AMP   = 0.2;

[shader("vertex")]
VSOutput vertMain(VSInput input) {
    VSOutput output;

    float x  = input.xzPos.x;
    float z  = input.xzPos.y;
    float ph = input.phase;
    float t  = ubo.time;

    float h = sin(x * 0.15 + t * 1.5 + ph)       * (WATER_AMP * 0.7)
            + sin(z * 0.12 + t * 1.2 + ph * 0.7) * (WATER_AMP * 0.5);

    float4 worldPos = mul(ubo.model, float4(x, WATER_LEVEL + h, z, 1.0));
    output.pos      = mul(ubo.projection, mul(ubo.view, worldPos));
    output.worldPos = worldPos.xyz;
    return output;
}

[shader("fragment")]
float4 fragMain(VSOutput vertIn) : SV_TARGET {
    float3 dx = ddx(vertIn.worldPos);
    float3 dy = ddy(vertIn.worldPos);
    float3 normal = normalize(cross(dy, dx));
    if (normal.y < 0.0) normal = -normal;

    float3 lightDir = normalize(ubo.lightDir);

    float3x3 R    = (float3x3)ubo.view;
    float3 t      = float3(ubo.view[0][3], ubo.view[1][3], ubo.view[2][3]);
    float3 camPos = -mul(t, R);
    camPos.y = -camPos.y;

    float3 viewDir = normalize(camPos - vertIn.worldPos);
    float3 halfwayDir = normalize(lightDir + viewDir);

    float ambient  = 0.2;
    float diffuse  = max(dot(normal, lightDir), 0.0);
    float specular = pow(max(dot(normal, halfwayDir), 0.0), 8.0) * 0.4;

    float3 waterColor = float3(0.06, 0.42, 0.68);
    float3 color = waterColor * (ambient + (1.0 - ambient) * diffuse);// + float3(1.0, 1.0, 1.0) * specular;
    return float4(color, 0.6);
}
