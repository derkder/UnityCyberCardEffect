using UnityEngine;

[ExecuteInEditMode]
public class WhiteScreenPostProcess : MonoBehaviour
{
    public Material whiteScreenMaterial;

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        // 使用全白材质直接进行后处理
        Graphics.Blit(src, dest, whiteScreenMaterial);
    }
}
