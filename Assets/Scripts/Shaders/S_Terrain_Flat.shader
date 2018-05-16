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
			#pragma geometry geom
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

			float inverseLerp(float a, float b, float value) {
				return saturate((value - a) / (b - a));
			}

			struct v2g
			{
				float2 uv : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float3 vertex : TEXCOORD2;
				float4 pos : SV_POSITION;
			};

			struct g2f {
				float4 pos : SV_POSITION;
				float3 worldPos : TEXCOORD0;
				float light : TEXCOORD1;
			};
			
			v2g vert (appdata_base v)
			{
				v2g o;
				o.uv = v.texcoord;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.vertex = v.vertex;
				return o;
			}

			[maxvertexcount(3)]
			void geom(triangle v2g input[3], inout TriangleStream<g2f> OutputStream) {
				g2f o;

				float3 v0 = input[0].vertex;
				float3 v1 = input[1].vertex;
				float3 v2 = input[2].vertex;

				float3 vn = normalize(cross(v1 - v0, v2 - v0));
				float3 normalDirection = mul(float4(vn, 0), unity_ObjectToWorld).xyz;

				float3 lightdir = normalize(_WorldSpaceLightPos0.xyz);
				float ndotl = max(0.0, dot(normalDirection, lightdir));


				for (int i = 0; i < 3; i++)
				{
					o.worldPos = input[i].worldPos;
					o.pos = input[i].pos;
					o.light = ndotl;
					OutputStream.Append(o);
				}
			}
			
			fixed4 frag (g2f input) : SV_Target
			{
				float heightPercent = inverseLerp(minHeight, maxHeight, input.worldPos.y);
				float3 col;
				for (int i = 0; i < baseColorCount; i++)
				{ 
					float drawStrength = saturate(sign(heightPercent - baseStartHeights[i]));
					col = col * (1-drawStrength) + drawStrength * baseColors[i], 1;
				}
				float4 light = input.light * _LightColor0;

				return light * float4(col, 1);
			}
			ENDCG
		}
	}
}
