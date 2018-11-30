Shader "Custom/Fresnel" {
	Properties{
		_Color("Color Tint", Color) = (1, 1, 1, 1)//主颜色
		_ReflectColor("Reflection Color", Color) = (1, 1, 1, 1)//反射光颜色
		_RefractColor("Refraction Color", Color) = (1, 1, 1, 1)//折射光颜色
		_RefractRatio("Refraction Ratio", Range(0.1, 1)) = 0.5//折射率
		_Cubemap("Reflection Cubemap", Cube) = "_Skybox" {}//立方体纹理
		_MaxH("Max Value", Range(0, 1)) = 0.7//入射角大于此值，仅计算折射
		_MinH("Min Value", Range(0, 1)) = 0.2//入射角小于此值，仅计算发射
	}
	SubShader{
		Tags{ "RenderType" = "Opaque" "Queue" = "Geometry" }
		Pass{
			Tags{ "LightMode" = "ForwardBase" }
			CGPROGRAM
			#pragma vertex vert//声明顶点着色器
			#pragma fragment frag//声明片元着色器
			#include "Lighting.cginc"//导入"Lighting"工具包
			#include "AutoLight.cginc"//导入"AutoLight"工具包
			fixed4 _Color;//定义主颜色变量
			fixed4 _ReflectColor;//定义反射光颜色变量
			fixed4 _RefractColor;//定义折射光颜色变量
			fixed _RefractRatio;//定义折射率变量
			samplerCUBE _Cubemap;//定义立方体纹理对象
			fixed _MaxH;
			fixed _MinH;

			struct a2v {//定义顶点着色器输入结构体
				float4 vertex : POSITION;//顶点位置
				float3 normal : NORMAL;//法向量
			};
			struct v2f {//定义顶点着色器输出结构体
				float4 pos : SV_POSITION;//顶点在剪裁坐标系中的坐标
				float3 worldPos : TEXCOORD0;//顶点在世界空间中的坐标
				fixed3 worldNormal : TEXCOORD1;//世界空间中的法线
				fixed3 worldViewDir : TEXCOORD2;//世界空间中的视线方向
			};
			v2f vert(a2v v) {
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);//从模型坐标系到剪裁坐标系

				o.worldNormal = UnityObjectToWorldNormal(v.normal);//世界坐标系下的法向量

				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;//世界坐标系下的顶点位置

				o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);//视线方向

				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 worldViewDir = normalize(i.worldViewDir);

				fixed3 vTextureCoord;//用于进行立方图纹理采样的向量
				fixed3 reflection;//反射采样结果
				fixed3 refraction;//折射采样结果
				fixed3 color;//最终颜色

				//计算视线向量与法向量的余弦值（有错）
				fixed testValue = abs(dot(worldViewDir,worldNormal));
				if (testValue > _MaxH) {//余弦值大于MaxH仅折射
					vTextureCoord = refract(-worldViewDir, worldNormal, _RefractRatio);
					refraction = texCUBE(_Cubemap, vTextureCoord).rgb * _RefractColor.rgb;
					color = refraction;
				}
				else if (testValue > _MinH && testValue < _MaxH) {//折射与反射融合
					vTextureCoord = reflect(-worldViewDir, worldNormal);
					reflection = texCUBE(_Cubemap, vTextureCoord).rgb * _ReflectColor.rgb;
					vTextureCoord = refract(-worldViewDir, worldNormal, _RefractRatio);
					refraction = texCUBE(_Cubemap, vTextureCoord).rgb * _RefractColor.rgb;
					fixed ratio = (testValue - _MinH) / (_MaxH - _MinH);
					color = refraction * ratio + reflection * (1.0 - ratio);
				}
				else {//只有反射
					vTextureCoord = reflect(-worldViewDir, worldNormal);
					reflection = texCUBE(_Cubemap, vTextureCoord).rgb * _ReflectColor.rgb;
					color = reflection;
				}

				return fixed4(color, 0.5);
			}

			ENDCG
		}
	}
}
