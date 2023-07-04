{ python3
, stdenv
, name ? "nixpkgs"
, callPackage
, nix
, writeScriptBin
}:

let
  dyalog-jupyter-kernel = callPackage ./dyalog-jupyter-kernel { };
  python = python3.withPackages (p: [ dyalog-jupyter-kernel ]);

  kernelFile = {
    display_name = "Dyalog" + (if name == "" then "" else " - ${name}");
    language = "Dyalog APL";
    argv = [
      "${python}/bin/python"
      "-m"
      "dyalog_kernel"
      "-f"
      "{connection_file}"
    ];
    logo64 = "logo-64x64.png";
  };

  kernel = stdenv.mkDerivation {
    name = "dyalog-jupyter-kernel-${name}";
    src = ./dyalog.png;
    phases = "installPhase";
    installPhase = ''
      mkdir -p $out/kernels/dyalog_${name}
      cp $src $out/kernels/dyalog_${name}/logo-64x64.png
      echo '${builtins.toJSON kernelFile}' > $out/kernels/dyalog_${name}/kernel.json
    '';
  };
in
{
  spec = kernel;
  runtimePackages = [ ];
}
