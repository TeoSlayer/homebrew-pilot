class Pilotprotocol < Formula
  desc "The network stack for AI agents - addresses, ports, tunnels, encryption, trust"
  homepage "https://pilotprotocol.network"
  version "1.14.0"
  license "AGPL-3.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/pilot-protocol/pilotprotocol/releases/download/v1.14.0/pilot-darwin-arm64.tar.gz"
      sha256 "0d1aee92b1d2ec18fe715016146cbb38883aebb30fd467cf1a0ba5818418841f"
    else
      url "https://github.com/pilot-protocol/pilotprotocol/releases/download/v1.14.0/pilot-darwin-amd64.tar.gz"
      sha256 "7445341d655f2e364dd02f37f050748ebb8405ba694b975e67a76bc8df663cd1"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/pilot-protocol/pilotprotocol/releases/download/v1.14.0/pilot-linux-arm64.tar.gz"
      sha256 "ba042be5193d82770f85e738dc0aadfd31489bedcd7c286fc8cbb8a167ba277b"
    else
      url "https://github.com/pilot-protocol/pilotprotocol/releases/download/v1.14.0/pilot-linux-amd64.tar.gz"
      sha256 "6afd0055c4b113ffa566e36d29a6670333155a83ef24dfc86f01f58afa911b13"
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
