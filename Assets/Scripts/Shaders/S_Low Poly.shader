// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/Low Poly Shader"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white"{}
		_MainColor("Main Color", Color) = (1,1,1,1)
		_ShadowColor("Shadow Color", Color) = (0.1,0.1,0.1,1)
		_Threshold("Threshold", float) = 0.5
	}
	SubShader
	{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainColor;
			float4 _ShadowColor;
			float _Threshold;

			struct v2g
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 vertex : TEXCOORD1;
			};

			struct g2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float light : TEXCOORD1;
			};

			v2g vert (appdata_full v)
			{
				v2g o;
				o.vertex = v.vertex;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				return o;
			}
			
			[maxvertexcount(3)]
			void geom(triangle v2g input[3], inout TriangleStream<g2f> outputStream) {
				g2f o;

				float3 SideAB = input[1].vertex - input[0].vertex;
				float3 SideAC = input[2].vertex - input[0].vertex;
				float3 normal = cross(SideAB, SideAC);
				normal = normalize(mul(normal, (float3x3) unity_ObjectToWorld));

				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float NdotL = dot(normal, lightDirection);
				float maxLight = max(0.0, NdotL);

				o.uv = (input[0].uv + input[1].uv + input[2].uv) / 3; 
				o.light = maxLight;

				for (int i = 0; i < 3; i++)
				{
					o.pos = input[i].pos;
					outputStream.Append(o);
				}
			}
			
			fixed4 frag (g2f i) : SV_Target
			{
				float4 tex = tex2D(_MainTex, i.uv);
				float3 lerped = lerp(_ShadowColor, _MainColor, i.light);

				return float4(lerped * tex , 1);
			}
			ENDCG
		}
	}
}
