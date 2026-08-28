import Lake
open System Lake DSL

def backend : String := (get_config? backend).getD "auto"

/-- Graphics backend for `sokol_gfx.h`. -/
def gfxBackendMacro : String :=
  match backend with
  | "dummy" => "SOKOL_DUMMY_BACKEND"
  | "glcore" => "SOKOL_GLCORE"
  | "metal" => "SOKOL_METAL"
  | "d3d11" => "SOKOL_D3D11"
  | "gles3" => "SOKOL_GLES3"
  | "auto" =>
    if Platform.isWindows then "SOKOL_D3D11"
    else if Platform.isOSX then "SOKOL_METAL"
    else "SOKOL_GLCORE"
  | other => panic! s!"unknown backend `{other}` (use auto|dummy|glcore|metal|d3d11|gles3)"

/--
`sokol_app.h` on Linux cannot be built with `SOKOL_NOAPI` / dummy.
Keep a real window-system backend even when gfx is dummy.
-/
def appBackendMacro : String :=
  if gfxBackendMacro == "SOKOL_DUMMY_BACKEND" then
    if Platform.isWindows then "SOKOL_D3D11"
    else if Platform.isOSX then "SOKOL_METAL"
    else "SOKOL_GLCORE"
  else gfxBackendMacro

def linuxLibs : Array String :=
  match get_config? libdir with
  | some dir =>
    ((dir.splitOn ":").filter (· ≠ "") |>.map (("-L" ++ ·))).toArray ++
      #["-lGL", "-lX11", "-lXi", "-lXcursor", "-lm", "-ldl", "-lpthread"]
  | none =>
    let d :=
      if Platform.target.startsWith "aarch64" then "/usr/lib/aarch64-linux-gnu"
      else "/usr/lib/x86_64-linux-gnu"
    -- Absolute `.so` paths avoid `-L/usr/lib`, which would shadow Lean's sysroot libc.
    #[s!"{d}/libGL.so", s!"{d}/libX11.so", s!"{d}/libXi.so", s!"{d}/libXcursor.so",
      "-lm", "-ldl", "-lpthread"]

def linkArgs : Array String :=
  if Platform.isWindows then
    #[]
  else if Platform.isOSX then
    #["-framework", "Cocoa", "-framework", "QuartzCore",
      "-framework", "Metal", "-framework", "MetalKit"]
  else
    linuxLibs

def commonTraceArgs : Array String :=
  #["-fPIC", "-O2"]

def objcArgs : Array String :=
  if Platform.isOSX then #["-x", "objective-c"] else #[]

package «sokol» where
  testDriver := "dummyTest"
  moreLinkArgs := linkArgs

def nativeWeakArgs (pkg : Package) : Array String :=
  #["-I", (pkg.dir / "vendor" / "sokol").toString]

target sokolGfxO pkg : FilePath := do
  let srcJob ← inputTextFile (pkg.dir / "native" / "sokol_gfx_impl.c")
  let oFile := pkg.buildDir / "native" / "sokol_gfx_impl.o"
  buildO oFile srcJob (nativeWeakArgs pkg)
    (commonTraceArgs ++ #[s!"-D{gfxBackendMacro}"] ++ objcArgs)

target sokolAppO pkg : FilePath := do
  let srcJob ← inputTextFile (pkg.dir / "native" / "sokol_app_impl.c")
  let oFile := pkg.buildDir / "native" / "sokol_app_impl.o"
  buildO oFile srcJob (nativeWeakArgs pkg)
    (commonTraceArgs ++ #["-DSOKOL_NO_ENTRY", s!"-D{appBackendMacro}"] ++ objcArgs)

target sokolFfiO pkg : FilePath := do
  let srcJob ← inputTextFile (pkg.dir / "native" / "ffi.c")
  let oFile := pkg.buildDir / "native" / "ffi.o"
  let leanInc := (← getLeanIncludeDir).toString
  buildO oFile srcJob (nativeWeakArgs pkg ++ #["-I", leanInc])
    (commonTraceArgs ++ #["-DSOKOL_NO_ENTRY", s!"-D{gfxBackendMacro}"])

@[default_target]
lean_lib Sokol where
  precompileModules := true
  moreLinkObjs := #[sokolGfxO, sokolAppO, sokolFfiO]

lean_exe clear where
  srcDir := "examples"
  root := `Clear

lean_exe triangle where
  srcDir := "examples"
  root := `Triangle

lean_exe dummyTest where
  srcDir := "tests"
  root := `DummyGfx
