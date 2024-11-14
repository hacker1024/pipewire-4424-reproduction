{ config, pkgs, ... }:

{
  users.users.root.password = "root";
  services.getty.autologinUser = config.users.users.root.name;
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      X11Forwarding = true;
    };
  };

  environment.systemPackages = with pkgs; [ alsa-utils qpwgraph audacity ];

  services.pipewire = {
    enable = true;
    systemWide = true;
    audio.enable = true;
    alsa.enable = true;
    pulse.enable = true;
    extraConfig.pipewire = {
      "99-custom"."context.properties"."default.clock.rate" = 48000;
      "99-cancellation"."context.modules" = [{
        name = "libpipewire-module-echo-cancel";
        args = {
          "library.name" = "aec/libspa-aec-webrtc";
          "audio.channels" = 1;
          "monitor.mode" = true;
          "sink.props"."node.description" = "Echo cancellation loopback";
          "capture.props" = {
            "node.description" = "Echo cancellation capture";
            "node.passive" = true;
          };
          "source.props" = {
            "node.description" = "Echo cancellation source";
            "priority.session" = 2000;
          };
        };
      }];
    };
  };

  virtualisation.vmVariant = { config, lib, ... }: {
    virtualisation = {
      forwardPorts = (lib.mkIf config.services.openssh.enable (map
        (port: rec {
          from = "host";
          guest.port = port;
          host.port = 2000 + guest.port; # e.g. 22 -> 2022
        })
        config.services.openssh.ports));

      qemu.options = [
        # https://www.qemu.org/docs/master/system/devices/virtio-snd.html
        "-device virtio-sound-pci,audiodev=SoundCard"
        "-audiodev alsa,id=SoundCard"
      ];
    };

    services.pipewire.wireplumber.extraConfig."99-custom" = {
      "wireplumber.settings"."device.routes.default-sink-volume" = 1.0;
      "monitor.alsa.rules" = [
        {
          matches = [{
            "alsa.card" = "0";
            "api.alsa.pcm.stream" = "playback";
          }];
          actions.update-props = {
            "audio.format" = "S16LE";
            "audio.rate" = 48000;
          };
        }
        {
          matches = [{
            "alsa.card" = "0";
            "api.alsa.pcm.stream" = "capture";
          }];
          actions.update-props = {
            "audio.format" = "S16LE";
            "audio.rate" = 16000;
          };
        }
      ];
    };
  };
}
