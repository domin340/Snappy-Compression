require_relative "../src/encoder";

encoder = Encoder.new opts:
  {
    dir: "./assets",
    exclude: ["./assets/README.md"]
      .map { |file| file.to_s },
  }, banned_chars_in: "./spc.ban.txt"

encoder.Encode;