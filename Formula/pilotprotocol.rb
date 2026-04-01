class Pilotprotocol < Formula
  desc "The network stack for AI agents - addresses, ports, tunnels, encryption, trust"
  homepage "https://pilotprotocol.network"
  version "1.4.1"
  license "AGPL-3.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/TeoSlayer/pilotprotocol/releases/download/v1.4.1/pilot-darwin-arm64.tar.gz"
      sha256 "9ce6d17f18702d53373bbe90c4cf926a47ca6a9d9e103dc3af3a3854974c672c"
    else
      url "https://github.com/TeoSlayer/pilotprotocol/releases/download/v1.4.1/pilot-darwin-amd64.tar.gz"
      sha256 "de2acb38e1743a8b45e3d9b11d7c54846f2f8af57406772561fbc998496e459d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/TeoSlayer/pilotprotocol/releases/download/v1.4.1/pilot-linux-arm64.tar.gz"
      sha256 "f7dc5d474a41e57b607ea563720e24f0866e11349d7b9c138f164004ba916c92"
    else
      url "https://github.com/TeoSlayer/pilotprotocol/releases/download/v1.4.1/pilot-linux-amd64.tar.gz"
      sha256 "76a22fecaa88d95b488ef3a6e651aa735562886fe696d8b755f48788d28e5f0f"
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
