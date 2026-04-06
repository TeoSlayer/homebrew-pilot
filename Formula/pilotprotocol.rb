class Pilotprotocol < Formula
  desc "The network stack for AI agents - addresses, ports, tunnels, encryption, trust"
  homepage "https://pilotprotocol.network"
  version "1.5.1"
  license "AGPL-3.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/TeoSlayer/pilotprotocol/releases/download/v1.5.1/pilot-darwin-arm64.tar.gz"
      sha256 "7f6bf6831cc7db4437a4b19e205ec26535940c0467199f2676eb2bc3475ca8fd"
    else
      url "https://github.com/TeoSlayer/pilotprotocol/releases/download/v1.5.1/pilot-darwin-amd64.tar.gz"
      sha256 "da61a4dd4cf7770bb9fc897757920cb8e0f07d38d74b01a02e51d87b2df149b7"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/TeoSlayer/pilotprotocol/releases/download/v1.5.1/pilot-linux-arm64.tar.gz"
      sha256 "b37e8c01be6ace80aa8d906bc1e73d209cd56cbc82e379d3353f39ada16f22a4"
    else
      url "https://github.com/TeoSlayer/pilotprotocol/releases/download/v1.5.1/pilot-linux-amd64.tar.gz"
      sha256 "44217b4627f18524ee3d6227bdb8e0030d0476650cf98ecd4e50054cdaf98dc4"
    end
  end

  def install
    bin.install "daemon" => "pilot-daemon"
    bin.install "pilotctl" => "pilotctl"
    bin.install "gateway" => "pilot-gateway"
  end

  def post_install
    (var/"pilot").mkpath

    config_dir = Pathname.new(Dir.home)/".pilot"
    config_dir.mkpath

    config_file = config_dir/"config.json"
    unless config_file.exist?
      config_file.write <<~JSON
        {
          "registry": "34.71.57.205:9000",
          "beacon": "34.71.57.205:9001",
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

      Docs: https://pilotprotocol.network/docs

      To start the daemon as a background service:
        brew services start pilotprotocol
    EOS
  end

  service do
    run [
      opt_bin/"pilot-daemon",
      "-registry", "34.71.57.205:9000",
      "-beacon", "34.71.57.205:9001",
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
