{ stdenv, mkDerivation, fetchFromGitHub, qmake, qttools, qttranslations, substituteAll }:

mkDerivation rec {
  pname = "gpxsee";
  version = "7.32";

  src = fetchFromGitHub {
    owner = "tumic0";
    repo = "GPXSee";
    rev = version;
    sha256 = "0mcd6zv71laykg1208vkqmaxv1v12mqq47156gb78a5ww8paa0ka";
  };

  patches = (substituteAll {
    # See https://github.com/NixOS/nixpkgs/issues/86054
    src = ./fix-qttranslations-path.diff;
    inherit qttranslations;
  });

  nativeBuildInputs = [ qmake qttools ];

  preConfigure = ''
    lrelease gpxsee.pro
  '';

  postInstall = with stdenv; lib.optionalString isDarwin ''
    mkdir -p $out/Applications
    mv GPXSee.app $out/Applications
    wrapQtApp $out/Applications/GPXSee.app/Contents/MacOS/GPXSee
  '';

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    homepage = "https://www.gpxsee.org/";
    description = "GPS log file viewer and analyzer";
    longDescription = ''
      GPXSee is a Qt-based GPS log file viewer and analyzer that supports
      all common GPS log file formats.
    '';
    license = licenses.gpl3;
    maintainers = with maintainers; [ womfoo sikmir ];
    platforms = with platforms; linux ++ darwin;
  };
}
