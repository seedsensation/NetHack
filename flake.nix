{
  description = "NetHack Flake for DGameLaunch";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = 
  { self, nixpkgs }:
  let
    allSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    forAllSystems =
      f: nixpkgs.lib.genAttrs allSystems (
        system:
        f {
          pkgs = import nixpkgs { inherit system; };
        }
      );
    lua = fetchTarball {
      name = "lua";
      url = "https://lua.org/ftp/lua-5.4.8.tar.gz";
      sha256 = "0arbxyn1s8kc6795mkypyj9gf0cd3l5bz88ckxpnppc3kmb2qcz9";
    };
  in 
  {

    packages = forAllSystems (
      { pkgs }:
      {
        default =
          let
            binName = "NetHack For DGameLaunch";
            dependencies = with pkgs; [
              gcc
              gnumake
              git
              groff
              curl
              flex
              linuxHeaders
              ncurses
            ];
          in
          pkgs.stdenv.mkDerivation {
            name = "NetHack";
            srcs = [self lua];
            sourceRoot = ".";
            postPatch = ''
              rm -rf source/lib/lua-5.4.8
              mkdir source/lib
              mv lua source/lib/lua-5.4.8
              cd source
            '';
            buildInputs = dependencies;
            buildPhase = ''
              cd sys/unix
              sh setup.sh hints/dgamelaunch
              cd ../../
              make all
            '';
            installPhase = ''
              make install
            '';
          };
      }
    );
  };
}
