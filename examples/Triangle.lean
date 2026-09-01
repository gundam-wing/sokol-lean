import Sokol

open Sokol Sokol.Gfx

def vsGL : String :=
  "#version 410\n\
   layout(location=0) in vec4 position;\n\
   layout(location=1) in vec4 color0;\n\
   out vec4 color;\n\
   void main() {\n\
     gl_Position = position;\n\
     color = color0;\n\
   }\n"

def fsGL : String :=
  "#version 410\n\
   in vec4 color;\n\
   out vec4 frag_color;\n\
   void main() {\n\
     frag_color = color;\n\
   }\n"

def vsMetal : String :=
  "#include <metal_stdlib>\n\
   using namespace metal;\n\
   struct vs_in {\n\
     float4 position [[attribute(0)]];\n\
     float4 color0 [[attribute(1)]];\n\
   };\n\
   struct vs_out {\n\
     float4 position [[position]];\n\
     float4 color;\n\
   };\n\
   vertex vs_out _main(vs_in in [[stage_in]]) {\n\
     vs_out out;\n\
     out.position = in.position;\n\
     out.color = in.color0;\n\
     return out;\n\
   }\n"

def fsMetal : String :=
  "#include <metal_stdlib>\n\
   using namespace metal;\n\
   struct fs_in {\n\
     float4 color;\n\
   };\n\
   fragment float4 _main(fs_in in [[stage_in]]) {\n\
     return in.color;\n\
   }\n"

def shaderDesc (backend : Backend) : Gfx.ShaderDesc :=
  -- `sg_backend`: GLCORE=0 GLES3=1, Metal=3..5
  if backend.val ≤ 1 then
    { vertex := vsGL, fragment := fsGL, attrNames := #["position", "color0"] }
  else if backend.val ≥ 3 && backend.val ≤ 5 then
    { vertex := vsMetal, fragment := fsMetal }
  else
    { vertex := vsGL, fragment := fsGL, attrNames := #["position", "color0"] }

structure State where
  pip : Pipeline := ⟨0⟩
  vbuf : Buffer := ⟨0⟩

def vertices : Array Float := #[
  -- positions            colors
   0.0,  0.5, 0.5,        1.0, 0.0, 0.0, 1.0,
   0.5, -0.5, 0.5,        0.0, 1.0, 0.0, 1.0,
  -0.5, -0.5, 0.5,        0.0, 0.0, 1.0, 1.0
]

def main : IO Unit := do
  let st ← IO.mkRef ({} : State)
  App.run {
    title := "sokol-lean triangle"
    width := 640
    height := 480
    init := do
      Gfx.setup
      let vbuf ← Gfx.Buffer.ofFloats vertices
      let shd ← Gfx.Shader.make (shaderDesc (← Gfx.backend))
      let pip ← Gfx.Pipeline.make {
        shader := shd
        attrs := #[.float3, .float4]
      }
      st.set { pip, vbuf }
    frame := do
      let s ← st.get
      Gfx.withClearPass Gfx.Color.black do
        Gfx.applyPipeline s.pip
        Gfx.applyBindings { vertexBuffers := #[s.vbuf] }
        Gfx.draw 3
    cleanup := Gfx.shutdown
  }
