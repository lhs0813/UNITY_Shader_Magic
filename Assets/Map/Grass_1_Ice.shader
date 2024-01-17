Shader "Custom/Grass_1_Ice"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "white" {}
        _BumpMap("NormalMap",2D) = "bump"{}
        _StoneTex("IceTexture",2D) = "white"{}
        _MaskTex("MaskTexture",2D) = "white"{}
        _MixValue("TextureCal",Range(0,1)) = 0
        _MixProgress("IcingRoad",Range(0,1)) = 0
        _Thickness("IceThickness",float) = 0
    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            LOD 200

            CGPROGRAM
            #pragma surface surf Standard fullforwardshadows addshadow vertex:vert
            #pragma target 3.0

            sampler2D _MainTex;
            sampler2D _StoneTex;
            sampler2D _MaskTex;
            sampler2D _BumpMap;
            float _MixValue;
            float _MixProgress;
            float _Thickness;

            struct Input
            {
                float2 uv_MainTex;
                float2 uv_StoneTex;
                float2 uv_MaskTex;
                float2 uv_BumpMap;
            };

            void vert(inout appdata_full v) {
                float m = tex2Dlod(_MaskTex, v.texcoord).r;
                v.vertex.xyz += v.normal * _Thickness * ((m <= (_MixProgress)) ? 1 : 0);
            }


            void surf(Input IN, inout SurfaceOutputStandard o)
            {
                float4 c = tex2D(_MainTex, IN.uv_MainTex);
                float3 stone = tex2D(_StoneTex, IN.uv_StoneTex);
                float3 mixStone = lerp((c.r + c.g + c.b) * 0.3, stone, _MixValue);
                float mask = tex2D(_MaskTex, IN.uv_MaskTex).r;
                o.Albedo = lerp(c,mixStone, (mask <= (_MixProgress)) ? 1 : 0);
                o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
                o.Alpha = c.a;
            }
            ENDCG
        }
            FallBack "Diffuse"
}


