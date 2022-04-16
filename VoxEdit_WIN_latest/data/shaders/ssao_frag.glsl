uniform mat4 projection;

const int kernelSize = 128;

uniform sampler2D depthTex;
uniform sampler2D noiseTex;

uniform vec3 kernel[kernelSize];
// tile noise texture over screen based on screen dimensions divided by noise size
uniform vec2 noiseScale;

uniform float zNear;
uniform float zFar;

uniform float radius;
uniform float bias;

varying vec4 viewPos;
varying vec3 viewNormal;
varying vec2 uvs;

vec4 packDepth(float depth) {
  float depthFrac = fract(depth * 255.0);
  return vec4(depth - depthFrac / 255.0, depthFrac, 1.0, 1.0);
}

float unpackDepth(vec4 color) {
  return color.r + color.g / 255.0;
}

void main()
{
    // get input for SSAO algorithm
   	vec3 fragPos = viewPos.xyz;
    vec3 normal = normalize(viewNormal.xyz);  
    vec3 noise = texture(noiseTex, uvs * noiseScale).xyz;
    noise.xy = noise.xy * 2.0f - 1.0f;
    vec3 randomVec = normalize(noise);

    // create TBN change-of-basis matrix: from tangent-space to view-space
    vec3 tangent = normalize(randomVec - normal * dot(randomVec, normal));
    vec3 bitangent = normalize(cross(normal, tangent));
    mat3 TBN = mat3(tangent, bitangent, normal);
    // iterate over the sample kernel and calculate occlusion factor
    
    float occlusion = 0.0;
    for(int i = 0; i < kernelSize; ++i)
    {
        // get sample position
        vec3 ksample = TBN * kernel[i]; // from tangent to view-space
        ksample = fragPos + ksample * radius;
        
        // project sample position (to sample texture) (to get position on screen/texture)
        vec4 offset = vec4(ksample, 1.0);
        offset = projection * offset; // from view to clip-space
        offset.xyz /= offset.w; // perspective divide
        offset.xyz = offset.xyz * 0.5 + 0.5; // transform to range 0.0 - 1.0
        
        // get sample depth
        vec4 packedDepth = texture(depthTex, offset.xy); // get depth value of kernel sample

        float sampleDepth = -unpackDepth(packedDepth) * (zFar - zNear);
        //float sampleDepth = -DecodeFloatRGBA(packedDepth);

        // range check & accumulate
        float rangeCheck = smoothstep(0.0, 1.0, radius / abs(fragPos.z - sampleDepth));
        occlusion += (sampleDepth >= ksample.z + bias ? 1.0 : 0.0) * rangeCheck;
    }
    occlusion = 1.0 - (occlusion / kernelSize);    
    occlusion = pow(occlusion, 1.0f);
    gl_FragColor = vec4(occlusion, occlusion, occlusion, 1.0f);
}
