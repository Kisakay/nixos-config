{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
}
