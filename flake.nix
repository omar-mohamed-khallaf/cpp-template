{
  description = "C++ Superbuild with flake-parts";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/25.11";
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      perSystem =
        {
          config,
          pkgs,
          system,
          ...
        }:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
              android_sdk.accept_license = true;
            };
          };
        in
        {
          # Define the development shell
          devShells.default =
            let
              buildToolsVersion = "35.0.0";
              cmdLineToolsVersion = "19.0";
              ndkVersion = "28.2.13676358";
              cmakeVersion = "3.22.1";
              androidEnv = pkgs.androidenv;
              androidComp = androidEnv.composeAndroidPackages {
                platformVersions = [
                  "35"
                  "36"
                ];
                platformToolsVersion = [ "35.0.1" ];
                buildToolsVersions = [ buildToolsVersion ];
                cmakeVersions = [ cmakeVersion ];
                includeNDK = true;
                includeSources = false;
                includeEmulator = false;
                includeSystemImages = false;
                toolsVersion = null;
                ndkVersions = [ ndkVersion ];
                cmdLineToolsVersion = [ cmdLineToolsVersion ];
              };
              androidSdk = androidComp.androidsdk;

            in
            pkgs.mkShell {
              name = "cpp-superbuild-shell";

              # Packages required at build time
              nativeBuildInputs = with pkgs; [
                bash
                cmake
                ninja
                gdb
                gcc
                clang-tools
                androidSdk
              ];

              # Libraries your app links against (host-side)
              buildInputs = with pkgs; [
                # add any nix-managed libs here if you don't build them via Superbuild
              ];

              env = {
                ANDROID_NDK_CMAKE_VERSION = cmakeVersion;
                ANDROID_HOME = "${androidComp.androidsdk}/libexec/android-sdk";
                ANDROID_SDK_ROOT = "${androidComp.androidsdk}/libexec/android-sdk";
                ANDROID_NDK_ROOT = "${androidComp.androidsdk}/libexec/android-sdk/ndk/${ndkVersion}";
              };
              shellHook = ''
                echo "❄️ Flake-parts environment loaded. G++ version: $(g++ -dumpversion)"
              '';
            };
        };
    };
}
