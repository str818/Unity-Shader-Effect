//浴室玻璃效果
Shader "Custom/Glass" {
Properties {
	_BumpAmt  ("Distortion", range (0,128)) = 10
	_MainTex ("Tint Color (RGB)", 2D) = "white" {}
	_BumpMap ("Normalmap", 2D) = "bump" {}
}
SubShader {
	Tags { "Queue"="Transparent" "RenderType"="Opaque" }
	GrabPass {}
	Pass {
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "UnityCG.cginc"

		struct a2v {
			float4 vertex : POSITION;
			float2 texcoord: TEXCOORD0;
		};

		struct v2f {
			float4 vertex : SV_POSITION;
			float4 uvgrab : TEXCOORD0;//捕获纹理坐标
			float2 uvbump : TEXCOORD1;
			float2 uvmain : TEXCOORD2;
		};

		float _BumpAmt;
		float4 _BumpMap_ST;
		float4 _MainTex_ST;

		v2f vert (a2v v)//顶点着色器
		{
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);//将顶点坐标转换到剪裁坐标系
			#if UNITY_UV_STARTS_AT_TOP
					float scale = -1.0;
				#else
					float scale = 1.0;
				#endif
				//将捕获的纹理坐标规范到0-1之间
				o.uvgrab.xy = (float2(o.vertex.x, o.vertex.y*scale) + o.vertex.w) * 0.5;
				o.uvgrab.zw = o.vertex.zw;
				o.uvbump = TRANSFORM_TEX( v.texcoord, _BumpMap );
				o.uvmain = TRANSFORM_TEX( v.texcoord, _MainTex );
				return o;
			}

			sampler2D _GrabTexture;
			float4 _GrabTexture_TexelSize;
			sampler2D _BumpMap;
			sampler2D _MainTex;

			half4 frag( v2f i ) : COLOR
			{
				//将法线纹理中的颜色值映射成法线方向
				half2 bump = UnpackNormal(tex2D( _BumpMap, i.uvbump )).rg;
				float2 offset = bump * _BumpAmt * _GrabTexture_TexelSize.xy;//计算偏移量
				i.uvgrab.xy = offset * i.uvgrab.z + i.uvgrab.xy;
	
				half4 col = tex2Dproj( _GrabTexture, UNITY_PROJ_COORD(i.uvgrab));//获取颜色值
				half4 tint = tex2D( _MainTex, i.uvmain );//获取主纹理颜色值
				return col * tint;
			}
			ENDCG
		}
	}
}
