import Sokol.FFI.Types
import Sokol.FFI.App
import Sokol.FFI.Gfx
import Sokol.FFI.Time

/-!
Simple FFI surface: resource ids, C enumerator values, and thin `extern`s.

This layer does not pick defaults beyond what Sokol already documents, and it
does not invent a scene graph or immediate-mode API.
-/
