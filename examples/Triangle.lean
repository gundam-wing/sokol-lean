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
      let shd ← Gfx.Shader.make {
        vertex := vsGL
        fragment := fsGL
        attrNames := #["position", "color0"]
      }
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
