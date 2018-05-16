Shader "Custom/S_Terrain_VF"
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
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			const static int maxColorCount = 8;
			const static int epsilon = 1E-4;	

			int baseColorCount;
			float3 baseColors[maxColorCount];
			float baseStartHeights[maxColorCount];
			float baseBlends[maxColorCount];

			float minHeight;
			float maxHeight;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD1;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				o.uv = v.uv;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f IN) : SV_Target
			{
				float heightPercent;
				for (int i = 0; i < baseColorCount; i++)
				{
					heightPercent = IN.worldPos.y - baseStartHeights[i];
					return float4(baseColors[i] * heightPercent, 1);
				}
				return	float4(1, 1, 1, 1);
			}
			ENDCG
		}
	}
}
