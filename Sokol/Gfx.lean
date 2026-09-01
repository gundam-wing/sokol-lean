import Sokol.FFI

/-!
Opinionated graphics helpers on top of `Sokol.FFI.Gfx`.

This layer picks defaults (clear-to-color swapchain passes, f32 vertex packing,
pipeline descriptions with triangle topology) so application code can stay in
Lean without repeating Sokol C boilerplate.
-/

namespace Sokol.Gfx
open Sokol.FFI
open Sokol.FFI.Gfx
export Sokol.FFI (Buffer Shader Pipeline VertexFormat PrimitiveType IndexType Backend ResourceState)

structure Color where
  r : Float := 0
  g : Float := 0
  b : Float := 0
  a : Float := 1
deriving Repr, Inhabited, BEq

namespace Color
def rgb (r g b : Float) : Color := { r, g, b }
def gray (x : Float) : Color := { r := x, g := x, b := x }
def black : Color := {}
def white : Color := { r := 1, g := 1, b := 1 }
def coral : Color := rgb 1.0 0.25 0.35
end Color

/-- Set up gfx using the live `sokol_app` environment. Call from `App` init. -/
def setup : IO Unit := FFI.Gfx.setup

/-- Set up gfx without a window. Intended for `SOKOL_DUMMY_BACKEND` tests. -/
def setupHeadless : IO Unit := FFI.Gfx.setupHeadless

def shutdown : IO Unit := FFI.Gfx.shutdown

def isValid : IO Bool := FFI.Gfx.isValid

def backend : IO Backend := FFI.Gfx.queryBackend

namespace Buffer
def ofBytes (data : ByteArray) (index := false) (stream := false) : IO FFI.Buffer :=
  FFI.Gfx.makeBuffer data index stream

/-- Upload `Array Float` as packed f32 vertex/index data. -/
def ofFloats (xs : Array Float) (index := false) (stream := false) : IO FFI.Buffer :=
  ofBytes (packF32 xs) index stream

def sized (size : USize) (index := false) (stream := false) : IO FFI.Buffer :=
  FFI.Gfx.makeBufferSize size index stream

def destroy (b : FFI.Buffer) : IO Unit :=
  FFI.Gfx.destroyBuffer b

def update (b : FFI.Buffer) (data : ByteArray) : IO Unit :=
  FFI.Gfx.updateBuffer b data

def state (b : FFI.Buffer) : IO ResourceState :=
  FFI.Gfx.queryBufferState b
end Buffer

structure ShaderDesc where
  vertex : String
  fragment : String
  /-- GLSL attribute names, in location order. -/
  attrNames : Array String := #[]

namespace Shader
def make (d : ShaderDesc) : IO FFI.Shader :=
  FFI.Gfx.makeShader d.vertex d.fragment d.attrNames

def destroy (s : FFI.Shader) : IO Unit :=
  FFI.Gfx.destroyShader s
end Shader

structure PipelineDesc where
  shader : FFI.Shader
  attrs : Array VertexFormat
  primitive : PrimitiveType := PrimitiveType.triangles
  indexType : IndexType := IndexType.none

namespace Pipeline
def make (d : PipelineDesc) : IO FFI.Pipeline :=
  FFI.Gfx.makePipeline d.shader d.attrs d.primitive d.indexType

def destroy (p : FFI.Pipeline) : IO Unit :=
  FFI.Gfx.destroyPipeline p
end Pipeline

structure Bindings where
  vertexBuffers : Array FFI.Buffer := #[]
  indexBuffer : FFI.Buffer := ⟨0⟩

def applyPipeline (p : FFI.Pipeline) : IO Unit :=
  FFI.Gfx.applyPipeline p

def applyBindings (b : Bindings) : IO Unit :=
  FFI.Gfx.applyBindings b.vertexBuffers b.indexBuffer

def applyUniforms (slot : UInt32) (data : ByteArray) : IO Unit :=
  FFI.Gfx.applyUniforms slot data

def draw (numElements : UInt32) (base : UInt32 := 0) (instances : UInt32 := 1) : IO Unit :=
  FFI.Gfx.draw base numElements instances

def beginClearPass (c : Color) : IO Unit :=
  FFI.Gfx.beginSwapchainPass c.r c.g c.b c.a

def endPass : IO Unit := FFI.Gfx.endPass

def commit : IO Unit := FFI.Gfx.commit

/-- Clear the swapchain, run `body`, then end the pass and commit the frame. -/
def withClearPass (c : Color) (body : IO Unit) : IO Unit := do
  beginClearPass c
  body
  endPass
  commit

def applyViewport (x y w h : UInt32) (originTopLeft := false) : IO Unit :=
  FFI.Gfx.applyViewport x y w h originTopLeft

end Sokol.Gfx
