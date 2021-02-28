
(self: super: {
  st = super.st.overrideAttrs (oldAttrs: {
    pname = "st-lukesmith";
    version = "1.0.0";
    src = super.fetchFromGitHub {
      owner = "LukeSmithxyz";
      repo = "st";
      rev = "73c034ba05101e2fc337183af1cdec5bfe318b99";
      sha256 = "sha256:1gjidvlvah5d5hmi61nxbqnmq2035c1zlrlk7vvb4vfk1vz3rs1l";
    };

    buildInputs = oldAttrs.buildInputs ++ (with super; [ harfbuzz ]);
  });
})
