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
  version = "0.9";

  # FATAL we need to keep a git repo
  src = fetchFromGitHub {
    owner = "intel";
    repo = "mptcpd";
    rev = "v${version}";
    sha256 = "sha256-L//Hh6W9vSxlokDwOsNIwH0UDCXMiQ3zMF1UUc+IZT4=";
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
