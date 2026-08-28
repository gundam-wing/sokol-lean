import Sokol.FFI

/-!
Opinionated application runner on top of `Sokol.FFI.App`.

Callbacks are Lean `IO` actions. Mutable frame state belongs in `IO.Ref`.
Escape requests quit by default.
-/

namespace Sokol.App
open Sokol.FFI
open Sokol.FFI.App

structure Event where
  type : EventType := EventType.invalid
  key : Keycode := Keycode.invalid
  charCode : UInt32 := 0
  keyRepeat : Bool := false
  modifiers : UInt32 := 0
  mouseButton : MouseButton := MouseButton.invalid
  mouseX : Float := 0
  mouseY : Float := 0
  mouseDx : Float := 0
  mouseDy : Float := 0
  scrollX : Float := 0
  scrollY : Float := 0
  windowWidth : UInt32 := 0
  windowHeight : UInt32 := 0
  frameCount : UInt64 := 0
deriving Repr, Inhabited

/-- Copy a transient FFI event pointer into an owned Lean record. -/
def Event.ofPtr (p : EventPtr) : Event :=
  { type := ⟨eventType p⟩
    key := ⟨eventKeycode p⟩
    charCode := eventCharCode p
    keyRepeat := eventKeyRepeat p
    modifiers := eventModifiers p
    mouseButton := ⟨eventMouseButton p⟩
    mouseX := eventMouseX p
    mouseY := eventMouseY p
    mouseDx := eventMouseDx p
    mouseDy := eventMouseDy p
    scrollX := eventScrollX p
    scrollY := eventScrollY p
    windowWidth := eventWindowWidth p
    windowHeight := eventWindowHeight p
    frameCount := eventFrameCount p }

structure Config where
  width : UInt32 := 640
  height : UInt32 := 480
  sampleCount : UInt32 := 1
  highDpi : Bool := true
  title : String := "sokol-lean"
  quitOnEscape : Bool := true
  init : IO Unit := pure ()
  frame : IO Unit := pure ()
  cleanup : IO Unit := pure ()
  event : Event → IO Unit := fun _ => pure ()

def width : IO UInt32 := FFI.App.width
def height : IO UInt32 := FFI.App.height
def widthf : IO Float := FFI.App.widthf
def heightf : IO Float := FFI.App.heightf
def dpiScale : IO Float := FFI.App.dpiScale
def frameCount : IO UInt64 := FFI.App.frameCount
def frameDuration : IO Float := FFI.App.frameDuration
def requestQuit : IO Unit := FFI.App.requestQuit
def quit : IO Unit := FFI.App.quit
def setWindowTitle (title : String) : IO Unit := FFI.App.setWindowTitle title

/-- Take over the process with a Sokol window. Do not put code after this call. -/
def run (cfg : Config) : IO Unit :=
  FFI.App.run cfg.width cfg.height cfg.sampleCount cfg.highDpi cfg.title
    cfg.init cfg.frame cfg.cleanup
    (fun ptr => do
      let ev := Event.ofPtr ptr
      if cfg.quitOnEscape && ev.type == EventType.keyDown && ev.key == Keycode.escape then
        requestQuit
      else
        cfg.event ev)

end Sokol.App
