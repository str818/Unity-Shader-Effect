//xy方向动画
Shader "Custom/VertexAnimation_3" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_WidthSpan("WidthSpan", Range(4,5)) = 4.2
		_StartAngle("StartAngle", Range(1,4)) = 1
		_Speed("Speed", Range(1,15)) = 1
	}
	SubShader {
		Pass{
			CGPROGRAM

			#pragma vertex vert//声明顶点着色器
			#pragma fragment frag//声明片元着色器

			#include "UnityCG.cginc"

			struct a2v {  
			    float4 pos : POSITION; 
			    float2 uv : TEXCOORD0;
			};

			struct v2f {  
			    float4 pos : SV_POSITION; 
			    float2 uv : TEXCOORD0;
			};

			float4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _WidthSpan;
			float _StartAngle;
			float _Speed;

			v2f vert(a2v v){
				v2f o;
				float angleSpanH = 2 * 3.14159265;
				float startX = -_WidthSpan / 2.0;//起始X坐标

				float currAngleX = _StartAngle * _Time.y * _Speed + ((v.pos.x - startX) / _WidthSpan) * angleSpanH /** _Speed*/;
				
				float HeightSpan = 0.618 * _WidthSpan;
				float startY = -HeightSpan / 2.0;//起始Y坐标

				float currAngleY = _Time.y * _Speed + ((v.pos.y - startY) / HeightSpan) * angleSpanH ;

				float tzX = sin(currAngleX) * 4;
				float tzY = sin(currAngleY) * 4;

				o.pos = UnityObjectToClipPos(float4(v.pos.x, v.pos.y, tzX + tzY, 1));
				o.uv = v.uv;
				return o;
			}

			fixed4 frag(v2f i) :SV_Target{
				fixed4 c = tex2D(_MainTex,i.uv);
				return c;
			}


			ENDCG
		}
	}
	FallBack "Diffuse"
}
