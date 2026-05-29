class Pilotprotocol < Formula
  desc "The network stack for AI agents - addresses, ports, tunnels, encryption, trust"
  homepage "https://pilotprotocol.network"
  version "1.10.5"
  license "AGPL-3.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/TeoSlayer/pilotprotocol/releases/download/v1.10.5/pilot-darwin-arm64.tar.gz"
      sha256 "125fe7c8b83ce89f53487ec0ac1fe22decd4defd4af2b42559809042e2083597"
    else
      url "https://github.com/TeoSlayer/pilotprotocol/releases/download/v1.10.5/pilot-darwin-amd64.tar.gz"
      sha256 "eab41da1108068e965e4c500bfae6f5aa1b6a21d02b7feb3942fd2b6434fc3be"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/TeoSlayer/pilotprotocol/releases/download/v1.10.5/pilot-linux-arm64.tar.gz"
      sha256 "37428a4b08e6880cffca5049df872746358c41f9d63c25d5896446c48aa7e165"
    else
      url "https://github.com/TeoSlayer/pilotprotocol/releases/download/v1.10.5/pilot-linux-amd64.tar.gz"
      sha256 "b062e355f24d85b884345de396398cd95d5c70fd44d23a9633c1bbcd3003022b"
    end
  end

  def install
    bin.install "daemon" => "pilot-daemon"
    bin.install "pilotctl" => "pilotctl"
    bin.install "gateway" => "pilot-gateway"
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
