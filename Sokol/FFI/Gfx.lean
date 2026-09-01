import Sokol.FFI.Types

namespace Sokol.FFI.Gfx
open Sokol.FFI

/-- Pack Lean `Float` values (f64) as little-endian IEEE-754 binary32. -/
@[extern "lean_sokol_pack_f32"]
opaque packF32 (xs : @& Array Float) : ByteArray

/-- `sg_setup` with `sglue_environment()` (call from `sapp` init). -/
@[extern "lean_sg_setup"]
opaque setup : IO Unit

/-- `sg_setup` without a window/swapchain. Used with `SOKOL_DUMMY_BACKEND`. -/
@[extern "lean_sg_setup_headless"]
opaque setupHeadless : IO Unit

@[extern "lean_sg_shutdown"]
opaque shutdown : IO Unit

@[extern "lean_sg_isvalid"]
opaque isValid : IO Bool

@[extern "lean_sg_query_backend"]
private opaque queryBackendId : IO UInt32

def queryBackend : IO Backend :=
  Backend.mk <$> queryBackendId

@[extern "lean_sg_reset_state_cache"]
opaque resetStateCache : IO Unit

@[extern "lean_sg_make_buffer"]
private opaque makeBufferId (data : @& ByteArray) (index stream : Bool) : IO UInt32

def makeBuffer (data : ByteArray) (index := false) (stream := false) : IO Buffer :=
  Buffer.mk <$> makeBufferId data index stream

@[extern "lean_sg_make_buffer_size"]
private opaque makeBufferSizeId (size : USize) (index stream : Bool) : IO UInt32

def makeBufferSize (size : USize) (index := false) (stream := false) : IO Buffer :=
  Buffer.mk <$> makeBufferSizeId size index stream

@[extern "lean_sg_destroy_buffer"]
private opaque destroyBufferId (id : UInt32) : IO Unit

def destroyBuffer (b : Buffer) : IO Unit :=
  destroyBufferId b.id

@[extern "lean_sg_update_buffer"]
private opaque updateBufferId (id : UInt32) (data : @& ByteArray) : IO Unit

def updateBuffer (b : Buffer) (data : ByteArray) : IO Unit :=
  updateBufferId b.id data

@[extern "lean_sg_query_buffer_state"]
private opaque queryBufferStateId (id : UInt32) : IO UInt32

def queryBufferState (b : Buffer) : IO ResourceState :=
  ResourceState.mk <$> queryBufferStateId b.id

@[extern "lean_sg_make_shader"]
private opaque makeShaderId (vs fs : @& String) (attrs : @& Array String) : IO UInt32

def makeShader (vs fs : String) (attrs : Array String := #[]) : IO Shader :=
  Shader.mk <$> makeShaderId vs fs attrs

@[extern "lean_sg_destroy_shader"]
private opaque destroyShaderId (id : UInt32) : IO Unit

def destroyShader (s : Shader) : IO Unit :=
  destroyShaderId s.id

@[extern "lean_sg_make_pipeline"]
private opaque makePipelineId
    (shaderId : UInt32) (formats : @& Array UInt32)
    (primitive indexType : UInt32) : IO UInt32

def makePipeline (shader : Shader) (formats : Array VertexFormat)
    (primitive : PrimitiveType := PrimitiveType.triangles)
    (indexType : IndexType := IndexType.none) : IO Pipeline :=
  Pipeline.mk <$> makePipelineId shader.id (formats.map (·.val)) primitive.val indexType.val

@[extern "lean_sg_destroy_pipeline"]
private opaque destroyPipelineId (id : UInt32) : IO Unit

def destroyPipeline (p : Pipeline) : IO Unit :=
  destroyPipelineId p.id

/-- Swapchain pass that clears color attachment 0. Requires a live `sapp` window. -/
@[extern "lean_sg_begin_swapchain_pass"]
opaque beginSwapchainPass (r g b a : Float) : IO Unit

@[extern "lean_sg_end_pass"]
opaque endPass : IO Unit

@[extern "lean_sg_commit"]
opaque commit : IO Unit

@[extern "lean_sg_apply_pipeline"]
private opaque applyPipelineId (id : UInt32) : IO Unit

def applyPipeline (p : Pipeline) : IO Unit :=
  applyPipelineId p.id

@[extern "lean_sg_apply_bindings"]
private opaque applyBindingsIds (vbufs : @& Array UInt32) (ibuf : UInt32) : IO Unit

def applyBindings (vertexBuffers : Array Buffer) (indexBuffer : Buffer := ⟨0⟩) : IO Unit :=
  applyBindingsIds (vertexBuffers.map (·.id)) indexBuffer.id

@[extern "lean_sg_apply_uniforms"]
opaque applyUniforms (slot : UInt32) (data : @& ByteArray) : IO Unit

@[extern "lean_sg_draw"]
opaque draw (baseElement numElements numInstances : UInt32) : IO Unit

@[extern "lean_sg_apply_viewport"]
opaque applyViewport (x y w h : UInt32) (originTopLeft : Bool) : IO Unit

end Sokol.FFI.Gfx
