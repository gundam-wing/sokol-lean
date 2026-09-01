namespace Sokol.FFI

/-!
Thin FFI types that match Sokol C enums and resource ids.

Values are the C enumerators. The opinionated `Sokol.Gfx` / `Sokol.App`
layers add names, defaults, and helpers on top of these.
-/

structure Buffer where
  id : UInt32
deriving Inhabited, Repr, BEq

structure Image where
  id : UInt32
deriving Inhabited, Repr, BEq

structure Shader where
  id : UInt32
deriving Inhabited, Repr, BEq

structure Pipeline where
  id : UInt32
deriving Inhabited, Repr, BEq

structure Sampler where
  id : UInt32
deriving Inhabited, Repr, BEq

structure View where
  id : UInt32
deriving Inhabited, Repr, BEq

/-- `sg_backend` -/
structure Backend where
  val : UInt32
deriving Inhabited, Repr, BEq

namespace Backend
def glcore : Backend := ⟨0⟩
def gles3 : Backend := ⟨1⟩
def d3d11 : Backend := ⟨2⟩
def metalIos : Backend := ⟨3⟩
def metalMacos : Backend := ⟨4⟩
def metalSimulator : Backend := ⟨5⟩
def wgpu : Backend := ⟨6⟩
def vulkan : Backend := ⟨7⟩
def dummy : Backend := ⟨8⟩
end Backend

/-- `sg_vertex_format` -/
structure VertexFormat where
  val : UInt32
deriving Inhabited, Repr, BEq

namespace VertexFormat
def invalid : VertexFormat := ⟨0⟩
def float : VertexFormat := ⟨1⟩
def float2 : VertexFormat := ⟨2⟩
def float3 : VertexFormat := ⟨3⟩
def float4 : VertexFormat := ⟨4⟩
def int : VertexFormat := ⟨5⟩
def int2 : VertexFormat := ⟨6⟩
def int3 : VertexFormat := ⟨7⟩
def int4 : VertexFormat := ⟨8⟩
def uint : VertexFormat := ⟨9⟩
def uint2 : VertexFormat := ⟨10⟩
def uint3 : VertexFormat := ⟨11⟩
def uint4 : VertexFormat := ⟨12⟩
def byte4 : VertexFormat := ⟨13⟩
def byte4n : VertexFormat := ⟨14⟩
def ubyte4 : VertexFormat := ⟨15⟩
def ubyte4n : VertexFormat := ⟨16⟩
def short2 : VertexFormat := ⟨17⟩
def short2n : VertexFormat := ⟨18⟩
def ushort2 : VertexFormat := ⟨19⟩
def ushort2n : VertexFormat := ⟨20⟩
def short4 : VertexFormat := ⟨21⟩
def short4n : VertexFormat := ⟨22⟩
def ushort4 : VertexFormat := ⟨23⟩
def ushort4n : VertexFormat := ⟨24⟩
def half2 : VertexFormat := ⟨25⟩
def half4 : VertexFormat := ⟨26⟩
end VertexFormat

/-- `sg_primitive_type` (`0` is C default / zero-init) -/
structure PrimitiveType where
  val : UInt32
deriving Inhabited, Repr, BEq

namespace PrimitiveType
def default : PrimitiveType := ⟨0⟩
def points : PrimitiveType := ⟨1⟩
def lines : PrimitiveType := ⟨2⟩
def lineStrip : PrimitiveType := ⟨3⟩
def triangles : PrimitiveType := ⟨4⟩
def triangleStrip : PrimitiveType := ⟨5⟩
end PrimitiveType

/-- `sg_index_type` (`0` is C default / zero-init) -/
structure IndexType where
  val : UInt32
deriving Inhabited, Repr, BEq

namespace IndexType
def default : IndexType := ⟨0⟩
def none : IndexType := ⟨1⟩
def uint16 : IndexType := ⟨2⟩
def uint32 : IndexType := ⟨3⟩
end IndexType

/-- `sg_resource_state` -/
structure ResourceState where
  val : UInt32
deriving Inhabited, Repr, BEq

namespace ResourceState
def initial : ResourceState := ⟨0⟩
def alloc : ResourceState := ⟨1⟩
def unsealed : ResourceState := ⟨2⟩
def valid : ResourceState := ⟨3⟩
def failed : ResourceState := ⟨4⟩
def invalid : ResourceState := ⟨5⟩
end ResourceState

/-- Transient `sapp_event*`. Valid only during the event callback. -/
abbrev EventPtr := USize

/-- `sapp_event_type` -/
structure EventType where
  val : UInt32
deriving Inhabited, Repr, BEq

namespace EventType
def invalid : EventType := ⟨0⟩
def keyDown : EventType := ⟨1⟩
def keyUp : EventType := ⟨2⟩
def char : EventType := ⟨3⟩
def mouseDown : EventType := ⟨4⟩
def mouseUp : EventType := ⟨5⟩
def mouseScroll : EventType := ⟨6⟩
def mouseMove : EventType := ⟨7⟩
def mouseEnter : EventType := ⟨8⟩
def mouseLeave : EventType := ⟨9⟩
def touchesBegan : EventType := ⟨10⟩
def touchesMoved : EventType := ⟨11⟩
def touchesEnded : EventType := ⟨12⟩
def touchesCancelled : EventType := ⟨13⟩
def resized : EventType := ⟨14⟩
def iconified : EventType := ⟨15⟩
def restored : EventType := ⟨16⟩
def focused : EventType := ⟨17⟩
def unfocused : EventType := ⟨18⟩
def suspended : EventType := ⟨19⟩
def resumed : EventType := ⟨20⟩
def quitRequested : EventType := ⟨21⟩
def clipboardPasted : EventType := ⟨22⟩
def filesDropped : EventType := ⟨23⟩
end EventType

/-- `sapp_keycode` (subset; other keys are raw `UInt32` values) -/
structure Keycode where
  val : UInt32
deriving Inhabited, Repr, BEq

namespace Keycode
def invalid : Keycode := ⟨0⟩
def space : Keycode := ⟨32⟩
def escape : Keycode := ⟨256⟩
def enter : Keycode := ⟨257⟩
def tab : Keycode := ⟨258⟩
def backspace : Keycode := ⟨259⟩
def insert : Keycode := ⟨260⟩
def delete : Keycode := ⟨261⟩
def right : Keycode := ⟨262⟩
def left : Keycode := ⟨263⟩
def down : Keycode := ⟨264⟩
def up : Keycode := ⟨265⟩
end Keycode

/-- `sapp_mousebutton` -/
structure MouseButton where
  val : UInt32
deriving Inhabited, Repr, BEq

namespace MouseButton
def left : MouseButton := ⟨0⟩
def right : MouseButton := ⟨1⟩
def middle : MouseButton := ⟨2⟩
def invalid : MouseButton := ⟨0x100⟩
end MouseButton

def modifierShift : UInt32 := 0x1
def modifierCtrl : UInt32 := 0x2
def modifierAlt : UInt32 := 0x4
def modifierSuper : UInt32 := 0x8

end Sokol.FFI
