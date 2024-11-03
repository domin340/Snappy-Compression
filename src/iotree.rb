require "pathname";

class IOTree
  attr_reader :files;
  def initialize opts
    # select just files from provided directory
    # then difference it with excluded
    files = (Dir.glob("#{opts[:dir]}/**/*") - opts[:exclude])
      .select { |file| File.file? file };
    @files = self.InToHash files;
  end
  def GetFilesHierarchy
    toml_body = {};
    @files.each do |key, val|
      last_element = nil;
      # extract path from the file and iterate each path part with index
      (Pathname.new key)
        .each_filename.with_index do |part, index|
          # distinguish if the path part looks like file or rathered directory
          is_file = !File.extname(part).empty?;
          # prevent from assigning to nil and multiple conditions
          target = last_element || toml_body;
          # if the part path looks like file set body to whats inside
          # otherwise check if the target exists to prevent data loss
          # if not assign it to empty hash
          body = is_file ? val : target[part] || {};
          target[part] = body;
          # assign last element to current target to continue hash structuring
          last_element = target[part];
        end
    end
    # remove the . as if every path starts with it
    toml_body["."];
  end
  protected
    # Input to hash returns { path: data, ... }
    def InToHash files
      files.map { |file| [file, File.open(file, 'r').read] } .to_h;
    end
end
