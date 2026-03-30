struct VSInput {
    float3 inPosition;
    float3 inNormal;
};

struct UniformBuffer {
    float4x4 model;
    float4x4 view;
    float4x4 projection;
    float3 lightDir;
};
[[vk::binding(0, 0)]] ConstantBuffer<UniformBuffer> ubo;

struct VSOutput {
    float4 pos : SV_Position;
    float3 normal;
    float worldY;
};

[shader("vertex")]
VSOutput vertMain(VSInput input) {
    VSOutput output;
    float4 worldPos = mul(ubo.model, float4(input.inPosition, 1.0));
    output.pos = mul(ubo.projection, mul(ubo.view, worldPos));
    output.normal = normalize(mul((float3x3)ubo.model, input.inNormal));

    output.worldY = worldPos.y;
    return output;
}

[shader("fragment")]
float4 fragMain(VSOutput vertIn) : SV_TARGET {
    float3 normal   = normalize(vertIn.normal);

    float ambient = 0.35;
    float diffuse = max(dot(normal, ubo.lightDir), 0.0);
    float light = ambient + 1.0 * (1.0 - ambient) * diffuse;

    float waterLevel = 4.0;
    float grassStart = 5.5;
    float t = clamp((vertIn.worldY - waterLevel) / (grassStart - waterLevel), 0.0, 1.0);
    float3 sandColor  = float3(0.85, 0.78, 0.40);
    float3 grassColor = float3(0.17, 0.55, 0.08);
    float3 color = lerp(grassColor, sandColor, t);

    if (vertIn.worldY > waterLevel) {
        float depth = clamp((vertIn.worldY - waterLevel) / 8.0, 0.0, 1.0);
        float3 waterTint = float3(0.05, 0.10, 0.18);
        color = lerp(color, waterTint, depth * 0.75);
    }

    return float4(color * light, 1.0);
}
