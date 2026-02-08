class Pilotprotocol < Formula
  desc "The network stack for AI agents - addresses, ports, tunnels, encryption, trust"
  homepage "https://github.com/TeoSlayer/pilotprotocol"
  version "1.0.0"
  license "AGPL-3.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/TeoSlayer/pilotprotocol/releases/download/v1.0.0/pilot-darwin-arm64.tar.gz"
      sha256 "9218656b6113a8f6a22218ce7e29652bc370dfe80f7c3166c64bc15402788c53"
    else
      url "https://github.com/TeoSlayer/pilotprotocol/releases/download/v1.0.0/pilot-darwin-amd64.tar.gz"
      sha256 "fac82c47bce16c701d1e4d1706b3de6b4f436c65a469ee78b82aeeec4e2646eb"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/TeoSlayer/pilotprotocol/releases/download/v1.0.0/pilot-linux-arm64.tar.gz"
      sha256 "2547d1884a7502dacb624c1d11c4031d5f8801ab5d2c852c93b3f93e5e27783e"
    else
      url "https://github.com/TeoSlayer/pilotprotocol/releases/download/v1.0.0/pilot-linux-amd64.tar.gz"
      sha256 "ba8f78c2cee09306ccb68f88973821d87c5d3c399fafea8a81e093a3677acf0e"
    end
  end

  def install
    os = OS.mac? ? "darwin" : "linux"
    arch = Hardware::CPU.arm? ? "arm64" : "amd64"

    bin.install "pilot-daemon-#{os}-#{arch}" => "pilot-daemon"
    bin.install "pilot-pilotctl-#{os}-#{arch}" => "pilotctl"
    bin.install "pilot-gateway-#{os}-#{arch}" => "pilot-gateway"
  end

  def post_install
    (var/"pilot").mkpath

    config_dir = Pathname.new(Dir.home)/".pilot"
    config_dir.mkpath

    config_file = config_dir/"config.json"
    unless config_file.exist?
      config_file.write <<~JSON
        {
          "registry": "35.193.106.76:9000",
          "beacon": "35.193.106.76:9001",
          "socket": "/tmp/pilot.sock",
          "encrypt": true,
          "identity": "#{config_dir}/identity.json"
        }
      JSON
    end
  end

  def caveats
    <<~EOS
      Config written to ~/.pilot/config.json (if not already present).

      Get started:
        pilotctl daemon start --hostname my-agent
        pilotctl info

      To start the daemon as a background service:
        brew services start pilotprotocol
    EOS
  end

  service do
    run [
      opt_bin/"pilot-daemon",
      "-registry", "35.193.106.76:9000",
      "-beacon", "35.193.106.76:9001",
      "-listen", ":4000",
      "-socket", "/tmp/pilot.sock",
      "-identity", "#{Dir.home}/.pilot/identity.json",
      "-encrypt",
    ]
    keep_alive crashed: true
    log_path var/"log/pilot-daemon.log"
    error_log_path var/"log/pilot-daemon.log"
  end

  test do
    assert_match "pilotctl", shell_output("#{bin}/pilotctl --help 2>&1", 0)
  end
end
