//边缘发光关闭对比效果
Shader "Custom/RimLightOff" {  
    Properties {  
        _MainTex ("Base (RGB)", 2D) = "white" {}  
       /* _Color ("Main Color", Color) = (1,1,1,1)  
        _RimColor ("Rim Color", Color) = (1, 1, 1, 1)  
        _RimWidth ("Rim Width", float) = 0.9  */
    }  
    SubShader {  
        Pass {  
            Lighting Off  
            CGPROGRAM  
                #pragma vertex vert  
                #pragma fragment frag  
                #include "UnityCG.cginc"  
  
                struct appdata   
                {  
                    float4 vertex : POSITION;  
                    float2 texcoord : TEXCOORD0;  
                };  
  
                struct v2f   
                {  
                    float4 pos : SV_POSITION;  
                    float2 uv : TEXCOORD0;  
                };  
 
  
                v2f vert (appdata_base v) {  
                    v2f o;  
                    o.pos = UnityObjectToClipPos (v.vertex);     
                    o.uv = v.texcoord.xy;  
                    return o;  
                }  
  
                uniform sampler2D _MainTex;  
                uniform fixed4 _Color;  
  
                fixed4 frag(v2f i) : COLOR {  
                    fixed4 texcol = tex2D(_MainTex, i.uv);  
                    return texcol;  
                }  
            ENDCG  
        }  
    }  
}  