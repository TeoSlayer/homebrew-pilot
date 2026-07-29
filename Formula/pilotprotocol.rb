class Pilotprotocol < Formula
  desc "The network stack for AI agents - addresses, ports, tunnels, encryption, trust"
  homepage "https://pilotprotocol.network"
  version "1.13.8"
  license "AGPL-3.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/pilot-protocol/pilotprotocol/releases/download/v1.13.8/pilot-darwin-arm64.tar.gz"
      sha256 "dd5ab9ad4d81d364655e4664d7272513410bf872785bdec19954c96170f94547"
    else
      url "https://github.com/pilot-protocol/pilotprotocol/releases/download/v1.13.8/pilot-darwin-amd64.tar.gz"
      sha256 "65205676ce300ccb3254fe8f1d76ecdb00a9621be03e1bb9f9876ff0b97002e6"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/pilot-protocol/pilotprotocol/releases/download/v1.13.8/pilot-linux-arm64.tar.gz"
      sha256 "4a36945f7de559888e811aece0769e08627cb08d75d40d4d3a768457ce183dd4"
    else
      url "https://github.com/pilot-protocol/pilotprotocol/releases/download/v1.13.8/pilot-linux-amd64.tar.gz"
      sha256 "5ac75e0d34f58fa7ea5cc7039a3f5b5e61a7e0c94afc7c60de2beea365ce230d"
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
