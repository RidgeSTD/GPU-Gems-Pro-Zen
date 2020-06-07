Shader "SSS/WrapLighting"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Wrap ("Wrap Factor", Range(0, 1)) = 0.2
        _ScatterColor ("Scatter Color", Color) = (38, 0, 0, 255)
        _ScatterWidth ("Scatter Width", Range(0, 1)) = 0.3
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 posW : POSITION1;
                float3 normalW : NORMAL;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Wrap;
            float _ScatterWidth;
            float4 _ScatterColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.posW = mul(UNITY_MATRIX_M, v.vertex);
                o.normalW = normalize(mul(UNITY_MATRIX_M, float4(v.normal, 0)));
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                float4 lightPosW = _WorldSpaceLightPos0;
                float3 L = lerp(lightPosW.xyz, i.posW - lightPosW.xyz, lightPosW.w);
                L = normalize(L);
                float NdotL = dot(i.normalW, L);
                float NdotLWrap = (NdotL + _Wrap) / (1 + _Wrap);
                col *= saturate(NdotL);
                float scatter = smoothstep(0, _ScatterWidth, NdotLWrap) * smoothstep(_ScatterWidth * 2, _ScatterWidth, NdotLWrap);
                col += _ScatterColor * scatter;

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
