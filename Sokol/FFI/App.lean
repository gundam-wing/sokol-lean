import Sokol.FFI.Types

namespace Sokol.FFI.App
open Sokol.FFI

/-- `sapp_run`. Does not return on some platforms until the app quits. -/
@[extern "lean_sapp_run"]
opaque run
    (width height sampleCount : UInt32) (highDpi : Bool) (title : @& String)
    (init frame cleanup : @& IO Unit) (onEvent : @& (EventPtr → IO Unit)) :
    IO Unit

@[extern "lean_sapp_isvalid"]
opaque isValid : IO Bool

@[extern "lean_sapp_width"]
opaque width : IO UInt32

@[extern "lean_sapp_height"]
opaque height : IO UInt32

@[extern "lean_sapp_widthf"]
opaque widthf : IO Float

@[extern "lean_sapp_heightf"]
opaque heightf : IO Float

@[extern "lean_sapp_dpi_scale"]
opaque dpiScale : IO Float

@[extern "lean_sapp_frame_count"]
opaque frameCount : IO UInt64

@[extern "lean_sapp_frame_duration"]
opaque frameDuration : IO Float

@[extern "lean_sapp_request_quit"]
opaque requestQuit : IO Unit

@[extern "lean_sapp_quit"]
opaque quit : IO Unit

@[extern "lean_sapp_set_window_title"]
opaque setWindowTitle (title : @& String) : IO Unit

@[extern "lean_sapp_event_type"]
opaque eventType (ev : EventPtr) : UInt32

@[extern "lean_sapp_event_keycode"]
opaque eventKeycode (ev : EventPtr) : UInt32

@[extern "lean_sapp_event_char_code"]
opaque eventCharCode (ev : EventPtr) : UInt32

@[extern "lean_sapp_event_key_repeat"]
opaque eventKeyRepeat (ev : EventPtr) : Bool

@[extern "lean_sapp_event_modifiers"]
opaque eventModifiers (ev : EventPtr) : UInt32

@[extern "lean_sapp_event_mouse_button"]
opaque eventMouseButton (ev : EventPtr) : UInt32

@[extern "lean_sapp_event_mouse_x"]
opaque eventMouseX (ev : EventPtr) : Float

@[extern "lean_sapp_event_mouse_y"]
opaque eventMouseY (ev : EventPtr) : Float

@[extern "lean_sapp_event_mouse_dx"]
opaque eventMouseDx (ev : EventPtr) : Float

@[extern "lean_sapp_event_mouse_dy"]
opaque eventMouseDy (ev : EventPtr) : Float

@[extern "lean_sapp_event_scroll_x"]
opaque eventScrollX (ev : EventPtr) : Float

@[extern "lean_sapp_event_scroll_y"]
opaque eventScrollY (ev : EventPtr) : Float

@[extern "lean_sapp_event_window_width"]
opaque eventWindowWidth (ev : EventPtr) : UInt32

@[extern "lean_sapp_event_window_height"]
opaque eventWindowHeight (ev : EventPtr) : UInt32

@[extern "lean_sapp_event_frame_count"]
opaque eventFrameCount (ev : EventPtr) : UInt64

end Sokol.FFI.App
