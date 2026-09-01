import Sokol

open Sokol

def fail (msg : String) : IO Unit :=
  throw <| IO.userError msg

def main : IO Unit := do
  Gfx.setupHeadless
  unless (← Gfx.isValid) do
    fail "sg_setup failed"
  let packed := Sokol.FFI.Gfx.packF32 #[1, 2, 3]
  if packed.size != 12 then
    fail s!"packF32 size {packed.size}, expected 12"
  let buf ← Gfx.Buffer.ofFloats #[
    0.0, 0.5, 0.5, 1.0, 0.0, 0.0, 1.0,
    0.5, -0.5, 0.5, 0.0, 1.0, 0.0, 1.0,
    -0.5, -0.5, 0.5, 0.0, 0.0, 1.0, 1.0
  ]
  if buf.id == 0 then
    fail "makeBuffer returned an invalid id"
  let st ← Gfx.Buffer.state buf
  if st != Sokol.FFI.ResourceState.valid && st != Sokol.FFI.ResourceState.alloc then
    fail s!"unexpected buffer state {st.val}"
  let backend ← Gfx.backend
  IO.println s!"backend={backend.val} buffer={buf.id} packed={packed.size}"
  Sokol.FFI.Time.setup
  let t0 ← Sokol.FFI.Time.now
  let dt ← Sokol.FFI.Time.since t0
  IO.println s!"stm_since_ticks={dt}"
  Gfx.shutdown
  if (← Gfx.isValid) then
    fail "sg_shutdown left gfx valid"
  IO.println "ok"
