{
  username,
  sshkeys,
  ...
}: {
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = ["wheel" "video" "audio" "vboxusers" "docker" "fuse" "adbusers" "networkmanager"];
    useDefaultShell = true;
    openssh.authorizedKeys.keys = sshkeys;
  };
}
