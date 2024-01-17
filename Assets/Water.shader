Shader "Custom/Water"
{
    Properties
    {
        _BumpMap ("NormalMap", 2D) = "bump" {}
        _Cube("Cube", Cube) = "" {}
        _SPColor("Specular Color",color) = (1,1,1,1)
        _SPPower("Specular Power",Range(50,300)) = 150
        _SPMulti("Specular Multiply",Range(1,10)) = 3
        _WaveH("Wave Height",Range(0,0.5)) = 0.1
        _WaveL("Wave Legth",Range(5,20)) = 12
        _WaveT("Wave Timeing",Range(0,10)) = 1
        _Refract("Refract Strength", Range(0,0.2)) = 0.1



    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent"}
        LOD 200

        GrabPass{}

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf WaterSpecular vertex:vert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
        samplerCUBE _Cube;
        sampler2D _BumpMap;
        sampler2D _GrabTexture;
        float4 _SPColor;
        float _SPPower;
        float _SPMulti;
        float _WaveH;
        float _WaveL;
        float _WaveT;
        float _Refract;

        void vert(inout appdata_full v) {
            float movement;
            movement = sin(abs((v.texcoord.x * 2 - 1) * _WaveL) + _Time.y * _WaveT) * _WaveH;
            movement += sin(abs((v.texcoord.y * 2 - 1) * _WaveL) + _Time.y * _WaveT) * _WaveH;
            v.vertex.y += movement / 2;
        }
        

        struct Input
        {
            float2 uv_BumpMap;
            float3 worldRefl;
            float3 viewDir;
            float4 screenPos;
            INTERNAL_DATA
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)



        



        void surf (Input IN, inout SurfaceOutput o)
        {
           float3 normal1 = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap + _Time.x * 0.7));
           float3 normal2 = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap + _Time.x * 1.4));
           o.Normal = (normal1 + normal2) / 2;

           float3 refcolor = texCUBE(_Cube, WorldReflectionVector(IN, o.Normal));

           float3 screenUV = IN.screenPos.rgb / IN.screenPos.a;
           float3 refraction = tex2D(_GrabTexture, (screenUV.xy + o.Normal.xy * _Refract));// 굴절


            float rim = saturate(dot(o.Normal, IN.viewDir));
            rim = pow(1-rim,5.0);
            o.Emission = (refcolor * rim + refraction) * 0.5;
            o.Alpha = 1;

            //o.Emission = refcolor;
            //o.Alpha = 0.2;
        }

        float4 LightingWaterSpecular(SurfaceOutput s, float3 lightDir, float3 viewDir, float atten) {
            float3 H = normalize(lightDir + viewDir); // 방향 벡터만 추출
            float spec = saturate(dot(H, s.Normal)); // 입력을 0과 1로 제한 // 빛과 카메라 뷰의 값과 표면의 벡터의 연산
            spec = pow(spec, _SPPower);// 

            float4 finalColor;
            finalColor.rgb = spec * _SPColor.rgb * _SPMulti;
            finalColor.a = s.Alpha; // +spec
            return finalColor;
        }
        ENDCG
    }
    FallBack "Legacy Shaders/Transparent/Vertexlit"
}
