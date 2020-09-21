require 'sketchup.rb'
require 'extensions.rb'

loader 			    = File.join(Sketchup.find_support_file('Plugins'), 'wall_extension/wall_loader.rb')
title 			    = 'Wall designer'
ext 			      = SketchupExtension.new(title, loader)

Sketchup.register_extension(ext, true)

SKETCHUP_CONSOLE.clear
SKETCHUP_CONSOLE.show