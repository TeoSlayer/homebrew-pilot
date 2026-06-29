class Pilotprotocol < Formula
  desc "The network stack for AI agents - addresses, ports, tunnels, encryption, trust"
  homepage "https://pilotprotocol.network"
  version "1.12.4"
  license "AGPL-3.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/pilot-protocol/pilotprotocol/releases/download/v1.12.4/pilot-darwin-arm64.tar.gz"
      sha256 "8f73eb0c2f0d38afa46057380b8f46fdbf44b55a60320a81cf9a0b67399b5d9d"
    else
      url "https://github.com/pilot-protocol/pilotprotocol/releases/download/v1.12.4/pilot-darwin-amd64.tar.gz"
      sha256 "b3cb4863f96b5586a6d94cc3811c8faf1931bfe28f0c878b355a0c2345af7ffe"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/pilot-protocol/pilotprotocol/releases/download/v1.12.4/pilot-linux-arm64.tar.gz"
      sha256 "1b2fc9584c7a884744d173815e14889ff161f50b506bf1e1287db0edf0f4e220"
    else
      url "https://github.com/pilot-protocol/pilotprotocol/releases/download/v1.12.4/pilot-linux-amd64.tar.gz"
      sha256 "ac0a053ee991e55fa788d21351ed67f74028b9ed7060b6d199a221d32e5d6979"
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
