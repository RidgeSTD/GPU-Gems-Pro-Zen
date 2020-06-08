Shader "SSS/DepthMapAbsorption"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LightDepthTex ("Light Depth Map Tex", 2D) = "black" {}
        _ScatterColor ("Scatter Color", Color) = (38, 0, 0, 255)
        _ScatterFactor ("Scatter Factor", Range(0, 1)) = 0.2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        // 1. Pass base abient lighting
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            // depth texture from secondary camera
            sampler2D _LastCameraDepthTexture;

            sampler2D _MainTex;
            sampler2D _LightDepthTex;
            float4 _MainTex_ST;
            float _ScatterFactor;
            float4 _ScatterColor;


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                // TODO: constant ambient light
                return col * 0.1;
            }

            ENDCG
        }

        // 2. Pass advanced lighting
        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            // depth texture from secondary camera
            sampler2D _LastCameraDepthTexture;

            sampler2D _MainTex;
            sampler2D _LightDepthTex;
            float4 _MainTex_ST;
            float _ScatterFactor;
            float4 _ScatterColor;
            float4x4 _WorldToLightMatrix;
            float4x4 _LightProjectionMatrix;


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 posO : POSITION1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.posO = v.vertex;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                // trace light depth map
                float4 posW = mul(UNITY_MATRIX_M, i.posO);
                float4 posL = mul(_WorldToLightMatrix, posW);
                float4 uvL = mul(_LightProjectionMatrix, posL);
                float3 uvLxyw = UNITY_PROJ_COORD(uvL);
                uvLxyw.xy = (uvLxyw.xy / uvLxyw.z + float2(1,1)) * 0.5;
                float4 depthMapValue = tex2D(_LightDepthTex, uvLxyw.xy);
                float d_i = LinearEyeDepth( depthMapValue.r );

                float d_o = length(posL);
                float penetration = max(d_o - d_i, 0);

                // return fixed4(0, d_i, 0, 1);
                //return depthMapValue * 2;
                return fixed4(penetration, 0, 0, 1);

                return exp(-penetration * _ScatterFactor) * _ScatterColor;
                // return col;
            }

            ENDCG
        }
    }
}
