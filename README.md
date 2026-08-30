# sokol-lean

Lean 4 bindings for [Sokol](https://github.com/floooh/sokol). Two layers, no extra Lean packages.

| Layer | Module | Role |
| --- | --- | --- |
| FFI | `Sokol.FFI` | Thin `extern`s, resource ids, C enumerator values |
| Graphics | `Sokol.App`, `Sokol.Gfx` | Defaults, `IO` callbacks, f32 packing, pass helpers |

Sokol itself is vendored (header-only, zlib). The Nix flake provides [elan](https://github.com/leanprover/elan) (which installs the Lean in `lean-toolchain`) plus Linux window/GL libraries.

## Requirements

- A C compiler (the Lean toolchain's `cc` is enough)
- On Linux: X11 + GL (`libX11`, `libXi`, `libXcursor`, `libGL`)
- On macOS: Cocoa / QuartzCore / Metal (linked automatically)

```sh
nix develop          # elan + lake/lean from lean-toolchain
lake build
lake exe triangle    # opens a window titled "sokol-lean triangle"; Escape quits
lake -Kbackend=dummy test
```

`lake build triangle` only compiles. Run the binary (`lake exe triangle` or `.lake/build/bin/triangle`) to get a window. On macOS it may open behind the terminal; check the Dock for `triangle`. The flake sets `LEAN_MAIN_USE_THREAD=0` so Sokol can create a Cocoa window (Lean otherwise runs `main` off the process main thread).

Without Nix, install elan yourself, then run the same `lake` commands. On Linux, pass `-Klibdir="$SOKOL_LEAN_LIBDIR"` if you need Nix-provided GL/X11.

On Nix, `-Klibdir` is the search path for `libGL` / `libX11` (do not pass `/usr/lib`; that can shadow Lean's sysroot libc). The flake `devShell` sets `SOKOL_LEAN_LIBDIR`.

## Backend

Sokol selects a 3D API at C compile time. Pass `-Kbackend=...`:

| Value | Define |
| --- | --- |
| `auto` (default) | `SOKOL_GLCORE` / `SOKOL_METAL` / `SOKOL_D3D11` |
| `dummy` | `SOKOL_DUMMY_BACKEND` for gfx (no GPU; for tests). Window code still uses the platform 3D API because `sokol_app` has no dummy backend on Linux. |
| `glcore` / `metal` / `d3d11` / `gles3` | that backend |

Rebuild after changing the backend (`lake clean` if object files were built for a different one). `-K` is a Lake *global* option, so it goes before the subcommand:

```sh
lake -Kbackend=dummy build dummyTest
lake -Kbackend=dummy test
```

## Usage

```lean
import Sokol

open Sokol

def main : IO Unit :=
  App.run {
    title := "hello"
    init := Gfx.setup
    frame := Gfx.withClearPass (Gfx.Color.rgb 0.12 0.18 0.28) (pure ())
    cleanup := Gfx.shutdown
  }
```

Keep per-frame GPU handles in an `IO.Ref`. See `examples/Triangle.lean`.

Shaders are backend source strings (GLSL 410 for `glcore`). This repo does not depend on `sokol-shdc`.

## Layout

```
Sokol/FFI/     -- simple FFI
Sokol/App.lean -- opinionated window + input
Sokol/Gfx.lean -- opinionated gfx helpers
native/        -- Sokol implementation + C shims
vendor/sokol/  -- upstream headers
```
