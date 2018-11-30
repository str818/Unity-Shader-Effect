Shader "Unlit/SnowScreen"{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Pass
		{
			Cull Off ZWrite Off ZTest Always
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;//主纹理
			sampler2D _CameraDepthNormalsTexture;//摄像机深度法线纹理
			float4x4 _CamToWorld;//摄像机到世界坐标系的转换矩阵
 
			sampler2D _SnowTex;//雪纹理
			float _SnowTexScale;
 
			half4 _SnowColor;//雪的颜色
 
			fixed _BottomThreshold;
			fixed _TopThreshold;
			
			v2f vert (appdata_img v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord.xy;
				return o;
			}
			
			half3 frag (v2f i) : SV_Target
			{
				half3 normal;//法线
				float depth;//深度值
 
				DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, i.uv), depth, normal);//获取深度值与法线
				normal = mul((float3x3)_CamToWorld, normal);//将法线从摄像机坐标系转换到世界坐标系
 
				// find out snow amount
				half snowAmount = normal.g;//获取法线沿Y方向的分量
				half scale = (_BottomThreshold + 1 - _TopThreshold) / 1 + 1;//计算厚度因子
				snowAmount = saturate( (snowAmount - _BottomThreshold) * scale);//计算雪的厚度
 
				// find out snow color
				float2 p11_22 = float2(unity_CameraProjection._11, unity_CameraProjection._22);
				float3 vpos = float3( (i.uv * 2 - 1) / p11_22, -1) * depth;
				float4 wpos = mul(_CamToWorld, float4(vpos, 1));
				
				wpos += float4(_WorldSpaceCameraPos, 0) / _ProjectionParams.z;
 
				wpos *= _SnowTexScale * _ProjectionParams.z;
				half3 snowColor = tex2D(_SnowTex, wpos.xz) * _SnowColor;
 
				// get color and lerp to snow texture
				half4 col = tex2D(_MainTex, i.uv);
				return lerp(col, snowColor, snowAmount);
				//return half3(1 ,0,0);
			}
			ENDCG
		}
	}
}
