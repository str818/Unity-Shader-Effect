//Bloom效果
Shader "Custom/Bloom"
{
    Properties
    {
        _MainTex("Base (RGB)", 2D) = "white" {}
		_Bloom ("Bloom (RGB)", 2D) = "black" {}
    }
    CGINCLUDE
    #include "UnityCG.cginc"

    sampler2D _MainTex;
	sampler2D _Bloom;
    
    fixed4 _ColorMix;	
	half4 _MainTex_TexelSize;
	fixed4 _Parameter;
    float4 _offsets;
 
	//第一步：根据阀值提取图像结构体
	struct v2f_withMaxCoords {
		half4 pos : SV_POSITION;
		half2 uv2[5] : TEXCOORD0;
	};
	//第一步：根据阀值提取图像顶点着色器
	//在vert函数里对uv坐标做了四次偏移，对原像素周围临近的像素采样
	v2f_withMaxCoords vertMax (appdata_img v)
	{
		v2f_withMaxCoords o;
		o.pos = UnityObjectToClipPos (v.vertex);
        o.uv2[0] = v.texcoord + _MainTex_TexelSize.xy * half2(1.5,1.5);					
		o.uv2[1] = v.texcoord + _MainTex_TexelSize.xy * half2(-1.5,1.5);
		o.uv2[2] = v.texcoord + _MainTex_TexelSize.xy * half2(-1.5,-1.5);
		o.uv2[3] = v.texcoord + _MainTex_TexelSize.xy * half2(1.5,-1.5);
		o.uv2[4] = v.texcoord ;
		return o; 
	}				
	//第一步：根据阀值提取图像片元着色器
	fixed4 fragMax ( v2f_withMaxCoords i ) : COLOR
	{				
		fixed4 color = tex2D(_MainTex, i.uv2[4]);
		color = max(color, tex2D (_MainTex, i.uv2[0]));	
		color = max(color, tex2D (_MainTex, i.uv2[1]));	
		color = max(color, tex2D (_MainTex, i.uv2[2]));	
		color = max(color, tex2D (_MainTex, i.uv2[3]));	
		return saturate(color - _Parameter.w);
	} 


    //第二步：高斯模糊结构体
	//blur结构体，从blur的vert函数传递到frag函数的参数
    struct v2f_blur
    {
        float4 pos : SV_POSITION;   //顶点位置
        float2 uv  : TEXCOORD0;     //纹理坐标
        float4 uv01 : TEXCOORD1;    //一个vector4存储两个纹理坐标
        float4 uv23 : TEXCOORD2;    //一个vector4存储两个纹理坐标
        float4 uv45 : TEXCOORD3;    //一个vector4存储两个纹理坐标
    };
	//第二步：高斯模糊顶点着色器
    v2f_blur vert_blur(appdata_img v)
    {
        v2f_blur o;
        o.pos = UnityObjectToClipPos(v.vertex);
        //uv坐标
        o.uv = v.texcoord.xy;
 
        //计算一个偏移值，offset可能是（0，1，0，0）也可能是（1，0，0，0）这样就表示了横向或者竖向取像素周围的点
        _offsets *= _MainTex_TexelSize.xyxy * _Parameter.x;
         
        o.uv01 = v.texcoord.xyxy + _offsets.xyxy * float4(1, 1, -1, -1);
        o.uv23 = v.texcoord.xyxy + _offsets.xyxy * float4(1, 1, -1, -1) * 2.0;
        o.uv45 = v.texcoord.xyxy + _offsets.xyxy * float4(1, 1, -1, -1) * 3.0;
 
        return o;
    }
    //第二步：高斯模糊片元着色器
    fixed4 frag_blur(v2f_blur i) : SV_Target
    {
        fixed4 color = fixed4(0,0,0,0);
        //将像素本身以及像素左右（或者上下，取决于vertex shader传进来的uv坐标）像素值的加权平均
        color += 0.4 * tex2D(_MainTex, i.uv);
        color += 0.15 * tex2D(_MainTex, i.uv01.xy);
        color += 0.15 * tex2D(_MainTex, i.uv01.zw);
        color += 0.10 * tex2D(_MainTex, i.uv23.xy);
        color += 0.10 * tex2D(_MainTex, i.uv23.zw);
        color += 0.05 * tex2D(_MainTex, i.uv45.xy);
        color += 0.05 * tex2D(_MainTex, i.uv45.zw);
        return color;
    }
 
	//第三步：混合
	struct v2f_mix {
		half4 pos : SV_POSITION;
		half4 uv : TEXCOORD0;
	};
	v2f_mix vertMix (appdata_img v)
	{
		v2f_mix o;
		o.pos = UnityObjectToClipPos (v.vertex);
        o.uv = v.texcoord.xyxy;			
        #if UNITY_UV_STARTS_AT_TOP//SHADER_API_D3D9
        if (_MainTex_TexelSize.y < 0.0)
        	o.uv.w = 1.0 - o.uv.w;
        #endif
		return o; 
	}
	fixed4 fragMix( v2f_mix i ) : COLOR
	{	
		fixed4 color = tex2D(_MainTex, i.uv.xy);
		color += tex2D(_Bloom, i.uv.zw)*_Parameter.z*_ColorMix;
		return color;
	}	

    ENDCG
 
    SubShader {
		ZTest Always  ZWrite Off Cull Off
		//0  
		Pass { 
			CGPROGRAM	
			#pragma vertex vertMax
			#pragma fragment fragMax
			ENDCG	 
		}	
		//1	
		Pass {
			CGPROGRAM 
			#pragma vertex vert_blur
			#pragma fragment frag_blur
			ENDCG
		}	
		//2
		Pass {
			CGPROGRAM
			#pragma vertex vertMix
			#pragma fragment fragMix
			ENDCG
		}	
	}	
}