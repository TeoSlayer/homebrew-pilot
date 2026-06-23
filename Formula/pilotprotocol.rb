class Pilotprotocol < Formula
  desc "The network stack for AI agents - addresses, ports, tunnels, encryption, trust"
  homepage "https://pilotprotocol.network"
  version "1.12.3"
  license "AGPL-3.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/pilot-protocol/pilotprotocol/releases/download/v1.12.3/pilot-darwin-arm64.tar.gz"
      sha256 "410790219e9889e4d82a338875af72b06711395a3c5f9debda71899231865c87"
    else
      url "https://github.com/pilot-protocol/pilotprotocol/releases/download/v1.12.3/pilot-darwin-amd64.tar.gz"
      sha256 "bd7c1667dbe8c0d4a9294318a881efbbd0e740d6afbda85b4083f669fc007385"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/pilot-protocol/pilotprotocol/releases/download/v1.12.3/pilot-linux-arm64.tar.gz"
      sha256 "bba3145b46bc77b26d206e11d0c7c8a045bd63f5dd617505ebfd820a176b4613"
    else
      url "https://github.com/pilot-protocol/pilotprotocol/releases/download/v1.12.3/pilot-linux-amd64.tar.gz"
      sha256 "031071157012b7b2a9b59fee539a345f29f9b3f14f8963f3e1933284cd11a5a4"
    end
  end

  def install
    bin.install "daemon" => "pilot-daemon"
    bin.install "pilotctl" => "pilotctl"
    bin.install "updater" => "pilot-updater"
  end

  def post_install
    (var/"pilot").mkpath

    config_dir = Pathname.new(Dir.home)/".pilot"
    config_dir.mkpath
    (config_dir/"bin").mkpath

    # Write version file for the auto-updater
    version_file = config_dir/"bin/.pilot-version"
    version_file.write "v#{version}\n"

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
        pilotctl daemon start --hostname my-agent --email you@example.com
        pilotctl info

      Docs: https://pilotprotocol.network/docs

      To start as background services:
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
