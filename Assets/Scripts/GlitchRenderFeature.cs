using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class GlitchRenderFeature : ScriptableRendererFeature
{
    class WhiteScreenPass : ScriptableRenderPass
    {
        private Material material;

        public WhiteScreenPass(Material material)
        {
            this.material = material;
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get("WhiteScreenPass");

            RenderTargetIdentifier source = renderingData.cameraData.renderer.cameraColorTarget;

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
//using UnityEngine;
//using UnityEngine.Rendering;
//using UnityEngine.Rendering.Universal;

//public class GlitchRenderFeature : ScriptableRendererFeature
//{
//    class BloomPass : ScriptableRenderPass
//    {
//        private Material bloomMaterial;
//        private RenderTargetIdentifier source;
//        private RenderTargetHandle tempTexture;

//        public BloomPass(Material material)
//        {
//            bloomMaterial = material;
//            tempTexture.Init("_TemporaryBloomTexture");
//        }

//        public void Setup(RenderTargetIdentifier source)
//        {
//            this.source = source;
//        }

//        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
//        {
//            CommandBuffer cmd = CommandBufferPool.Get("Bloom Pass");

//            RenderTextureDescriptor opaqueDesc = renderingData.cameraData.cameraTargetDescriptor;
//            opaqueDesc.depthBufferBits = 0;

//            cmd.GetTemporaryRT(tempTexture.id, opaqueDesc, FilterMode.Bilinear);

//            // Apply bloom shader
//            Blit(cmd, source, tempTexture.Identifier(), bloomMaterial);
//            Blit(cmd, tempTexture.Identifier(), source);

//            Debug.Log("Executing Bloom Pass");
//            Debug.Log("Source: " + source);

//            context.ExecuteCommandBuffer(cmd);
//            CommandBufferPool.Release(cmd);
//        }

//        public override void FrameCleanup(CommandBuffer cmd)
//        {
//            cmd.ReleaseTemporaryRT(tempTexture.id);
//        }
//    }

//    [System.Serializable]
//    public class BloomSettings
//    {
//        public RenderPassEvent renderPassEvent = RenderPassEvent.AfterRenderingOpaques;
//        public Material bloomMaterial = null;
//    }

//    public BloomSettings settings = new BloomSettings();
//    BloomPass bloomPass;

//    public override void Create()
//    {
//        bloomPass = new BloomPass(settings.bloomMaterial);
//        bloomPass.renderPassEvent = settings.renderPassEvent;
//    }

//    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
//    {
//        Debug.Log("Adding Bloom Pass to render queue");

//        bloomPass.Setup(renderer.cameraColorTarget);
//        renderer.EnqueuePass(bloomPass);
//    }
//}
