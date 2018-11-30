using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class WaterScreen : MonoBehaviour
{
    //-------------------变量声明部分-------------------  
    #region Variables  

    public Material _Material;//当前的材质  

    //时间变量和素材图的定义  
    private float TimeX = 1.0f;//时间变量  
    public Texture2D ScreenWaterDropTex;//屏幕水滴的素材图  

    //可以在编辑器中调整的参数值  
    [Range(5, 64), Tooltip("溶解度")]
    public float Distortion = 8.0f;
    [Range(0, 7), Tooltip("水滴在X坐标上的尺寸")]
    public float SizeX = 1f;
    [Range(0, 7), Tooltip("水滴在Y坐标上的尺寸")]
    public float SizeY = 0.5f;
    [Range(0, 10), Tooltip("水滴的流动速度")]
    public float DropSpeed = 3.6f;

    //用于参数调节的中间变量  
    public static float ChangeDistortion;
    public static float ChangeSizeX;
    public static float ChangeSizeY;
    public static float ChangeDropSpeed;
    #endregion
    //-------------------------------------【OnRenderImage()函数】------------------------------------    
    // 说明：此函数在当完成所有渲染图片后被调用，用来渲染图片后期效果  
    //--------------------------------------------------------------------------------------------------------  
    void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
    {
        //着色器实例不为空，就进行参数设置  
        if (_Material != null)
        {
            //时间的变化  
            TimeX += Time.deltaTime;
            //时间大于100，便置0，保证可以循环  
            if (TimeX > 100) TimeX = 0;

            //设置Shader中其他的外部变量  
            _Material.SetFloat("_CurTime", TimeX);
            _Material.SetFloat("_Distortion", Distortion);
            _Material.SetFloat("_SizeX", SizeX);
            _Material.SetFloat("_SizeY", SizeY);
            _Material.SetFloat("_DropSpeed", DropSpeed);
            _Material.SetTexture("_ScreenWaterDropTex", ScreenWaterDropTex);

            //拷贝源纹理到目标渲染纹理，加上我们的材质效果  
            Graphics.Blit(sourceTexture, destTexture, _Material);
        }
        //着色器实例为空，直接拷贝屏幕上的效果。此情况下是没有实现屏幕特效的  
        else
        {
            //直接拷贝源纹理到目标渲染纹理  
            Graphics.Blit(sourceTexture, destTexture);
        }


    }

}