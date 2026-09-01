namespace Sokol.FFI.Time

@[extern "lean_stm_setup"]
opaque setup : IO Unit

@[extern "lean_stm_now"]
opaque now : IO UInt64

@[extern "lean_stm_sec"]
opaque sec (ticks : UInt64) : Float

@[extern "lean_stm_ms"]
opaque ms (ticks : UInt64) : Float

@[extern "lean_stm_diff"]
opaque diff (newTicks oldTicks : UInt64) : IO UInt64

@[extern "lean_stm_since"]
opaque since (start : UInt64) : IO UInt64

end Sokol.FFI.Time
