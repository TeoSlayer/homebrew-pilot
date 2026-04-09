class Pilotprotocol < Formula
  desc "The network stack for AI agents - addresses, ports, tunnels, encryption, trust"
  homepage "https://pilotprotocol.network"
  version "1.7.1"
  license "AGPL-3.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/TeoSlayer/pilotprotocol/releases/download/v1.7.1/pilot-darwin-arm64.tar.gz"
      sha256 "5251decf57830ddc7cc08028a26ac2b163238946ec085e5705fb43ee91f03631"
    else
      url "https://github.com/TeoSlayer/pilotprotocol/releases/download/v1.7.1/pilot-darwin-amd64.tar.gz"
      sha256 "a62036f86cd377005903a9f5bc3be8a31223d36daaaad4170502399a98894531"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/TeoSlayer/pilotprotocol/releases/download/v1.7.1/pilot-linux-arm64.tar.gz"
      sha256 "18088d10886f7758c28990285a0d9dd37bd5bd2ce593c1a4132b1730cf1e5b22"
    else
      url "https://github.com/TeoSlayer/pilotprotocol/releases/download/v1.7.1/pilot-linux-amd64.tar.gz"
      sha256 "5e9181be0b3fda1bd1557be8041be84d668c3066024c94908c6a695c9972e9e0"
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
