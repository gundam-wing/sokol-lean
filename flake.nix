{
  description = "Sokol bindings for Lean 4";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    eachSystem = nixpkgs.lib.genAttrs systems;
  in {
    devShells = eachSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      libs = with pkgs;
        lib.optionals stdenv.hostPlatform.isLinux [
          libGL
          xorg.libX11
          xorg.libXi
          xorg.libXcursor
        ];
    in {
      default = pkgs.mkShell {
        packages = [pkgs.elan pkgs.pkg-config] ++ libs;
        SOKOL_LEAN_LIBDIR = pkgs.lib.makeLibraryPath libs;
        shellHook = ''
          # AppKit windows only work if Lean `main` stays on the process main thread.
          export LEAN_MAIN_USE_THREAD=0
          echo "sokol-lean: $(lean --version)"
        '';
      };
    });
  };
}
