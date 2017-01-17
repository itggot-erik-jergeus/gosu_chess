require 'gosu'

# module ZOrder
#   Background, Layout, Highlight, Piece, Cursor = *0..4
# end

# TODO Fix Models for cursor and highlight. Remember different colors on Move Only and Attack Only
# TODO Fix Wrong turn window and code
# TODO Fix Confirm attack window and add the code for implementing it
# TODO Fix Check Mate screen

class GameWindow < Gosu::Window

  def initialize
    super 540, 540
    self.caption = "Chess"
    # @background is a variable that contains the media file for the background used.
    @background_image = Gosu::Image.new('./media/8x8.png', :tileable => true)
    # @square_blue is a variable that contains the media file for the even player's @highlight image
    @square_blue = Gosu::Image.new('./media/60x60_blue.jpg')
    # @square_red is a variable that contains the media file for the odd player's @highlight image
    @square_red = Gosu::Image.new('./media/60x60_red.jpg')
    # @cursor is a variable that cointains the media file for the cursor
    @cursor = Gosu::Image.new(self, './media/cursor-arrow.png')
    # @pieces is an array that contains various Piece subclasses
    @pieces = []
    # @shields is an array that contains all shields from Paladins. Formated as X,Y,Direction,Team
    @shields = []
    # @selected is a variable that contains a Piece subclass of the targeted chess piece
    @selected = nil
    # @highlight is all your eligible moves for the @selected piece
    @highlight = []
    # @turn is the current turn, starting at 0. Will most often be used with %2 to figure out whose turn it is
    @turn = 0
    # @board is a temporary variable that says the size of the board ATM
    @board = spawn("8x8")
  end

  def check_mate
    alive = []
    @pieces.each do |piece|
      # Checks how many general exists
      if piece.type == general
        # Says which generals are alive
        alive << piece.owner
      end
    end
    # Checks if both players have atleast 1 general alive
    if alive.include?(0) && alive.include?(1)
      false
    # Outputs the player that's alive (this will only happen if 1 player is not alive)
    else
      # Should show end message
      alive[0]
    end
  end

  # Removes all shields and then adds three shields to all Paladins adjacent to it, by calling the method 'shield'
  def shield
    @shields = []
    @pieces.each do |piece|
      if piece.class == Paladin
        piece.shield.each do |shield|
          @shields << shield
        end
      end
    end
  end

  def spawn(size)
    if size =="8x8"
      # Creating some pieces for both sides
      @pieces << General.new(4,0,180,0)
      @pieces << General.new(3,0,180,0)
      @pieces << General.new(4,7,0,1)
      @pieces << General.new(3,7,0,1)
      @pieces << Cavalry.new(2,7,180,1)
      @pieces << Cavalry.new(5,7,180,1)
      @pieces << Cavalry.new(2,0,0,0)
      @pieces << Cavalry.new(5,0,0,0)
      @pieces << Cavalry.new(0,7,180,1)
      @pieces << Cavalry.new(7,7,180,1)
      @pieces << Cavalry.new(0,0,0,0)
      @pieces << Cavalry.new(7,0,0,0)
      @pieces << Paladin.new(2,6,180,1)
      @pieces << Paladin.new(5,6,180,1)
      @pieces << Paladin.new(2,1,0,0)
      @pieces << Paladin.new(5,1,0,0)
      @pieces << Warrior.new(0,1,0,0)
      @pieces << Warrior.new(1,1,0,0)
      @pieces << Warrior.new(3,1,0,0)
      @pieces << Warrior.new(4,1,0,0)
      @pieces << Warrior.new(6,1,0,0)
      @pieces << Warrior.new(7,1,0,0)
      @pieces << Warrior.new(0,6,180,1)
      @pieces << Warrior.new(1,6,180,1)
      @pieces << Warrior.new(3,6,180,1)
      @pieces << Warrior.new(4,6,180,1)
      @pieces << Warrior.new(6,6,180,1)
      @pieces << Warrior.new(7,6,180,1)
      @pieces << Archer.new(1,0,0,0)
      @pieces << Archer.new(6,0,0,0)
      @pieces << Archer.new(1,7,180,1)
      @pieces << Archer.new(6,7,180,1)


      shield
    end
  end

  def update
    if Gosu::button_down?(Gosu::MsLeft) then
      ### p "#{(mouse_x/60).to_i},#{(mouse_y/60).to_i-1}"
      # This happens if you don't have a selected piece. The purpose is to select a piece
      if @selected == nil
        # A loop to check which, if any, piece that will be selected. Would probably be better with an .any? method
        @pieces.each do |piece|
          # Checks if the mouse coordinates equal that of one of the pieces. No "else" statement
          if (mouse_x/60).to_i == piece.x_value && (mouse_y/60).to_i-1 == piece.y_value
            # Checks if the turn is equal to that of the piece that was clicked.
            if @turn%2 == piece.owner
              # Sets the piece to @selected, since it is in the right mouse coordinates and the right turn
              @selected = piece
              ### p @selected
              @highlight = []
              # Fix with the 3x2 arrays
              @selected.moves.each do |line|
                line.each do |move|
                  p move[0]
                  p move[1]
                  # p move[2]
                  p move[3]
                  # Checks if the moves for the @selceted piece are eligible
                  if @selected.x_value + move[0] <= 7 && @selected.x_value + move[0] >= 0 && @selected.y_value + move[1] <= 7 && @selected.y_value + move[1] >= 0
                    # Sets @highlight if the move location is not obstructed by a friendly piece
                    if @pieces.any? { |occupied| [occupied.x_value,occupied.y_value,occupied.owner] == [@selected.x_value+move[0],@selected.y_value+move[1],@selected.owner] }
                      # Makes sure that the line of moves are "broken" (to fix object collision) unless the selected type of the piece is cavalry,occupied.owner,@selected.owner
                      unless @selected.class == Cavalry
                        break
                      end
                      ### p ["sel", @selected.x_value+move[0],@selected.y_value+move[1],@selected.owner]
                    # Checks if any shield have the same x and y value as the move, as well as checking to make sure it's a different owner and checking if the shield is facing the same way as the attack
                    elsif @shields.any? { |protected| [protected[0],protected[1],protected[3],(protected[2]+180)%360] == [(@selected.x_value+move[0]).to_i,(@selected.y_value+move[1]).to_i,(@selected.owner+1)%2,(@selected.angle+move[3])%360] }
                      # protected[2],,(@selected.angle+180)%360
                      unless @selected.class == Cavalry
                        break
                      end
                      @highlight << [@selected.x_value+move[0],@selected.y_value+move[1]+1,@selected.owner,move[2]]
                    # move[2] is to check if it's a move which isn't allowed to attack. The any? method doesn't contain the owner in that case since you aren't allowed to attack the opponent if move[2] == true
                    elsif move[2] && @pieces.any? { |occupied| [occupied.x_value,occupied.y_value] == [@selected.x_value+move[0],@selected.y_value+move[1]] }
                      break
                    # Makes sure that object collision also works for enemy units
                    elsif @pieces.any? { |occupied| [occupied.x_value,occupied.y_value,(occupied.owner+1)%2] == [@selected.x_value+move[0],@selected.y_value+move[1],@selected.owner] }
                      @highlight << [@selected.x_value+move[0],@selected.y_value+move[1]+1,@selected.owner,move[2]]
                      unless @selected.class == Cavalry
                        break
                      end
                    else
                      ### p [@selected.x_value+move[0],@selected.y_value+move[1]+1,@selected.owner,move[2]]
                      @highlight << [@selected.x_value+move[0],@selected.y_value+move[1]+1,@selected.owner,move[2]]
                    end
                  end
                end
              end
              # @selected.moves.each_with_index do |move,i|
              #   # Checks if the moves for the @selceted piece are eligible
              #   if @selected.x_value + move[0] <= 7 && @selected.x_value + move[0] >= 0 && @selected.y_value + move[1] <= 7 && @selected.y_value + move[1] >= 0
              #     # Sets @highlight if the move location is not obstructed by a friendly piece
              #     unless @pieces.any? { |occupied| [occupied.x_value,occupied.y_value,occupied.owner] == [@selected.x_value+move[0],@selected.y_value+move[1],@selected.owner] }
              #       ### p ["sel", @selected.x_value+move[0],@selected.y_value+move[1],@selected.owner]
              #       @highlight << [@selected.x_value+move[0],@selected.y_value+move[1]+1,@selected.owner]
              #     end
              #   end
              # end
            else
              # TODO do something if it is the wrong turn
              #wrong turn
            end
          end
        end
      # This happens if you have a selected piece. The purpose is to move or attack a piece
      else
        # A loop to see if you clicked an eligible spot (an @highlight).
        @highlight.each do |current|
          if [(mouse_x/60).to_i,(mouse_y/60).to_i] == [current[0],current[1]]
            # Sets an @do variable for the move that you will make, that contains the coordinates and possibly the index of the attacked piece.
            @do = [true,current[0],(current[1]-1).to_i,nil,current[3]]
            @pieces.each_with_index do |piece, i|
              # Sees if the move is an attack or not
              if [piece.x_value,piece.y_value] == [@do[1],@do[2]]
                # Sets the index of the attacked piece to @do[3]
                @do[3] = i
              end
            end
          end
        end
      end
    end

    # Executes the @do-move when you press spacebar
    if Gosu::button_down?(Gosu::KbSpace) && @do[0] == true
      # Deletes the piece that was in the position where you move, if the @do-move it's an attack.
      if @do[3] != nil
        @pieces.delete_at(@do[3])
      end
      # Puts the @selected piece where you wanted it to move. The expression can't be simplified since 'nil != false'
      if @do[4] != false
        @selected.warp(@do[1],@do[2])
      end
      # Resets all temporary variables
      @selected = nil
      @highlight = []
      @do = [false,0,0,0]
      # Adds a turn
      @turn += 1
      shield
    end

    # Cancels the selection
    if Gosu::button_down?(Gosu::MsRight) || Gosu::button_down?(Gosu::KbEscape) then
      # Resets all temporary variables
      @selected = nil
      @highlight = []
      @do = [false,0,0,0]
    end

    # def button_down(id)
    #   if id == Gosu::KbEscape
    #     close
    #   end
    # end
    # @player.move
    # @player.collect_stars(@stars)
    #
    # if rand(100) < 4 and @stars.length < 25
    #   @stars << Star.new(@star_anim)
    # end

  end

  def draw
    # Draws the piece via its own draw method
    for piece in @pieces
      piece.draw
    end
    # Draws the @highlight squares and checks which colour to draw with the @highlight[2], which is the owner of the @selected piece
    for highlight in @highlight
      if highlight[2] == 0
        @square_blue.draw((highlight[0])*60,highlight[1]*60, ZOrder::Highlight)
      else
        @square_red.draw((highlight[0])*60,highlight[1]*60, ZOrder::Highlight)
      end
    end
    for shield in @shields
      Gosu::Image.new('./media/shield.png').draw_rot((shield[0]+0.5)*60,(shield[1]+1.5)*60, ZOrder::Highlight,shield[2])
    end
    # Draw explanation window if it is the wrong turn

    # Draw confirmation window if you press a piece

    # Draws cursor and background
    @cursor.draw(self.mouse_x, self.mouse_y, ZOrder::Cursor)
    @background_image.draw(0, 0, ZOrder::Background)
  end
end

class Piece
  def initialize(x, y, angle, owner)
    @x = x
    @y = y
    @angle = angle
    @owner = owner
  end

  # Contains a bundle of methods that makes it possible to call the owner, x_value and y_value
  def owner
    @owner
  end

  def angle
    @angle
  end

  def x_value
    @x
  end

  def y_value
    @y
  end

  # A method to switch places for the Piece
  def warp(x, y)
    @x = x
    @y = y
  end

  # A method that might be used in the future, but isn't currently
  # def score
  #   @score
  # end

  # The .draw method for the Piece, that uses the .image method in all subclasses
  def draw
    self.image.draw_rot((@x+0.5)*60, (@y+1.5)*60, ZOrder::Piece, @angle)
  end

end

class Warrior < Piece
  # Returns the media file for the current subclass
  def image
    if self.owner == 0
      Gosu::Image.new('./media/warrior_blue.png')
    else
      Gosu::Image.new('./media/warrior_red.png')
    end
  end

  # Returns all moves for the current subclass. It also uses a multiplier Degree -> Radian conversion multiplier, because gosu and ruby uses different systems. This is needed for non-symmetric pieces and for shield attacking
  def moves
    [[[-1*(Math.cos(@angle*Math::PI/180)).to_i,0,nil,90],[-2*(Math.cos(@angle*Math::PI/180)).to_i,0,nil,90],[-3*(Math.cos(@angle*Math::PI/180)).to_i,0,nil,90]],
     [[1*(Math.cos(@angle*Math::PI/180)).to_i,0,nil,270],[2*(Math.cos(@angle*Math::PI/180)).to_i,0,nil,270],[3*(Math.cos(@angle*Math::PI/180)).to_i,0,nil,270]],
     [[0,1*(Math.cos(@angle*Math::PI/180)).to_i,nil,0],[0,2*(Math.cos(@angle*Math::PI/180)).to_i,nil,0],[0,3*(Math.cos(@angle*Math::PI/180)).to_i,nil,0]]]
  end
end

class Cavalry < Piece
  # Returns the media file for the current subclass
  def image
    if self.owner == 0
      Gosu::Image.new('./media/knight_blue.png')
    else
      Gosu::Image.new('./media/knight_red.png')
    end
  end

  # Returns all moves for the current subclass.
  def moves
    [[[-2,-2,nil,135]],
     [[-3,-3,nil,135]],
     [[-4,-4,nil,135]],
     [[2,2,nil,315]],
     [[3,3,nil,315]],
     [[4,4,nil,315]],
     [[-2,2,nil,45]],
     [[-3,3,nil,45]],
     [[-4,4,nil,45]],
     [[2,-2,nil,225]],
     [[3,-3,nil,225]],
     [[4,-4,nil,225]]]
  end
end

class General < Piece
  # Returns the media file for the current subclass
  def image
    if self.owner == 0
      Gosu::Image.new('./media/general_blue.png')
    else
      Gosu::Image.new('./media/general_red.png')
    end
  end

  # Returns all moves for the current subclass.
  def moves
    [[[-1*(Math.cos(@angle*Math::PI/180)).to_i,0,nil,90],[-2*(Math.cos(@angle*Math::PI/180)).to_i,0,nil,90]],
     [[1*(Math.cos(@angle*Math::PI/180)).to_i,0,nil,270],[2*(Math.cos(@angle*Math::PI/180)).to_i,0,nil,270]],
     [[0,1*(Math.cos(@angle*Math::PI/180)).to_i,nil,0],[0,2*(Math.cos(@angle*Math::PI/180)).to_i,nil,0]],
     [[0,-1*(Math.cos(@angle*Math::PI/180)).to_i,nil,180],[0,-2*(Math.cos(@angle*Math::PI/180)).to_i,nil,180]]]
  end
end

class Archer < Piece
  # Returns the media file for the current subclass
  def image
    if self.owner == 0
      Gosu::Image.new('./media/archer_blue.png')
    else
      Gosu::Image.new('./media/archer_red.png')
    end
  end

  # Returns all moves for the current subclass. Also specifies if it is a only moving move(true), or a only attacking move (false).
  def moves
    [[[-1*(Math.cos(@angle*Math::PI/180)).to_i,0,true,90]],[[1*(Math.cos(@angle*Math::PI/180)).to_i,0,true,270]],[[0,1*(Math.cos(@angle*Math::PI/180)).to_i,true,0]],[[0,-1*(Math.cos(@angle*Math::PI/180)).to_i,true,180]],
     [[-3*(Math.cos(@angle*Math::PI/180)).to_i,0,false,90]],[[3*(Math.cos(@angle*Math::PI/180)).to_i,0,false,270]],[[0,3*(Math.cos(@angle*Math::PI/180)).to_i,false,0]],[[0,-3*(Math.cos(@angle*Math::PI/180)).to_i,false,180]],
     [[1*(Math.cos(@angle*Math::PI/180)).to_i,-3*(Math.cos(@angle*Math::PI/180)).to_i,false,180]],[[-1*(Math.cos(@angle*Math::PI/180)).to_i,-3*(Math.cos(@angle*Math::PI/180)).to_i,false,180]],[[1*(Math.cos(@angle*Math::PI/180)).to_i,3*(Math.cos(@angle*Math::PI/180)).to_i,false,0]],[[-1*(Math.cos(@angle*Math::PI/180)).to_i,3*(Math.cos(@angle*Math::PI/180)).to_i,false,0]],
     [[3*(Math.cos(@angle*Math::PI/180)).to_i,-1*(Math.cos(@angle*Math::PI/180)).to_i,false,270]],[[-3*(Math.cos(@angle*Math::PI/180)).to_i,-1*(Math.cos(@angle*Math::PI/180)).to_i,false,90]],[[3*(Math.cos(@angle*Math::PI/180)).to_i,1*(Math.cos(@angle*Math::PI/180)).to_i,false,270]],[[-3*(Math.cos(@angle*Math::PI/180)).to_i,1*(Math.cos(@angle*Math::PI/180)).to_i,false,90]],
     [[2*(Math.cos(@angle*Math::PI/180)).to_i,-2*(Math.cos(@angle*Math::PI/180)).to_i,false,225]],[[-2*(Math.cos(@angle*Math::PI/180)).to_i,-2*(Math.cos(@angle*Math::PI/180)).to_i,false,135]],[[2*(Math.cos(@angle*Math::PI/180)).to_i,2*(Math.cos(@angle*Math::PI/180)).to_i,false,315]],[[-2*(Math.cos(@angle*Math::PI/180)).to_i,2*(Math.cos(@angle*Math::PI/180)).to_i,false,45]]]
  end
end

class Paladin < Piece
  # Returns the media file for the current subclass
  def image
    if self.owner == 0
      Gosu::Image.new('./media/paladin_blue.png')
    else
      Gosu::Image.new('./media/paladin_red.png')
    end
  end

  # Returns all moves for the current subclass. Also specifies if it is a only moving move(true), or a only attacking move (false). It also uses a multiplier Degree -> Radian conversion multiplier, because gosu and ruby uses different systems. This is only needed when the piece can't move symmetrically in X and Y, such as this case
  def moves
    [[[-1*(Math.cos(@angle*Math::PI/180)).to_i,0,true,90]],
     [[1*(Math.cos(@angle*Math::PI/180)).to_i,0,true,270]],
     [[0,1*(Math.cos(@angle*Math::PI/180)).to_i,true,0]]]
  end

  def shield
    shields = []
    shields << [self.x_value-1*Math.cos(self.angle*Math::PI/180).to_i,self.y_value-1*Math.sin(self.angle*Math::PI/180).to_i,self.angle,self.owner]
    shields << [self.x_value,self.y_value,self.angle,self.owner]
    shields << [self.x_value+1*Math.cos(self.angle*Math::PI/180).to_i,self.y_value+1*Math.sin(self.angle*Math::PI/180).to_i,self.angle,self.owner]
    shields
  end
end


# class Star
#   attr_reader :x, :y
#
#   def initialize(animation)
#     @animation = animation
#     @color = Gosu::Color.new(0xff_000000)
#     @color.red = rand(256 - 40) + 40
#     @color.green = rand(256 - 40) + 40
#     @color.blue = rand(256 - 40) + 40
#     @x = rand * 1366
#     @y = rand * 768
#   end
#
#   def draw
#     img = @animation[Gosu::milliseconds / 100 % @animation.size];
#     img.draw(@x - img.width / 2.0, @y - img.height / 2.0,
#              ZOrder::Stars, 1, 1, @color, :add)
#   end
# end