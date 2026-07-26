class Pilotprotocol < Formula
  desc "The network stack for AI agents - addresses, ports, tunnels, encryption, trust"
  homepage "https://pilotprotocol.network"
  version "1.13.6"
  license "AGPL-3.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/pilot-protocol/pilotprotocol/releases/download/v1.13.6/pilot-darwin-arm64.tar.gz"
      sha256 "cff52d8b958559607a4f1360faa18d2df11a486bc5020fd46647c3ff6d6cdf30"
    else
      url "https://github.com/pilot-protocol/pilotprotocol/releases/download/v1.13.6/pilot-darwin-amd64.tar.gz"
      sha256 "93fe53f640d92a399fca30dfe0f1d782602ca3c50d79c5bf747a9a49cca198c2"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/pilot-protocol/pilotprotocol/releases/download/v1.13.6/pilot-linux-arm64.tar.gz"
      sha256 "0155fa17918e6b932689e645e675c43dc8afa468263fb6561fb0804bfd6ab78a"
    else
      url "https://github.com/pilot-protocol/pilotprotocol/releases/download/v1.13.6/pilot-linux-amd64.tar.gz"
      sha256 "4e27b7fc2b4f6e22e3b01876fba606ada4fba3c1de1e47ba1746831042509c31"
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
