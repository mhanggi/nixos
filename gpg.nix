{ config, pkgs, ... }:

{
   services.pcscd.enable = true;
   programs.gnupg.agent.enable = true;
   programs.gnupg.agent.pinentryFlavor = "curses";
   environment.systemPackages = with pkgs; [
     gnupg
   ];

}

