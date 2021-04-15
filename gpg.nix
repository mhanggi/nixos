{ config, pkgs, ... }:

{
   services.pcscd.enable = true;
   programs.gnupg.agent.enable = true;
   programs.gnupg.agent.pinentryFlavor = "curses";
   programs.gnupg.agent.enableSSHSupport = true;
   programs.ssh.startAgent = false;
   environment.systemPackages = with pkgs; [
     gnupg
   ];

   services.udev.packages = [ pkgs.yubikey-personalization ];
}

