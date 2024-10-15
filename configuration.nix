# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # enable bluetooth
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;
  hardware.enableRedistributableFirmware = true; # this is to fix the bad mix of wifi and bluetooth

  # needed drivers for opengl and intel ( mainly for hardware acceleration on firefox )
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs;[  
      mesa
      intel-media-driver 
      # intel-ocl 
      intel-vaapi-driver
      libvdpau-va-gl
      # vaapi-intel-hybrid
      # libva-vdpau-driver
    ]; 
  };


  # environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; }; # Force intel-media-driver
  #  boot.blacklistedKernelModules = [ "nouveau" ];
  

  # nvidia drivers
  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false; ## try this later

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false; ## change this to false if I finde buggy behaviour from the drivers

    # Enable the Nvidia settings menu,
	  # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # laptop configuration
  hardware.nvidia.prime = {
    # choose one of the two options only
    # thers is another option c, but it's experimental, go to the wiki.
		# Option A : offloading
    # offload = {
		# 	enable = true;
		# 	enableOffloadCmd = true;
		# };
    # Option B : sync
    sync.enable = true;

		# Make sure to use the correct Bus ID values for your system!
		intelBusId = "PCI:0:2:0";
		nvidiaBusId = "PCI:1:0:0";
	};



  # end of nvidia drivers

  # enable and default zsh
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # sets the kernel to the latest kernel available 
  # comment it to use the "lts" version
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Jerusalem";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  programs.hyprland.enable = true; # enable Hyprland

  services = {
    xserver = {
      enable = true;
      videoDrivers = [ "i915" "nouveau"]; # replace i915 with nvidia, for nvidia #"nvidia" "nvidia_drm" "nvidia_modeset" 
    };
    desktopManager.plasma6.enable = true;
    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };
  };
  # boot.kernelParams = [ "module_blacklist=i915" ]; # blacklist i915 for nvidia ## don't use this unlees ablsolutely necessary

  ## disable nvidia card completely
  # boot.extraModprobeConfig = ''
  #   blacklist nouveau
  #   options nouveau modeset=0
  # '';   
  # services.udev.extraRules = ''
  #   # Remove NVIDIA USB xHCI Host Controller devices, if present
  #   ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"
  #   # Remove NVIDIA USB Type-C UCSI devices, if present
  #   ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"
  #   # Remove NVIDIA Audio devices, if present
  #   ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"
  #   # Remove NVIDIA VGA/3D controller devices
  #   ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
  # '';
  # boot.blacklistedKernelModules = [ "nouveau" "nvidia" "nvidia_drm" "nvidia_modeset" ];

  ## spcial boot configuration for nvidia drivers, ( can add more options and more configurations )
  specialisation = {
    nvidia.configuration = {
      system.nixos.tags = [ "nvidia" ];
      services.xserver.videoDrivers = [ "i915" "nvidia" "nvidia_drm" "nvidia_modeset" ];
    };
  };

  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  # Using the following example configuration, QT applications will have a look similar to the GNOME desktop, using a dark theme. 
  # qt = {
  #   enable = true;
  #   platformTheme = "gnome";
  #   style = "adwaita-dark";
  # };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = false;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false; # switch to it if a flatpak app is lagging
  security.rtkit.enable = true; # this one is the default
  security.polkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = false;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    # media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # this seems to help with the touchpad lag
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.karemkassem = {
    isNormalUser = true;
    description = "karemkassem";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # to allow connections with ios
  # services.usbmuxd.enable = true;

  # # xdg portal configuration
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-kde
      xdg-desktop-portal-hyprland
    ];
    wlr = {
      enable = true;
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    
    ## system packages 
    vulkan-loader
    vulkan-tools
    vulkan-validation-layers
    mesa-demos
    pwvucontrol
    # toybox # if I find no glitches after commenting it delete it completely
    # libimobiledevice # to connect with ios
    ## packages for hyprland
    lxqt.lxqt-policykit
    rofi-wayland
    dunst
    libnotify # for dunst
    networkmanagerapplet
    hyprpaper
    waybar

    ## terminal applications
    kitty
    alacritty
    neovim
    vim
    btop
    bat
    ranger
    
    ## gnome applications
    # gnome-tweaks
    resources
    mission-center

    ## applications 
    obsidian
    vesktop
    spotify
    (chromium.override {
      commandLineArgs = [
        "--enable-features=VaapiVideoDecodeLinuxGL"
        # "--ignore-gpu-blocklist"
        # "--enable-zero-copy"
        # "--ozone-platform-hint=auto"
      ];
    })
    zoom-us

    ## coding
    gcc
    python3
    git
    vscode
    zed-editor

  ];
  
  # enviromental variable that chooses the vulkan driver.
  # uncomment to use the intel drivers, if needed replace "intel" with "nvidia" to use nvidia drivers 
  # comment this to use nvidia drivers
  environment.variables.VK_DRIVER_FILES=/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json;
  ## Note: use DRI_PRIME=1 <application> if you want to run vulkan applications on nvidia

  # for electron wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # enable flatpak
  services.flatpak.enable = true;
  
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
