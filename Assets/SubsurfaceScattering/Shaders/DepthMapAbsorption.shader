Shader "SSS/DepthMapAbsorption"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LightDepthTex ("Light Depth Map Tex", 2D) = "black" {}
        _ScatterColor ("Scatter Color", Color) = (38, 0, 0, 255)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        // 1. Pass render depth map
        // Pass
        // {
        //     CGPROGRAM
        //     #pragma vertex vert
        //     #pragma fragment frag

        //     #include "UnityCG.cginc"

        //     struct appdata
        //     {
        //         float4 vertex : POSITION;
        //         float2 uv : TEXCOORD0;
        //     };

        //     struct v2f
        //     {
        //         float2 uv : TEXCOORD0;
        //         float4 vertex : SV_POSITION;
        //     };

        //     v2f vert (appdata v)
        //     {
        //         v2f o;
        //         o.vertex = UnityObjectToClipPos(v.vertex);
        //         UNITY_TRANSFER_DEPTH(o.uv);
        //         return o;
        //     }

        //     fixed4 frag (v2f i) : SV_Target
        //     {
        //         // render to depth map
        //         UNITY_OUTPUT_DEPTH(i.uv);
        //     }
        //     ENDCG
        // }

        // 2. Pass
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
             // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _LightDepthTex;
            float4 _MainTex_ST;
            float _ScatterColor;


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
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                // trace light depth map
                // get light depth map uv
                float4 posW = mul(UNITY_MATRIX_M, i.posO);


                return col;
            }

            ENDCG
        }
    }
}
