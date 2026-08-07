class Pilotprotocol < Formula
  desc "The network stack for AI agents - addresses, ports, tunnels, encryption, trust"
  homepage "https://pilotprotocol.network"
  version "managed-runtime-v0.1.3"
  license "AGPL-3.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/pilot-protocol/pilotprotocol/releases/download/managed-runtime-v0.1.3/pilot-darwin-arm64.tar.gz"
      sha256 "14b0e8cfd51931a1cef5dfcabac5f9abe1bc436d21c42bda659d2f97e4dba2c2"
    else
      url "https://github.com/pilot-protocol/pilotprotocol/releases/download/managed-runtime-v0.1.3/pilot-darwin-amd64.tar.gz"
      sha256 "f34a01c363b254f7c5ca2b42e4fe2eaef893b60361cec3e96ee11c2237c32153"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/pilot-protocol/pilotprotocol/releases/download/managed-runtime-v0.1.3/pilot-linux-arm64.tar.gz"
      sha256 "8c171351cf28fe1d0f5e024910e92ae5e9730ca801528324c92cfd9c4ddfab6a"
    else
      url "https://github.com/pilot-protocol/pilotprotocol/releases/download/managed-runtime-v0.1.3/pilot-linux-amd64.tar.gz"
      sha256 "1c19f7bc3b51eab1a41e9e90698f4f25f47a28a964ddc6d36d1164d710ff7124"
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
