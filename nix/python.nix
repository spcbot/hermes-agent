# nix/python.nix — uv2nix virtual environment builder
{
  python311,
  lib,
  callPackage,
  stdenv,
  uv2nix,
  pyproject-nix,
  pyproject-build-systems,
}:
let
  workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = ./..; };

  overlay = workspace.mkPyprojectOverlay {
    sourcePreference = "wheel";
  };

  pythonSet =
    (callPackage pyproject-nix.build.packages {
      python = python311;
      # Raise Darwin SDK version so wheels tagged macosx_14_0+ are accepted.
      # See: https://pyproject-nix.github.io/uv2nix/platform-quirks.html
      stdenv = stdenv.override {
        targetPlatform = stdenv.targetPlatform // {
          darwinSdkVersion = "15.1";
        };
      };
    }).overrideScope
      (lib.composeManyExtensions [
        pyproject-build-systems.overlays.default
        overlay
      ]);
in
pythonSet.mkVirtualEnv "hermes-agent-env" {
  hermes-agent = [ "all" ];
}
