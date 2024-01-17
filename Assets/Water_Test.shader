Shader "Custom/Water"
{
    Properties
    {
        _BumpMap ("NormalMap", 2D) = "bump" {}
        _Cube("Cube", Cube) = "" {}
        _StoneTex("ICE_Texture",2D) = "white"{}
        _MaskTex("마스크 텍스쳐",2D) = "white"{}

        _NoTexture("Notexture",2D) = "white"{}

        _SPColor("Specular Color",color) = (1,1,1,1)
        _SPPower("Specular Power",Range(50,300)) = 150
        _SPMulti("Specular Multiply",Range(1,10)) = 3
        _WaveH("Wave Height",Range(0,0.5)) = 0.1
        _WaveL("Wave Legth",Range(5,20)) = 12
        _WaveT("Wave Timeing",Range(0,10)) = 1
        _Refract("Refract Strength", Range(0,0.2)) = 0.1
        _Thickness("석화된 부분의 두께",float) = 0
        _MixProgress("석화 진행도",Range(0,1)) = 0



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
        sampler2D _StoneTex;
        sampler2D _MaskTex;
        sampler2D _NoTexture;
        float4 _SPColor;
        float _SPPower;
        float _SPMulti;
        float _WaveH;
        float _WaveL;
        float _WaveT;
        float _Refract;
        float _Thickness;
        float _MixProgress;
        float _MixValue;
        float xTIme = 0.7;

        void vert(inout appdata_full v) {
            float movement;
            movement = sin(abs((v.texcoord.x * 2 - 1) * _WaveL) + _Time.y * _WaveT) * _WaveH;
            movement += sin(abs((v.texcoord.y * 2 - 1) * _WaveL) + _Time.y * _WaveT) * _WaveH;
            

            if (xTIme < 0) {
                movement = 0;
            }

            if (_MixProgress > 0.2) {
                v.vertex.y += movement / 2;
            }
            
            



            float m = tex2Dlod(_MaskTex, v.texcoord).r;
            v.vertex.xyz -= v.normal * _Thickness * ((m <= (_MixProgress)) ? 1 : 0);
        }
        

        struct Input
        {
            float2 uv_BumpMap;
            float3 worldRefl;
            float3 viewDir;
            float4 screenPos;
            float2 uv_StoneTex;
            float2 uv_MaskTex;
            float2 uv_NoTexture;
            
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
           float calculate = 0.7;
           float place = 0.9;
           float exact = 0.3;


           for (int i = 0; i <= 6; i++) {
               if (_MixProgress < place) {
                   calculate = place - exact;
                   place = place - 0.1;
                   
               }
               if (place <= 0) {
                   xTIme = 0;
               }
           }
           

           

           float4 c = tex2D(_NoTexture, IN.uv_NoTexture);
           float3 normal1 = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap + _Time.x * calculate));
           float3 normal2 = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap + _Time.x * calculate));
          
           
           o.Normal = (normal1 + normal2) / 2;

            float3 refcolor = texCUBE(_Cube, WorldReflectionVector(IN, o.Normal));

           float3 screenUV = IN.screenPos.rgb / IN.screenPos.a;
           float3 refraction = tex2D(_GrabTexture, (screenUV.xy + o.Normal.xy * _Refract));


            float rim = saturate(dot(o.Normal, IN.viewDir));
            rim = pow(1-rim,5.0);
            o.Emission = (refcolor * rim + refraction) * 0.5;
            

            float3 stone = tex2D(_StoneTex, IN.uv_StoneTex);
            float3 mixStone = lerp((o.Normal.r + o.Normal.g + c.b) * 0.3, stone, _MixValue);
            float mask = tex2D(_MaskTex, IN.uv_MaskTex).r;

            o.Albedo = lerp(c, (refcolor * rim + refraction) * 0.5 , (mask <= (_MixProgress)) ? 1 : 0);

            //o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));


            o.Alpha = 1;

            //o.Emission = refcolor;
            //o.Alpha = 0.2;
        }

        float4 LightingWaterSpecular(SurfaceOutput s, float3 lightDir, float3 viewDir, float atten) {
            float3 H = normalize(lightDir + viewDir);
            float spec = saturate(dot(H, s.Normal));
            spec = pow(spec, _SPPower);

            float4 finalColor;
            finalColor.rgb = spec * _SPColor.rgb * _SPMulti;
            finalColor.a = s.Alpha; // +spec
            return finalColor;
        }
        ENDCG
    }
    FallBack "Legacy Shaders/Transparent/Vertexlit"
}
