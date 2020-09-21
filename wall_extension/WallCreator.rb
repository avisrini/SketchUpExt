require_relative 'WallTool'

module WallCreator
  @@wall_main_dialog = nil
  extend self

  def create_wall_dialog
    dialog_h = {
      :dialog_title=>"Wall Details",
      :preferences_key=>"com.sample.plugin",
      :scrollable=>true,
      :resizable=>true,
      :style=>UI::HtmlDialog::STYLE_DIALOG,

      #Size values
      :min_width => 50,
      :min_height => 50,
      :max_width =>1000,
      :max_height => 1000
    }

    wall_dialog = get_wall_dialog
    html_path = File.join(Sketchup.find_support_file('Plugins'), 'wall_extension/wall.html')

    #If dialog not created or not visible...create new
    if wall_dialog.nil? || !wall_dialog.visible?
      wall_dialog = UI::HtmlDialog.new(dialog_h)

      wall_dialog.set_file(html_path)
      wall_dialog.set_size(450, 600)
      wall_dialog.set_position(100,100)
      add_main_action_callbacks wall_dialog

      @@wall_main_dialog = wall_dialog

      wall_dialog.show
    end
    wall_dialog
  end

  def get_wall_dialog
    @@wall_main_dialog
  end

  def add_main_action_callbacks wall_dialog

    #Add all the callback feature requests here
    wall_dialog.add_action_callback("createWall") { |dlg, params|
      puts "CB : createWall : #{params}"
      inputs = JSON.parse(params)
      wall_inst = WallTool.instance
      puts "inputs : #{inputs} : #{inputs['wall_width']} : #{inputs[:wall_width]}"
      wall_inst.set_wall_width inputs['wall_width'].to_i.mm
      Sketchup.active_model.select_tool(wall_inst)

    }
  end 
end
