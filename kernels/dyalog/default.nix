{ stdenv
, callPackage
, python3
, name ? ""
}:

let
  dyalog-jupyter-kernel = callPackage ./dyalog-jupyter-kernel { };
  python = python3.withPackages (p: [ dyalog-jupyter-kernel ]);

  kernelName = "dyalog-kernel" + (if name == "" then "" else "-${name}");
  kernelFile = {
    display_name = "Dyalog APL" + (if name == "" then "" else " - ${name}");
    language = "apl";
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
    name = kernelName;
    phases = "installPhase";
    installPhase = ''
      mkdir -p $out/kernels/${kernelName}
      cd $out/kernels/${kernelName}
      cp ${./dyalog.png} logo-64x64.png
      cp ${dyalog-jupyter-kernel.codeMirrorConfig} kernel.js
      echo '${builtins.toJSON kernelFile}' > kernel.json
    '';
  };
in
{
  spec = kernel;
  runtimePackages = [ ];
}
