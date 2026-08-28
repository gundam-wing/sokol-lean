import Sokol

open Sokol

def main : IO Unit :=
  App.run {
    title := "sokol-lean clear"
    init := Gfx.setup
    frame := Gfx.withClearPass (Gfx.Color.rgb 0.12 0.18 0.28) (pure ())
    cleanup := Gfx.shutdown
  }
