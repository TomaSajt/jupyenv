{ python3
, fetchFromGitHub
}:
let
  pname = "dyalog-jupyter-kernel";
  version = "0.1";
  src = fetchFromGitHub {
    owner = "TomaSajt";
    repo = "dyalog-jupyter-kernel";
    rev = "100f446bd803dfe86a363e3af0a70ee9d488324f";
    sha256 = "nxo7AisPaqFzLQ/dSYHboV13natCK8RAnl0LMZeIZU0=";
  };
in
python3.pkgs.buildPythonPackage {
  inherit pname version src;

  doCheck = false;
  preBuild = "export HOME=$(pwd)";
  propagatedBuildInputs = with python3.pkgs; [ notebook ];

  passthru.codeMirrorConfig = src + "/dyalog-kernel/kernel.js";
}
