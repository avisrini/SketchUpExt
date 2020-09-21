require_relative 'WallCreator'

UI.menu('Plugins').add_item('Wall Creator'){
  wall_dialog = WallCreator.create_wall_dialog 
  wall_dialog.show
}