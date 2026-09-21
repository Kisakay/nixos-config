{ config, pkgs, lib, ... }:

{
  services.ollama = {
    enable = true;

    package = pkgs.ollama-vulkan;

    loadModels = [
      "qwen3:8b"
    ];
  };

  systemd.services.ollama.environment.OLLAMA_HOST =
    lib.mkForce "0.0.0.0:11434";

  environment.systemPackages = with pkgs; [
    llama-cpp-vulkan
  ];
}
