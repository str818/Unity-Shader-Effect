using UnityEngine;
using System.Collections;

//编辑状态下也运行
[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class Bloom: MonoBehaviour
{
    public Material _Material;//图像处理材质

    public Color colorMix = new Color(1, 1, 1, 1);//特效的颜色

    [Range(0.0f, 1.0f)]
    public float threshold = 0.25f;//Bloom效果范围

    [Range(0.0f, 2.5f)]
    public float intensity = 0.75f;//Bloom特效强度

    [Range(0.2f, 1.0f)]
    public float BlurSize = 1.0f;//模糊范围与质量

    //降分辨率
    public int downSample = 2;

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_Material)
        {
            _Material.SetColor("_ColorMix", colorMix);
            _Material.SetVector("_Parameter", new Vector4(BlurSize * 1.5f, 0.0f, intensity, 0.8f - threshold));

            //申请RenderTexture，RT的分辨率按照downSample降低
            RenderTexture rt1 = RenderTexture.GetTemporary(source.width >> downSample, source.height >> downSample, 0, source.format);
            RenderTexture rt2 = RenderTexture.GetTemporary(source.width >> downSample, source.height >> downSample, 0, source.format);

            //第一步：根据阀值提取图像
            Graphics.Blit(source, rt1, _Material, 0);

            //第二步：高斯模糊
            //第一次高斯模糊，设置offsets，竖向模糊
            _Material.SetVector("_offsets", new Vector4(0, 1, 0, 0));
            Graphics.Blit(rt1, rt2, _Material, 1);
            //第二次高斯模糊，设置offsets，横向模糊
            _Material.SetVector("_offsets", new Vector4(1, 0, 0, 0));
            Graphics.Blit(rt2, rt1, _Material, 1);

            //第三步：与原图像混合
            _Material.SetTexture("_Bloom", rt1);
            Graphics.Blit(source, destination, _Material, 2);

            //释放申请的两块RenderBuffer内容
            RenderTexture.ReleaseTemporary(rt1);
            RenderTexture.ReleaseTemporary(rt2);
        }
    }
}
