{
  description = "Minecraft launchers for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        prismlauncher = pkgs.prismlauncher;
        hmcl = pkgs.hmcl;
        jdk = pkgs.jdk21;
        hmclLibDir = "${hmcl}/lib/hmcl";
        hmclRuntimeLibs = [
          pkgs.libglvnd
          pkgs.glib
          pkgs.openal-soft
          pkgs.vulkan-loader
          pkgs.libx11
          pkgs.libxxf86vm
          pkgs.libxext
          pkgs.libxcursor
          pkgs.libxrandr
          pkgs.libxtst
          pkgs.libpulseaudio
          pkgs.wayland
          pkgs.alsa-lib
          pkgs.gtk3
        ];
        hmclLdLibraryPath = pkgs.lib.makeLibraryPath hmclRuntimeLibs;

        minecraftEnv = pkgs.writeShellApplication {
          name = "minecraft-env";
          runtimeInputs = [ prismlauncher hmcl jdk pkgs.mesa-demos pkgs.vulkan-tools ];
          text = ''
            cat <<'EOF'
            Available launchers:
              hmcl
              prismlauncher

            Java:
              ${jdk}/bin/java

            Useful debug commands:
              glxinfo -B
              vulkaninfo --summary
            EOF
          '';
        };

        hmclClean = pkgs.writeShellApplication {
          name = "hmcl";
          runtimeInputs = [ jdk ];
          text = ''
            unset JAVA_TOOL_OPTIONS
            export LD_LIBRARY_PATH="${hmclLdLibraryPath}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
            exec ${jdk}/bin/java -Djdk.gtk.version=3 -jar ${hmclLibDir}/hmcl-terracotta-patch.jar "$@"
          '';
        };

        prismlauncherClean = pkgs.writeShellScript "prismlauncher-clean" ''
          unset JAVA_TOOL_OPTIONS
          exec ${prismlauncher}/bin/prismlauncher "$@"
        '';
      in {
        packages = {
          default = hmclClean;
          inherit prismlauncher hmcl jdk minecraftEnv hmclClean prismlauncherClean;
        };

        apps = {
          default = {
            type = "app";
            program = "${hmclClean}/bin/hmcl";
          };

          prismlauncher = {
            type = "app";
            program = "${prismlauncher}/bin/prismlauncher";
          };

          hmcl = {
            type = "app";
            program = "${hmclClean}/bin/hmcl";
          };

          prismlauncher-clean = {
            type = "app";
            program = "${prismlauncherClean}";
          };

          hmcl-clean = {
            type = "app";
            program = "${hmclClean}/bin/hmcl";
          };

          minecraft-env = {
            type = "app";
            program = "${minecraftEnv}/bin/minecraft-env";
          };
        };

        devShells.default = pkgs.mkShell {
          packages = [ jdk pkgs.mesa-demos pkgs.vulkan-tools hmclClean ] ++ hmclRuntimeLibs;

          shellHook = ''
            unset JAVA_TOOL_OPTIONS
            export LD_LIBRARY_PATH="${hmclLdLibraryPath}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
          '';
        };
      });
}
