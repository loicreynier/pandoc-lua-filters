{
  lib,
  stdenv,
}:
stdenv.mkDerivation rec {
  pname = "pandoc-lua-filters-lor";
  version = "22.08.01";

  src = ./.;

  dontBuild = true;

  installPhase = ''
    install -Dt $out/share/pandoc/filters **/*.lua
  '';

  meta = with lib; {
    homepage = "https://github.com/loicreynier/pandoc-lua-filters";
    description = "Personal collection of Pandoc Lua filters";
    license = licenses.unlicense;
    maintainers = with maintainers; [loicreynier];
  };
}
