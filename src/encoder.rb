require_relative "iotree"

class Encoder < IOTree
  # file paths, banned characters input
  def initialize opts:, banned_chars_in:
    super opts;
    # characters to ignore
    @special_chars = File.exist?(banned_chars_in) ?
      File.open(banned_chars_in, "r").read.split("")
      : [];
    @map = self.GetFrequency self.GatherTokens;
    self.SaveMap;
  end
  def Encode out: "./out.min"
    out = out + ".toml";
    hierarchy = self.GetFilesHierarchy;
    puts hierarchy
  end
  
  private
  attr_reader :special_chars;
  attr_reader :map;
  def SaveMap
    regexp = Regexp.new "=>|\\s"
    # fit minimal json format
    body = @map.inspect.gsub regexp do |match|
        case match
        when "=>"
          ":";
        # space
        when "\s"
          "";
        end
      end
    File.open("./dict.map.json", "w+").write body;
  end
  def Tokenize input
    # returns all possible tokens
    # ignore the case, punctuation and numbers
    regexp = Regexp.new "\\d+|[#{Regexp.escape @special_chars.join}]"
    input.split(" ").map do |token|
      # removes punctuation and numbers from tokens
      cleaned = token.downcase.gsub(/\d+/, "").split regexp;
      cleaned unless cleaned.empty?;
    end .flatten.compact;
  end
  def GetFrequency tokens
    counter = Hash.new 0;
    tokens.each { |token| counter[token] += 1 }
    counter.keys.sort_by { |key| -counter[key] } .map!.with_index do |val, index|
      counter[val] = index.to_s 16;
    end
    counter;
  end
  def GatherTokens
    # returns all documents possible tokens after normalization
    @files.reduce ([]) { |memo, (key, val)| memo.concat self.Tokenize val }
  end
end
