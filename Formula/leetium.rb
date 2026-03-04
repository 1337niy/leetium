class Leetium < Formula
  desc "Rust-powered bot framework with LLM agents, plugins, and gateway"
  homepage "https://github.com/1337leetium/leetium"
  url "https://github.com/1337leetium/leetium.git",
      tag:      "v0.1.0",
      revision: ""
  license "MIT"
  head "https://github.com/1337leetium/leetium.git", branch: "main"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/cli")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/leetium --version", 2)
  end
end
