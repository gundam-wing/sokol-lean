{
  description = "Sokol bindings for Lean 4";

  inputs = {
    nixpkgs.follows = "lean4-nix/nixpkgs";
    lean4-nix.url = "github:lenianiva/lean4-nix/e04ca093bca4c944f587c5e306cb5ff0c2c6ea87";
  };

  outputs = {
    self,
    nixpkgs,
    lean4-nix,
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    eachSystem = nixpkgs.lib.genAttrs systems;
    pkgsFor = system:
      import nixpkgs {
        inherit system;
        overlays = [(lean4-nix.readToolchainFile ./lean-toolchain)];
      };
    nativeDeps = pkgs:
      with pkgs;
        [pkg-config]
        ++ lib.optionals stdenv.isLinux [
          libGL
          xorg.libX11
          xorg.libXi
          xorg.libXcursor
        ];
  in {
    packages = eachSystem (system: {
      lean = (pkgsFor system).lean.lean-all;
    });

    devShells = eachSystem (system: let
      pkgs = pkgsFor system;
      libs = nativeDeps pkgs;
      libdir = pkgs.lib.makeLibraryPath libs;
    in {
      default = pkgs.mkShell {
        packages = [pkgs.lean.lean-all] ++ libs;
        SOKOL_LEAN_LIBDIR = libdir;
        shellHook = ''
          echo "sokol-lean: $(lean --version)"
          echo "native libs: lake -Klibdir=\$SOKOL_LEAN_LIBDIR build"
        '';
      };
    });
  };
}
