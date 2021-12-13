{ stdenv
, lib
, linux
, libtool
, fetchFromGitHub
, pkgconfig
, autoreconfHook
, ell
, check
, openssl # for libcrypto
, libpcap
, doxygen
, pandoc
, autoconf-archive
}:

stdenv.mkDerivation rec {
  name = "mptcpd";
  # version = "v0.8";
  version = "unstable";

  # FATAL we need to keep a git repo
  src = fetchFromGitHub {
    owner = "intel";
    repo = "mptcpd";
    rev = "504e8c59a55b5d813b6c568c5cbc2e529ff00cc8";
    sha256 = "sha256-JiS9Y7cw8N7MLOI6kImZ/KOyNaZl431sUjOpUDmXyhE=";
  };

  preConfigure = ''
    ./bootstrap
  '';

  nativeBuildInputs = [
    autoreconfHook
    autoconf-archive
    pkgconfig
    # check
    ell # embedded linux library !
    linux.dev # for mptcp.h
    libtool
    openssl
    libpcap
    doxygen
    pandoc
  ];

  meta = with lib; {

    homepage = "https://github.com/github/mptcpd";
    description = "a daemon for Linux based operating systems that performs multipath TCP path management related operations in the user space";
    platforms = platforms.unix;
    license = licenses.bsd3;
  };
}
