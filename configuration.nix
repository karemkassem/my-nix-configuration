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
    powerManagement.finegrained = false; 

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

  ## enable Hyprland
  programs.hyprland.enable = true; 

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

  # # Enable CUPS to print documents.
  # services.printing.enable = true;
  # services.avahi = {
  #   enable = true;
  #   nssmdns4 = true;
  #   openFirewall = true;
  # };

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
    extraPortals = with pkgs; [ # highly likely that all this is unnecissary in kde plasma
      xdg-desktop-portal-hyprland
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    
    ## system packages 
    vulkan-loader
    vulkan-tools
    vulkan-validation-layers
    mesa-demos
    # libimobiledevice # to connect with ios

    ## packages for hyprland
    lxqt.lxqt-policykit
    rofi-wayland
    dunst
    libnotify # for dunst
    waybar
    swww
    pwvucontrol
    cliphist
    wl-clipboard
    brightnessctl
    libsForQt5.kservice

    ## terminal applications
    kitty
    alacritty
    vim
    btop
    bat
    ranger
    neofetch

    ## applications 
    obsidian
    vesktop
    spotify
    zoom-us
    kdePackages.filelight
    kdePackages.kclock
    librewolf
    vlc
    resources

    ## chromium browsers
    (chromium.override {
      commandLineArgs = [
        "--enable-features=VaapiVideoDecodeLinuxGL"
        "--ignore-gpu-blocklist"
        "--enable-zero-copy"
      ];
    })
    (brave.override {
      commandLineArgs = [
        "--enable-features=VaapiVideoDecodeLinuxGL"
        "--ignore-gpu-blocklist"
        "--enable-zero-copy"
      ];
    })

    ## coding
    gcc
    python3
    git
    vscode
    jetbrains.pycharm-professional
    zed-editor

    # language servers and packages for zed 
    
    # tree-sitter-grammars.tree-sitter-c
    # tree-sitter-grammars.tree-sitter-markdown
    # tree-sitter-grammars.tree-sitter-python
    # tree-sitter-grammars.tree-sitter-java

    clang-tools # for clangd in c


    ## neovim and Zed

    # Language servers
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted
    pyright
    rust-analyzer
    gopls
    ccls
    jdt-language-server

    # Tools
    ripgrep
    fd

  ];

  # NeoVim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    configure = {
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [
          # File explorer
          nvim-tree-lua
          
          # Fuzzy finder
          telescope-nvim
          plenary-nvim
          
          # LSP Support
          nvim-lspconfig
          nvim-cmp
          cmp-nvim-lsp
          cmp-buffer
          cmp-path
          cmp-cmdline
          luasnip
          cmp_luasnip
          
          # Syntax highlighting
          (nvim-treesitter.withPlugins (p: with p; [
            python
            javascript
            typescript
            rust
            go
            json
            html
            css
            c
            cpp
            java
          ]))
          
          # Git integration
          gitsigns-nvim
          
          ## Themes
          tokyonight-nvim
          catppuccin-nvim
          onedark-nvim
          vscode-nvim
          gruvbox-material-nvim
          
          # Status line
          lualine-nvim
          
          # Buffer line
          bufferline-nvim
          
          # Auto pairs
          nvim-autopairs
          
          # Comments
          comment-nvim
          
          # Indent guides
          indent-blankline-nvim-lua
          
          # Which key
          which-key-nvim
        ];
      };

      customRC = ''
        lua << EOF
        -- Set leader key to space
        vim.g.mapleader = " "
        vim.g.maplocalleader = " "

        -- Basic settings
        vim.opt.number = true
        vim.opt.relativenumber = true
        vim.opt.mouse = 'a'
        vim.opt.ignorecase = true
        vim.opt.smartcase = true
        vim.opt.hlsearch = false
        vim.opt.wrap = false
        vim.opt.breakindent = true
        vim.opt.tabstop = 2
        vim.opt.shiftwidth = 2
        vim.opt.expandtab = true
        vim.opt.termguicolors = true

        -- Theme
        vim.cmd[[colorscheme vscode]]

        -- Nvim Tree
        require('nvim-tree').setup{}
        vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>')

        -- Telescope
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>ff', builtin.find_files)
        vim.keymap.set('n', '<leader>fg', builtin.live_grep)
        vim.keymap.set('n', '<leader>fb', builtin.buffers)
        vim.keymap.set('n', '<leader>fh', builtin.help_tags)

        -- LSP Configuration
        local lspconfig = require('lspconfig')
        local capabilities = require('cmp_nvim_lsp').default_capabilities()

        -- Setup language servers
        local servers = { 
          'ts_ls',
          'pyright',
          'rust_analyzer',
          'gopls',
          'ccls',
          'jdtls'
        }
        
        for _, lsp in ipairs(servers) do
          lspconfig[lsp].setup {
            capabilities = capabilities,
            on_attach = function(client, bufnr)
              -- Enable completion triggered by <c-x><c-o>
              vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

              -- Mappings
              local bufopts = { noremap=true, silent=true, buffer=bufnr }
              vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
              vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
              vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
              vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
              vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
              vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
              vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
              vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
            end,
          }
        end

        -- Completion setup
        local cmp = require('cmp')
        local luasnip = require('luasnip')

        cmp.setup({
          snippet = {
            expand = function(args)
              luasnip.lsp_expand(args.body)
            end,
          },
          mapping = cmp.mapping.preset.insert({
            ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<CR>'] = cmp.mapping.confirm({ select = true }),
            ['<Tab>'] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
              else
                fallback()
              end
            end, { 'i', 's' }),
            ['<S-Tab>'] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
              else
                fallback()
              end
            end, { 'i', 's' }),
          }),
          sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
            { name = 'buffer' },
            { name = 'path' },
          })
        })

          -- Tab management keymaps
        vim.keymap.set('n', '<leader>tn', ':tabnew<CR>', { noremap = true, desc = 'New tab' })
        vim.keymap.set('n', '<leader>tc', ':tabclose<CR>', { noremap = true, desc = 'Close tab' })
        vim.keymap.set('n', '<leader>to', ':tabonly<CR>', { noremap = true, desc = 'Close other tabs' })
        
        -- Tab navigation
        vim.keymap.set('n', '<leader>1', '1gt', { noremap = true, desc = 'Go to tab 1' })
        vim.keymap.set('n', '<leader>2', '2gt', { noremap = true, desc = 'Go to tab 2' })
        vim.keymap.set('n', '<leader>3', '3gt', { noremap = true, desc = 'Go to tab 3' })
        vim.keymap.set('n', '<leader>4', '4gt', { noremap = true, desc = 'Go to tab 4' })
        vim.keymap.set('n', '<leader>5', '5gt', { noremap = true, desc = 'Go to tab 5' })
        
        -- Alternative tab navigation
        vim.keymap.set('n', '<A-h>', ':tabprevious<CR>', { noremap = true, desc = 'Previous tab' })
        vim.keymap.set('n', '<A-l>', ':tabnext<CR>', { noremap = true, desc = 'Next tab' })
        
        -- Buffer management (another way to manage multiple files)
        vim.keymap.set('n', '<leader>bn', ':bnext<CR>', { noremap = true, desc = 'Next buffer' })
        vim.keymap.set('n', '<leader>bp', ':bprevious<CR>', { noremap = true, desc = 'Previous buffer' })
        vim.keymap.set('n', '<leader>bd', ':bdelete<CR>', { noremap = true, desc = 'Delete buffer' })

        -- Configure bufferline
        require('bufferline').setup({
          options = {
            mode = 'tabs',
            separator_style = 'slant',
            always_show_bufferline = true,
            show_buffer_close_icons = true,
            show_close_icon = true,
            color_icons = true,
            diagnostics = "nvim_lsp",
            diagnostics_indicator = function(count, level)
              local icon = level:match("error") and " " or " "
              return " " .. icon .. count
            end,
          }
        })

        -- Treesitter
        require('nvim-treesitter.configs').setup({
          highlight = { enable = true },
          indent = { enable = true },
        })

        -- Status line
        require('lualine').setup()

        -- Buffer line
        require('bufferline').setup()

        -- Git signs
        require('gitsigns').setup()

        -- Auto pairs
        require('nvim-autopairs').setup()

        -- Comments
        require('Comment').setup()

        -- Indent guides (new version)
        require('ibl').setup()
        
        -- swith navigation keys 
        vim.keymap.set({'n', 'v'}, 'j', 'h')
        vim.keymap.set({'n', 'v'}, 'k', 'k')
        vim.keymap.set({'n', 'v'}, 'l', 'j')
        vim.keymap.set({'n', 'v'}, ';', 'l')

        -- Which key
        require('which-key').setup()
        EOF
      '';
    };
  };

  # Font configuration
  fonts = {
    packages = with pkgs; [
      (nerdfonts.override { fonts = [
        "JetBrainsMono"
        "FiraCode"
        "Hack"
        "DroidSansMono"
      ]; })
      dejavu_fonts
      liberation_ttf
      ubuntu_font_family
    ];
    
    fontconfig = {
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" "DejaVu Sans Mono" ];
        sansSerif = [ "DejaVu Sans" ];
        serif = [ "DejaVu Serif" ];
      };
    };
    enableDefaultPackages = true;
  };


  # Enable the KDE Connect service
  programs.kdeconnect.enable = true;
  # Open ports in the firewall for KDE Connect
  networking.firewall = {
    enable = true;
    allowedTCPPortRanges = [ 
      { from = 1714; to = 1764; } # KDE Connect
    ];  
    allowedUDPPortRanges = [ 
      { from = 1714; to = 1764; } # KDE Connect
    ];  
  }; 

  # Enable and download steam (NOTE : make sure to change the vulkan driver to nvidia)
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };
  
  # enviromental variable that chooses the vulkan driver.
  # uncomment to use the intel drivers, if needed replace "intel" with "nvidia" to use nvidia drivers 
  # comment this to use nvidia drivers
  # environment.variables.VK_DRIVER_FILES=/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json;
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
