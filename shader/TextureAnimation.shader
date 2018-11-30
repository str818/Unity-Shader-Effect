//序列帧动画
Shader "Custom/TextureAnimation" {
	Properties{
		_MainTex ("Image Sequence", 2D) = "white" {}//主纹理
    	_HorizontalAmount ("Horizontal Amount", Float) = 4//水平图像数量
    	_VerticalAmount ("Vertical Amount", Float) = 4//竖直图像数量
    	_Speed ("Speed", Range(1, 20)) = 1//序列帧播放速度
	}
	SubShader{
		//设置透明所需标签
		Tags{"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}

		Pass{

			ZWrite Off//关闭深度写入
			Blend SrcAlpha OneMinusSrcAlpha//开启混合

			CGPROGRAM
			#pragma vertex vert//声明顶点着色器
			#pragma fragment frag//声明片元着色器
			
			#include "UnityCG.cginc"
			struct a2v {  
			    float4 vertex : POSITION; 
			    float2 texcoord : TEXCOORD0;
			};  
			
			struct v2f {  
			    float4 pos : SV_POSITION;
			    float2 uv : TEXCOORD0;
			};  

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _HorizontalAmount;
			float _VerticalAmount;
			float _Speed;


			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);//将顶点坐标转化到剪裁空间坐标系
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);//进行纹理坐标变换
				return o;
			}

			fixed4 frag(v2f i) :SV_Target{
				float time = floor(_Time.y * _Speed);
				float row = floor(time / _HorizontalAmount);
				float column = time - row * _HorizontalAmount;

				half2 uv = i.uv + half2(column, -row);
				uv.x /= _HorizontalAmount;
				uv.y /= _VerticalAmount;

				fixed4 c = tex2D(_MainTex, uv);
				return c;

			}
			ENDCG
		}

	}
}

