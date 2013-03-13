class Player
  def play_turn(warrior)
    # add your code here
    @health ||= warrior.health
    dont_rest = warrior.health < @health
    if warrior.feel.enemy?
#      if warrior.health < 5
#        warrior.walk!(:backward)
#      else
        warrior.attack!
#      end
    else
      if warrior.health != 20 and !dont_rest
        warrior.rest!
      else
        warrior.walk!
      end
    end
    @health = warrior.health
  end
end
