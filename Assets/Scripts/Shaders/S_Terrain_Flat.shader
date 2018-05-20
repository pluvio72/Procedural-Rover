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

			float randomness;
			sampler2D tex;

			float inverseLerp(float a, float b, float value) {
				return saturate((value - a) / (b - a));
			}

			float rand(float3 co)
			{
				return frac(sin(dot(co.xyz, float3(12.9898, 78.233, 45.5432))) * 43758.5453);
			}

			struct v2g
			{
				float2 uv : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float3 vertex : TEXCOORD2;
				float4 pos : SV_POSITION;
				float4 col : COLOR0;
			};

			struct g2f {
				float4 pos : SV_POSITION;
				float3 worldPos : TEXCOORD0;
				float light : TEXCOORD1;
				float4 col : COLOR0;
				float2 uv : TEXCOORD2;
			};
			
			v2g vert (appdata_base v)
			{
				v2g o;
				o.uv = v.texcoord;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.vertex = v.vertex;

				float heightPercent = inverseLerp(minHeight, maxHeight, o.worldPos.y);
				float3 col;
				for (int i = 0; i < baseColorCount; i++)
				{
					//float drawStrength = saturate(sign(heightPercent - baseStartHeights[i]));
					float drawStrengthWithBlend = inverseLerp(-baseBlends[i] / 2 - epsilon, baseBlends[i] / 2, heightPercent - baseStartHeights[i]);
					col = col * (1 - drawStrengthWithBlend) + drawStrengthWithBlend * baseColors[i], 1;
				}
				o.col = float4(col, 1);

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
				float4 light = ndotl * _LightColor0;

				float random = rand(input[1].col) * randomness - 1E-10;

				//o.uv = (input[0].uv, input[1].uv, input[2].uv) /3;
				for (int i = 0; i < 3; i++)
				{
					o.col = input[i].col + (input[i].col * random);
					o.worldPos = input[i].worldPos;
					o.pos = input[i].pos;
					o.uv = input[i].uv;
					o.light = light;
					OutputStream.Append(o);
				}
			}
			
			fixed4 frag (g2f input) : SV_Target
			{
				float4 textureSample = tex2D(tex, input.uv);
				return (input.light * input.col) * (textureSample * 2);
			}
			ENDCG
		}
	}
}
