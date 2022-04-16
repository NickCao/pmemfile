{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let pkgs = import nixpkgs { inherit system; }; in
        rec {
          packages.default = pkgs.stdenv.mkDerivation {
            name = "pmemfile";
            src = self;
            nativeBuildInputs = with pkgs;[
              cmake
              pkg-config
              perl
              python3
            ];
            buildInputs = with pkgs;[
              libunwind
              libcap
              libndctl
              pmdk
              packages.syscall_intercept
            ];
            postPatch = ''
              ln -s ${pkgs.fetchurl {
                url = "https://github.com/google/googletest/archive/release-1.8.0.zip";
                sha256 = "sha256-8+07WFEe/ScusHSjptb7edfC5qDjdDI9HmvLzB7xQb8=";
              }} googletest-1.8.0.zip
            '';
            cmakeFlags = [
              "-DANTOOL_TESTS=SKIP"
              "-DBUILD_LIBPMEMFILE_TESTS=OFF"
              "-DBUILD_PMEMFILE_FUSE=OFF"
            ];
          };
          packages.syscall_intercept = pkgs.stdenv.mkDerivation {
            pname = "syscall_intercept";
            version = "unstable-2021-05-12";
            src = pkgs.fetchFromGitHub {
              owner = "pmem";
              repo = "syscall_intercept";
              rev = "2c8765fa292bc9c28a22624c528580d54658813d";
              sha256 = "sha256-LnanI8pDF7jr3MPAHPCMSXRSOI7bzITE4lk5JO2BdiQ=";
            };
            nativeBuildInputs = with pkgs;[
              cmake
              pkg-config
              perl
            ];
            propagatedBuildInputs = with pkgs;[
              capstone
            ];
          };
        });
}
