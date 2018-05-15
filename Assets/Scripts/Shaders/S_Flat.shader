// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/Flat Shader"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white"{}
		_MainColor("Main Color", Color) = (1,1,1,1)
		_SpecularColor("Specular Color", Color) = (1,1,1,1)
		_ShadowColor("Shadow Color", Color) = (0.1,0.1,0.1,1)
		_Shininess("Shininess", float) = 0.5
		_HighlightType("Highlight Type", int) = 0
	}
	SubShader
	{
		Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			sampler2D _MainTex;
			float4 _MainColor;
			float4 _SpecularColor;
			float4 _ShadowColor;
			float _Shininess;
			int _HighlightType;

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
				float3 diffuseColor : TEXCOORD2;
				float3 specularColor : TEXCOORD3;
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

				float3 v0 = input[0].vertex.xyz;
				float3 v1 = input[1].vertex.xyz;
				float3 v2 = input[2].vertex.xyz;

				float3 centerPos = (v0 + v1 + v2) / 3.0;
				float3 vn = normalize(cross(v1 - v0, v2 - v0));
				
				float3 normalDirection = normalize(mul(float4(vn, 0.0), unity_ObjectToWorld).xyz);
				float3 viewDirection = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, float4(centerPos, 0.0)).xyz);
				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float attenuation = 1;

				float3 ambientLighting = UNITY_LIGHTMODEL_AMBIENT.rgb * _MainColor.rgb;
				float3 diffuseReflection = attenuation * _LightColor0.rgb * _MainColor.rgb * max(0, dot(normalDirection, lightDirection));
				float hglType = clamp(_HighlightType, -1, 1);

				float3 specularReflection;
				if (dot(normalDirection, lightDirection) < 0) {
					specularReflection = float4(0.0, 0.0, 0.0, 0.0);
				}
				else {
					specularReflection = attenuation * _LightColor0.rgb * _SpecularColor.rgb * 
					pow(max(0.0, dot(reflect(-lightDirection, normalDirection), viewDirection * hglType)), _Shininess);
				}
				
				for (int i = 0; i < 3; i++)
				{
					o.pos = input[i].pos;
					o.diffuseColor = ambientLighting + diffuseReflection;
					o.specularColor = specularReflection;
					//o.uv = (input[0].uv + input[1].uv + input[2].uv) / 3; 
					o.uv = input[i].uv;
					outputStream.Append(o);
				}
			}
			
			half4 frag (g2f i) : COLOR
			{
				float4 tex = tex2D(_MainTex, i.uv);
				return float4(i.diffuseColor + i.specularColor, 1) * tex;
			}
			ENDCG
		}
	}
}
