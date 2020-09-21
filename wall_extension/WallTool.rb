require 'singleton'

class WallTool
  include Singleton

  @@prev_point = nil
  @@wall_width = 100.mm
  @@wall_faces_a = []

  def initialize;end
  
  def activate;end

  def deactivate(view);end

  def onCancel(flag, view);
    puts "Wall tool disabled..."
    Sketchup.active_model.select_tool(nil)
    @@wall_width = 100.mm
    @@prev_point = nil
  end

  def get_selected_pt view, x, y
    view.pickhelper.do_pick x, y
  end

  def set_wall_width width_mm;@@wall_width = width_mm;end
  def get_wall_width;@@wall_width;end

  def get_perp_vector edge, face
    edge_center = edge.bounds.center
    edge_vector = edge.line[1]
    perp_vector = Geom::Vector3d.new(-edge_vector.y, edge_vector.x, edge_vector.z)
    
    pt 	= edge_center.offset(perp_vector, 2.mm)
    res     	= face.classify_point(pt)
    return perp_vector if [1, 8].include?(res)

    pt 	= edge_center.offset(perp_vector.reverse, 2.mm)
    res = face.classify_point(pt)
    return perp_vector.reverse if [1, 8].include?(res)

    return nil
  end

  def create_room_with_walls faces_a
    model = Sketchup.active_model
    ents = model.entities
    temp_grp = ents.add_group()
    puts "Faces : #{faces_a}"
    faces_a.grep(Sketchup::Face).each{|face| temp_grp.entities.add_face face.vertices unless face.deleted?}
    
    exploded_entities = temp_grp.explode.grep(Sketchup::Face)
    @@wall_faces_a = exploded_entities.grep(Sketchup::Face)

    visible_entities = Sketchup.active_model.entities.select{|ent| ent.visible?}.to_a
    ents.grep(Sketchup::Edge).map{|e| e.find_faces}
    post_entities = Sketchup.active_model.entities.select{|ent| ent.visible?}.to_a
    
    new_ents = post_entities - visible_entities
    puts "New ents : #{new_ents}"

    face_ents = new_ents.grep(Sketchup::Face)
    # if face_ents.length == 1
    #   face = face_ents[0]
    face_ents.each{|face|
      if face.area > 1000
        puts "Face area : #{face.area}"
        face.material = 'white'
        face.back_material = 'white'
        @@wall_faces_a = []
        @@prev_point = nil

        face.edges.each { |fedge|
          if fedge.length > 300.mm
            vertices = fedge.vertices
            perp_vector = get_perp_vector fedge, face
            puts "Dim : #{perp_vector} : #{vertices[0].position} : #{vertices[1].position}" 
            ents.add_dimension_linear(vertices[0].position, vertices[1].position, perp_vector) if perp_vector
          end
        }
      end
    }

    # end
  end

  #Works only on the Z plane of ZERO
  def draw_wall start_pt, end_pt, width
    model = Sketchup.active_model
    ents = model.entities

    wall_vector = start_pt.vector_to end_pt

    ref_pt1 = start_pt.offset(wall_vector, 2.mm)
    ref_pt2 = end_pt.offset(wall_vector.reverse, 2.mm)
    ref_line = ents.add_line(ref_pt1, ref_pt2)

    side_vector = Geom::Vector3d.new(-wall_vector.y, wall_vector.x, 0)
    pt1 = start_pt.offset(side_vector, width/2)
    pt2 = start_pt.offset(side_vector.reverse, width/2)
    pt3 = end_pt.offset(side_vector.reverse, width/2)
    pt4 = end_pt.offset(side_vector, width/2)

    wall_face = ents.add_face([pt1,pt2,pt3,pt4])

    @@wall_faces_a << wall_face
    create_room_with_walls @@wall_faces_a
    wall_face
  end
  
  def onLButtonDown(flags,x,y,view)
    input_point = view.inputpoint(x, y)
    puts input_point.position
    if @@prev_point
      puts "Prev point : #{@@prev_point}"
      puts "Distance : #{@@prev_point.position.distance(input_point.position)}"
      pt1 = @@prev_point.position
      pt2 = input_point.position
      @@prev_point = input_point

      width = get_wall_width
      draw_wall pt1, pt2, width
    else
      @@prev_point = input_point
    end
  end

end