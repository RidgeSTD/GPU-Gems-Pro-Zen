// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "NinCoolShader/MyForwardRendering2"
{
	Properties
	{
		_Diffuse("Diffuse", Color) = (1, 1, 1, 1)
		_Specular("Specular", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", Range(8.0, 256)) = 20

		_fAttenuation0("Attenuation0", Range(0.01, 1.0)) = 0.01
		_fAttenuation1("Attenuation1", Range(0.01, 1.0)) = 0.01
		_fAttenuation2("Attenuation2", Range(0.01, 1.0)) = 0.01
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }

		Pass
		{
			CGPROGRAM
			#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};

			
			v2f vert (a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.worldNormal = UnityObjectToWorldNormal(v.normal);

				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed atten = 1.0;

				return fixed4(ambient * atten, 1.0);
			}
			ENDCG
		}
		
		Pass
		{
			Tags{"LightMode" = "ForwardAdd"}

			Blend One One

			CGPROGRAM

			#pragma multi_compile_fwdadd

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			
			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			float _fAttenuation0;
			float _fAttenuation1;
			float _fAttenuation2;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f 
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};

			v2f vert(a2v v) 
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.worldNormal = UnityObjectToWorldNormal(v.normal);

				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				
				fixed3 dirVertex2Light = _WorldSpaceLightPos0.xyz - i.worldPos.xyz;
				
				float fDistance = length(dirVertex2Light);

				fixed atten = 1.0 / (_fAttenuation0 + _fAttenuation1 * fDistance + pow(_fAttenuation2, 2) * fDistance);

				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);

				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));

				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				fixed3 halfDir = normalize(worldLightDir + viewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

                return _WorldSpaceLightPos0;
				return fixed4((diffuse + specular) * atten, 1.0);
			}

			ENDCG

		}
	}
}