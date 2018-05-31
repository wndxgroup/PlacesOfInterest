class Numeric
  def degrees
    self * Math::PI / 180
  end
end

class ViewController < UIViewController
  attr_accessor :location_manager, :region_radius, :started_loading_POIs,
                :places, :camera_button, :scene_view, :map_message_box,
                :start_button, :exit_button, :curr_location, :destination,
                :target_pos, :distance

  def init
    @location_manager = CLLocationManager.alloc.init
    @region_radius = 1000
    @started_loading_POIs = false
    @places = []
    super
  end

  def viewDidLoad
    super
    display_map
    @location_manager.delegate = self
    @location_manager.desiredAccuracy = 1000 # kCLLocationAccuracyNearestTenMeters
    @location_manager.requestWhenInUseAuthorization
    if @location_manager.headingAvailable
      @location_manager.startUpdatingHeading
    else
      UIAlertView.alloc.initWithTitle('Heading Unavailable',
                                      message: 'Sorry, the AR won\'t work for your device.',
                                      delegate: nil,
                                      cancelButtonTitle: 'Ok',
                                      otherButtonTitles: nil).show
    end
  end

  def display_map
    self.view = MKMapView.alloc.init
    view.showsUserLocation = true
    view.delegate = self
    @location_manager.startUpdatingLocation
    if @started_loading_POIs
      @places.each {|a| Dispatch::Queue.main.async {view.addAnnotation(a)}}
    end
  end

  def display_AR
    @scene_view = ARSCNView.alloc.init
    @scene_view.autoenablesDefaultLighting = true
    @scene_view.delegate = self
    configuration = ARWorldTrackingConfiguration.alloc.init
    configuration.worldAlignment = ARWorldAlignmentGravityAndHeading
    @scene_view.session.runWithConfiguration(configuration)
    @scene_view.session.delegate = self
    self.view = @scene_view
    add_cones

    height = 80
    ar_message_box = make_message_box(height)
    @distance = UILabel.new
    @distance.font = UIFont.systemFontOfSize(18)
    @distance.text = "#{@curr_location.distanceFromLocation(@destination).round}m away"
    @distance.textColor = UIColor.alloc.initWithRed(0, green: 0, blue: 0, alpha: 1)
    @distance.frame = [[20, 0], [UIScreen.mainScreen.bounds.size.width, height]]
    ar_message_box.addSubview(@distance)

    exit_width   = 50
    exit_frame   = [[UIScreen.mainScreen.bounds.size.width - exit_width, 0],
                     [exit_width, height]]
    @exit_button = UIView.alloc.initWithFrame(exit_frame)
    exit = UILabel.new
    exit.font = UIFont.systemFontOfSize(18)
    exit.text = 'Exit'
    exit.textColor = UIColor.alloc.initWithRed(1, green: 1, blue: 1, alpha: 1.0)
    exit.frame = [[0, 0], [exit_width, height]]
    @exit_button.addSubview(exit)
    ar_message_box.addSubview(@exit_button)

    view.addSubview(ar_message_box)
  end

  def locationManager(manager, didUpdateLocations: locations)
    if locations.count > 0
      location = @curr_location = locations.last
      puts "Accuracy: #{location.horizontalAccuracy}"
      if location.horizontalAccuracy < 100
        @location_manager.stopUpdatingLocation
        span = MKCoordinateSpanMake(0.014, 0.014)
        region = MKCoordinateRegionMake(location.coordinate, span)
        view.setRegion(region, true)
        unless @started_loading_POIs
          @started_loading_POIs = true
          loader = PlacesLoader.alloc.init
          loader.load_POIs(self, location, 1000)
        end
      end
    end
  end

  def center_map_on_location(location)
    coordinate_region = MKCoordinateRegionMakeWithDistance(location.coordinate, @region_radius, @region_radius)
    view.setRegion(coordinate_region, false)
  end

  def touchesEnded(touches, withEvent: event)
    display_AR if event.touchesForView(@start_button)
    if event.touchesForView(@exit_button)
      @scene_view.session.pause
      display_map
    end
  end

  def add_cones
    scene = SCNScene.scene

    guide_geometry = SCNPyramid.pyramidWithWidth(0.1, height: 0.2, length: 0.1)
    guide_material = SCNMaterial.material
    guide_material.diffuse.contents = NSColor.colorWithRed(0, green: 1, blue: 1, alpha: 0.8)
    guide_material.doubleSided = true
    guide_geometry.materials = [guide_material]
    guide = SCNNode.nodeWithGeometry(guide_geometry)
    guide.position = SCNVector3Make(0, 0.3, -1)

    target_geometry = SCNPyramid.pyramidWithWidth(2, height: 6, length: 2)
    target_material = SCNMaterial.material
    target_material.diffuse.contents = NSColor.colorWithRed(0, green: 1, blue: 0, alpha: 0.8)
    target_material.doubleSided = true
    target_geometry.materials = [target_material]
    target = SCNNode.nodeWithGeometry(target_geometry)
    target.position = @target_pos = get_target_vec_location

    constraint = SCNLookAtConstraint.lookAtConstraintWithTarget(target)
    constraint.localFront = SCNVector3Make(0, 0.2, 0)
    guide.constraints = [constraint]

    @scene_view.pointOfView.addChildNode(guide)
    scene.rootNode.addChildNode(target)
    @scene_view.scene = scene
  end

  def get_target_vec_location
    c_lon = @curr_location.coordinate.longitude
    c_lat = @curr_location.coordinate.latitude
    d_lon = @destination.coordinate.longitude
    d_lat = @destination.coordinate.latitude
    rlat = c_lat * Math::PI / 180
    m_per_deg_lat = 111132.92 - 559.82 * Math.cos(2* rlat) + 1.175*Math.cos(4*rlat)
    m_per_deg_lon = 111412.84 * Math.cos(rlat) - 93.5 * Math.cos(3*rlat)
    x = (d_lon - c_lon) * m_per_deg_lon
    z = (c_lat - d_lat) * m_per_deg_lat
    SCNVector3Make(x, -1, z)
  end

  def make_message_box(height)
    frame = [[0, UIScreen.mainScreen.bounds.size.height - height],
             [UIScreen.mainScreen.bounds.size.width, height]]
    message_box = UIView.alloc.initWithFrame(frame)
    message_box.backgroundColor = UIColor.alloc.initWithRed(0, green: 0.7, blue: 0, alpha: 0.92)
    message_box
  end

  # Called when a map annotation is selected
  def mapView(mapView, didSelectAnnotationView: view)
    if view.class.to_s == 'NSKVONotifying_MKModernUserLocationView'
      return
    end
    @map_message_box.removeFromSuperview unless @map_message_box.nil?
    @destination = CLLocation.alloc.initWithLatitude(view.coordinate.latitude, longitude: view.coordinate.longitude)

    height = 80
    @map_message_box = make_message_box(height)
    distance = UILabel.new
    distance.font = UIFont.systemFontOfSize(18)
    distance.text = "#{@curr_location.distanceFromLocation(@destination).round}m away"
    distance.textColor = UIColor.alloc.initWithRed(0, green: 0, blue: 0, alpha: 1)
    distance.frame = [[20, 0], [UIScreen.mainScreen.bounds.size.width, height]]
    @map_message_box.addSubview(distance)

    start_width   = 60
    start_frame   = [[UIScreen.mainScreen.bounds.size.width - start_width, 0],
                     [start_width, height]]
    @start_button = UIView.alloc.initWithFrame(start_frame)
    start = UILabel.new
    start.font = UIFont.systemFontOfSize(18)
    start.text = 'Start'
    start.textColor = UIColor.alloc.initWithRed(1, green: 1, blue: 1, alpha: 1.0)
    start.frame = [[0, 0], [start_width, height]]
    @start_button.addSubview(start)
    @map_message_box.addSubview(@start_button)

    self.view.addSubview(@map_message_box)
  end

  # Called when a map annotation is deselected
  def mapView(mapView, didDeselectAnnotationView: view)
    @map_message_box.removeFromSuperview unless @map_message_box.nil?
  end

  # Called with every AR frame update
  def session(session, didUpdateFrame: frame)
    me = @scene_view.pointOfView.position
    @distance.text = "#{Math.sqrt((@target_pos.x - me.x)**2 + (@target_pos.z - me.z)**2).round}m away"
  end
end