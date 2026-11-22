{
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;

    # Micro traité par EasyEffects (easyeffects_source) -> strip VeeMeeter
    # "Micro Sortie EasyEffect" (vi3), routée ensuite sur "Micro Clean" (b1).
    extraConfig.pipewire."90-easyeffects-mic-to-veemeeter" = {
      "context.modules" = [
        {
          name = "libpipewire-module-loopback";
          args = {
            "node.description" = "EasyEffects -> VeeMeeter";
            "capture.props" = {
              "node.name" = "ee_to_veemeeter.capture";
              "target.object" = "easyeffects_source";
            };
            "playback.props" = {
              "node.name" = "ee_to_veemeeter.playback";
              "target.object" = "veemeeter.vi3";
            };
          };
        }
      ];
    };
  };
}
