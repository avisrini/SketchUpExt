require 'sketchup.rb'
require 'extensions.rb'

module Avinash
  module CustomTool

    unless file_loaded?(__FILE__)
      # ex = SketchupExtension.new('Hello Cube', 'as_create_cube/main')
      ex = SketchupExtension.new('Line Tool', 'as_line_tool/line_tool')
      ex.description = 'SketchUp Ruby API example creating a cube.'
      ex.version     = '1.0.0'
      ex.copyright   = 'Avisrini © 2020'
      ex.creator     = 'SketchUp'
      Sketchup.register_extension(ex, true)
      file_loaded(__FILE__)
    end

  end # module CustomTool
end # module Avinash