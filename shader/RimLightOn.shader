//边缘发光效果
Shader "Custom/RimLightOn" {  
    Properties {  
        _MainTex ("Base (RGB)", 2D) = "white" {}//主纹理
        _Color ("Main Color", Color) = (1, 1, 1, 1)//主颜色值
        _RimColor ("Rim Color", Color) = (1, 1, 1, 1)//边缘发光颜色
        _RimWidth ("Rim Width", Float) = 0.8//边缘发光宽度
    }  
    SubShader {  
        Pass {  
            Lighting Off//关闭光照效果
            CGPROGRAM  
                #pragma vertex vert//声明顶点着色器 
                #pragma fragment frag//声明片元着色器
                #include "UnityCG.cginc"//导入UnityCG工具包
  
                struct a2f{//顶点着色器输入结构体
                    float4 pos : POSITION;  
                    float3 normal : NORMAL;  
                    float2 uv : TEXCOORD0;  
                };  
  
                struct v2f{//顶点着色器输出结构体  
                    float4 pos : SV_POSITION;  
                    float2 uv : TEXCOORD0;  
                    fixed3 color : COLOR;  
                };  
  
				fixed4 _RimColor;  
                float _RimWidth;  
				sampler2D _MainTex;  
				fixed4 _Color;  
  
                v2f vert (a2f v) {//顶点着色器
                    v2f o;//定义输出结构体
                    o.pos = UnityObjectToClipPos (v.pos);//将顶点坐标从物体坐标系转换到剪裁坐标系
                    float3 viewDir = normalize(ObjSpaceViewDir(v.pos));//获取顶点对应的视线方向
                    float dotValue = 1 - dot(v.normal, viewDir);//构造平滑差值的参数
                     
                    o.color = smoothstep(1 - _RimWidth, 1.0, dotValue);//根据因子计算边缘发光强度
                    o.color *= _RimColor;//混合边缘发光颜色  
                    o.uv = v.uv.xy;//将纹理坐标传递到片元着色器
                    return o;  
                }  
  
                fixed4 frag(v2f i) : COLOR {//片元着色器
                    fixed4 texcol = tex2D(_MainTex, i.uv);//纹理采样
                    texcol *= _Color;//混合主颜色
                    texcol.rgb += i.color;//混合边缘发光片元的颜色值
                    return texcol;
                }  
            ENDCG  
        }  
    }  
}  