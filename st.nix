
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (st.overrideAttrs (oldAttrs: rec {
      src = fetchFromGitHub {
        owner = "LukeSmithxyz";
        repo = "st";
        rev = "73c034ba05101e2fc337183af1cdec5bfe318b99";
        sha256 = "sha256:1gjidvlvah5d5hmi61nxbqnmq2035c1zlrlk7vvb4vfk1vz3rs1l";
#        fetchSubmodules = true;
    };

    # Make sure you include whatever dependencies the fork needs to build properly!
    buildInputs = oldAttrs.buildInputs ++ [ harfbuzz ];

    }))
  ];
}
