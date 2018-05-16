Shader "Custom/S_Terrain_Flat"
{
	Properties
	{

	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
			#include "AutoLight.cginc"	

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			const static int maxColorCount = 8;
			const static int epsilon = 1E-4;	

			int baseColorCount;
			float3 baseColors[maxColorCount];
			float baseStartHeights[maxColorCount];
			float baseBlends[maxColorCount];

			float minHeight;
			float maxHeight;

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 worldPos : TEXCOORD1;

				SHADOW_COORDS(2) // put shadows data into TEXCOORD1
				fixed3 diff : COLOR0;
				fixed3 ambient : COLOR1;
				float4 pos : SV_POSITION;
			};

			float inverseLerp(float a, float b, float value) {
				return saturate((value - a) / (b - a));
			}
			
			v2f vert (appdata_base v)
			{
				v2f o;
				o.uv = v.texcoord;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.pos = UnityObjectToClipPos(v.vertex);

				half3 worldNormal = UnityObjectToWorldNormal(v.normal);
				half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
				o.diff = nl * _LightColor0.rgb;
				o.ambient = ShadeSH9(half4(worldNormal, 1));
				// compute shadows data
				TRANSFER_SHADOW(o)
				return o;
			}
			
			fixed4 frag (v2f IN) : SV_Target
			{
				fixed shadow = SHADOW_ATTENUATION(IN);
				fixed3 lighting = IN.diff * shadow + IN.ambient;
				float heightPercent = inverseLerp(minHeight, maxHeight, IN.worldPos.y);
				float3 col;
				for (int i = 0; i < baseColorCount; i++)
				{ 
					float drawStrength = saturate(sign(heightPercent - baseStartHeights[i]));
					col = col * (1-drawStrength) + drawStrength * baseColors[i], 1;
				}

				return	float4(col, 1) * float4(lighting, 1);
			}
			ENDCG
		}
	}
}
