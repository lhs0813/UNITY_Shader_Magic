Shader "Custom/ICE_SHADER"
{
    Properties
    {
        _MainTex("_MainTex", 2D) = "white" {}
        _BumpMap("_NormalMap",2D) = "bump"{}
        _IceTex("_ICE TEXTURE",2D) = "white"{}
        _MaskTex("_Mask TEXTURE",2D) = "white"{}
        _MixValue("_TEXTURE VALUE",Range(0,1)) = 0
        _MixProgress("_ICING_PROGRESS",Range(0,1)) = 0
        _Thickness("_ICING_THICKNESS",float) = 0
    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            LOD 200

            CGPROGRAM
            #pragma surface surf Standard fullforwardshadows addshadow vertex:vert
            #pragma target 3.0

            sampler2D _MainTex;
            sampler2D _IceTex;
            sampler2D _MaskTex;
            sampler2D _BumpMap;
            float _MixValue;
            float _MixProgress;
            float _Thickness;

            struct Input
            {
                float2 uv_MainTex;
                float2 uv_IceTex;
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
                float3 Ice = tex2D(_IceTex, IN.uv_IceTex);
                float3 mixIce = lerp((c.r + c.g + c.b) * 0.3, Ice, _MixValue);

                float mask = tex2D(_MaskTex, IN.uv_MaskTex).r;

                o.Albedo = lerp(c,mixIce, (mask <= (_MixProgress)) ? 1 : 0);
                o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
                o.Alpha = c.a;
            }
            ENDCG
        }
            FallBack "Diffuse"
}

