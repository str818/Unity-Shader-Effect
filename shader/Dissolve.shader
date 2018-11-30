//消融效果
Shader "Custom/Dissolve"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}//主纹理
		_NoiseTex("Noise", 2D) = "white" {}//噪声纹理
		_Threshold("Threshold", Range(0.0, 1.0)) = 0.5//消融阀值
		_EdgeLength("Edge Length", Range(0.0, 0.2)) = 0.1//边缘宽度
		_EdgeFirstColor("First Edge Color", Color) = (1,1,1,1)//边缘颜色值1
		_EdgeSecondColor("Second Edge Color", Color) = (1,1,1,1)//边缘颜色值2
	}
	SubShader
	{
		Tags { "Queue"="Geometry" "RenderType"="Opaque" }//标签

		Pass
		{
			Cull Off //要渲染背面保证效果正确

			CGPROGRAM
			#pragma vertex vert//声明顶点着色器
			#pragma fragment frag//声明片元着色器
			
			#include "UnityCG.cginc"

			struct a2v//顶点着色器输入结构体
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uvMainTex : TEXCOORD0;
				float2 uvNoiseTex : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _NoiseTex;
			float4 _NoiseTex_ST;
			float _Threshold;
			float _EdgeLength;
			fixed4 _EdgeFirstColor;
			fixed4 _EdgeSecondColor;
			
			v2f vert (a2v v)//顶点着色器
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);//将顶点坐标变化到剪裁坐标系
				o.uvMainTex = TRANSFORM_TEX(v.uv, _MainTex);//进行主纹理坐标变换
				o.uvNoiseTex = TRANSFORM_TEX(v.uv, _NoiseTex);//进行噪声纹理坐标变换
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target//片元着色器
			{
				fixed cutout = tex2D(_NoiseTex, i.uvNoiseTex).r;//获取灰度图的R通道
				clip(cutout - _Threshold);//根据消融阀值裁剪片元

				float degree = saturate((cutout - _Threshold) / _EdgeLength);//规范化
				fixed4 edgeColor = lerp(_EdgeFirstColor, _EdgeSecondColor, degree);//对颜色值进行插值

				fixed4 col = tex2D(_MainTex, i.uvMainTex);//对主纹理进行采样

				fixed4 finalColor = lerp(edgeColor, col, degree);//对边缘颜色与片元颜色进行插值
				return fixed4(finalColor.rgb, 1);
			}
			ENDCG
		}
	}
}
