using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class GlitchRenderFeature : ScriptableRendererFeature
{
    class WhiteScreenPass : ScriptableRenderPass
    {
        private Material material;
        private float offset = 0f; // 用于控制 _Offset 的值
        private float fade = 0f;   // 用于控制 _Fade 的值
        private float speed = 0.1f;  // 控制 _Offset 增长的速度
        private bool startGlitching = false;

        public WhiteScreenPass(Material material)
        {
            this.material = material;
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            //Debug.Log("Execute");

            if (!startGlitching)
            {
                material.SetFloat("_Offset", 0);
                material.SetFloat("_Fade", fade);
            }

            if (Input.GetKey(KeyCode.A))
            {
                startGlitching = true;
                Debug.Log("StartGlitching");
            }

            CommandBuffer cmd = CommandBufferPool.Get("WhiteScreenPass");

            RenderTargetIdentifier source = renderingData.cameraData.renderer.cameraColorTarget;

            // 逐渐加速的速度控制
            if (startGlitching)
            {
                float accelerationFactor = 1.001f;
                speed *= accelerationFactor;
                offset += Time.deltaTime * speed;

                // 当 offset 达到 5 时设置 fade 为 1
                if (offset >= 5f)
                {
                    fade = 1f;
                }
            }
            
            // 更新到材质上
            material.SetFloat("_Offset", offset);
            material.SetFloat("_Fade", fade);

            // 创建临时渲染纹理
            RenderTextureDescriptor opaqueDesc = renderingData.cameraData.cameraTargetDescriptor;
            int tempID = Shader.PropertyToID("_TempTexture");
            cmd.GetTemporaryRT(tempID, opaqueDesc);

            Blit(cmd, source, tempID, material); // 先把结果Blit到临时纹理
            Blit(cmd, tempID, source);           // 再Blit回到源

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

    }

    public Material material;
    private WhiteScreenPass whiteScreenPass;

    public override void Create()
    {
        whiteScreenPass = new WhiteScreenPass(material);
        whiteScreenPass.renderPassEvent = RenderPassEvent.AfterRendering;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(whiteScreenPass);
    }
}
