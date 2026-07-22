class Pilotprotocol < Formula
  desc "The network stack for AI agents - addresses, ports, tunnels, encryption, trust"
  homepage "https://pilotprotocol.network"
  version "1.13.2"
  license "AGPL-3.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/pilot-protocol/pilotprotocol/releases/download/v1.13.2/pilot-darwin-arm64.tar.gz"
      sha256 "95cdef5ac41a2ff4e6b148d1f3d34fbf5549a3e071a18aec85b3fc017a2d26f1"
    else
      url "https://github.com/pilot-protocol/pilotprotocol/releases/download/v1.13.2/pilot-darwin-amd64.tar.gz"
      sha256 "61d8e74e0c0ac4f0c71a229314e1047dc317f2de8f7e92ebc5e9521c774d3853"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/pilot-protocol/pilotprotocol/releases/download/v1.13.2/pilot-linux-arm64.tar.gz"
      sha256 "6ecc92311e9ef1ec5af55a384bba71ba9f60526d0b36d897b11f53fd084911e9"
    else
      url "https://github.com/pilot-protocol/pilotprotocol/releases/download/v1.13.2/pilot-linux-amd64.tar.gz"
      sha256 "48279b68612cf266df9eb57453a48ac649064ef37e673c9acd20190797b2820d"
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
