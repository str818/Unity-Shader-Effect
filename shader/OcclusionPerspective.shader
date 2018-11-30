// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/OcclusionPerspective" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_PColor("Perspective Color", Color) = (1,1,1,0.5)
	}
	SubShader {
		Tags{"Queue" = "Geometry+1000" "RenderType" = "Opaque"}
		Pass{
			ZWrite off
			Lighting off
			Ztest Greater
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			float4 _PColor;

			struct v2f{
				float4 pos : SV_POSITION;
			};

			v2f vert(appdata_img v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				return o;
			}

			float4 frag(v2f i) : COLOR{
				return _PColor;
			}
			ENDCG
		}

		Pass{
			ZWrite on
			ZTest less

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			//float4 _MainTex_ST;

			struct v2f{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert(appdata_img v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				return o;
			}

			float4 frag(v2f i) : COLOR{
				float4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
