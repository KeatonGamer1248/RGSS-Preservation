#============================================================================
# Talk Command
#----------------------------------------------------------------------------
# LEVEL: Easy, Medium
# AUTHOR: Pie God
# MODIFIED BY: KeatonGamer
# 
# DESCRIPTION:
# Want to add a talk system to your game with a custom HUD and everything? 
# This script does exactly that!
#
# TERMS OF USE:
# Free for commercial and non-commercial. Credit is not needed.
#============================================================================

#============================================================================
# Configuration
#============================================================================
module PGS
  #==========================================================================
  # Talk Variable
  #--------------------------------------------------------------------------
  # This is where the Actor ID of whoever you selected to talk to is stored.
  #==========================================================================
  CommonEvent  = true  # Toggles the Common Event.
  TalkEvent    = 101   # Calls the Common Event if CommonEvent is set to true.
  TalkVariable = 18    # Don't leave this at 0 or the script will explode.
end

class Window_TalkCommand < Window_Command
  #==========================================================================
  # Public Variable
  #==========================================================================
  attr_accessor :command_talk
  #==========================================================================
  # Initialize
  #==========================================================================
  def initialize
    # Starting Position
    super(146, 40)

    # Clears windowskin
    self.windowskin = build_windowskin

    # Draw Background
    create_background

    # Invisible on startup
    self.visible = false
  end
  #==========================================================================
  # Processing When OK Button Is Pressed
  #==========================================================================
  def process_ok
    @command_talk = @index
    super
  end
  #==========================================================================
  # Create Background
  #==========================================================================
  def create_background
    # Builds background sprite
    @background_sprite = Sprite.new()
    @background_sprite.bitmap = Cache.system("HUD_Talk")

    # Positioning
    @background_sprite.x = self.x
    @background_sprite.y = self.y - line_height

    # Layer to whatever
    @background_sprite.z = self.z

    # While we're at it, layer the window a bit higher
    self.z += 1

    # Also hides background on startup
    @background_sprite.visible = false
  end
  
  #==========================================================================
  # Setup Alignment
  #==========================================================================
  def alignment
    return 1
  end
  #==========================================================================
  # Setup window width
  #==========================================================================
  def window_width
    return 130
  end
  #==========================================================================
  # Create Command List
  #==========================================================================
  def make_command_list
    add_actor_commands
  end
  #==========================================================================
  # Makes a command for each party member
  #==========================================================================
  def add_actor_commands
    # Gets party members
    party = $game_party.members

    # Gets everyone who isn't the party leader
    party = party.select {|actor| actor != $game_party.leader}

    # Makes commands
    party.each do |actor|
      add_command(actor.name, :select_actor)
    end
  end
  #==========================================================================
  # Syncs background
  #==========================================================================
  def update
    super
    @background_sprite.visible = self.visible
  end
  #==========================================================================
  # Disposes background
  #==========================================================================
  def dispose
    super
    @background_sprite.dispose
  end
  #==========================================================================
  # Build Transparent Windowskin
  #--------------------------------------------------------------------------
  #  Brute forces the stock window background to be invisible other than text
  # color
  #
  #  I refuse to let this be more time consuming than it needs to be, so this
  # also keeps it cached in Cache
  #==========================================================================
  def build_windowskin
    # Gets a direct access to Cache's cache
    cache = Cache.instance_variable_get(:@cache)

    # Doesn't bother if we already did this
    return cache[:pgs_invisible] if cache[:pgs_invisible]

    # Copies whatever the current windowskin is
    skin = self.windowskin.clone

    # Removes the background
    (0..128).each do |y| ; (0..64).each do |x|
        skin.set_pixel(x, y, Color.new())
    end ; end

    # Removes the outline
    (0..64).each do |y| ; (64..128).each do |x|
      skin.set_pixel(x, y, Color.new())
    end ; end

    # Adds to cache
    cache[:pgs_invisible] = skin

    # Done!
    return skin
  end
  #==========================================================================
  # This method is for Luna Engine's "Window Cursor" script.
  # Here are the instructions on how set it up.
  #--------------------------------------------------------------------------
  # - Go to the script called "Window Cursor" and insert this script right
  # below the module called "OtherMenu":
  #~   module GameEnd
  #~     GAME_END ||= {} # compatible line
  #~     GAME_END[:custom_cursor] = {
  #~       :enable   => true,	            # Enable Cursor? True/False
  #~       :cursor   => "Skin_Cursor2",   # Cursor filename
  #~       :frame    => 7,                # Amount of Frames
  #~       :offset_x => -15,						  # Adjust X value without affecting the base X.						
  #~       :offset_y => 15,							  # Adjust Y value without affecting the base Y.
  #~       :fps      => 4,                # Wait time before changing to the next frame.
  #~     }
  #~   end
  # Make sure to press CTRL + Q or if you're on Macintosh press COMMAND + Q
  # after pasting the script.
  # - Next step, go into Module Luna and add another string called "TalkMenu".
  #==========================================================================
  def setting 
    # If you don't have Luna Engine, ignore the instructions and just comment 
    # out this method unless you have Luna Engine.
    MenuLuna::TalkMenu::TALK_WINDOW
  end
end

class Scene_Menu
  #==========================================================================
  # * Start Processing
  #==========================================================================
  alias pgs_talk_window_start start
  def start
    pgs_talk_window_start
    create_talk_window
  end
  #==========================================================================
  # Create Talk Window
  #==========================================================================
  def create_talk_window
    @talk_window = Window_TalkCommand.new
    @talk_window.unselect
    @talk_window.deactivate
    @talk_window.visible = false
    @talk_window.set_handler(:ok,     method(:on_talk_ok))
    @talk_window.set_handler(:cancel, method(:on_talk_cancel))
  end
  #==========================================================================
  # Command Talk
  #==========================================================================
  def command_talk
    @talk_window.visible = true
    @talk_window.activate
    @talk_window.select(0)
  end
  #==========================================================================
  # On Talk OK
  #==========================================================================
  def on_talk_ok
    target = @talk_window.command_talk

    actor = $game_party.members[target+1]
    
    $game_variables[PGS::TalkVariable] = actor.id
    
    unless PGS::CommonEvent == true 
      # do nothing
    else
      $game_temp.reserve_common_event(PGS::TalkEvent)
    end
    
    # Returns to map
    return_scene

    #  NOTE: If you want to reserve a common event to handle the talk
    # event, do this here
  end
  #==========================================================================
  # On Talk Cancel
  #==========================================================================
  def on_talk_cancel
    @talk_window.deactivate
    @talk_window.visible = false
    @command_window.activate
  end
end