class Player
  def play_turn(warrior)
    # add your code here
    @health ||= warrior.health
    @toccato_il_muro ||= false
    @toccato_il_muro = true if warrior.feel(:backward).wall?
    dont_rest = warrior.health < @health
          
    #check look
    look = warrior.look
    if look[0].enemy?
      if warrior.health < 15 and !dont_rest
        warrior.walk!(:backward)
      else
        warrior.attack!
      end
    else
      if look[1].enemy? or (look[1].empty? and look[2].enemy?)
        warrior.shoot!
      elsif warrior.health != 20 and !dont_rest
        warrior.rest!
      elsif warrior.health < 15
        warrior.walk!(:backward)
      else
        if warrior.captive_to_rescue?
          warrior.rescue!(warrior.captive_to_rescue?)
        else
          if warrior.feel.wall?
            warrior.pivot!
          else
            if !@toccato_il_muro
              warrior.walk!(:backward)
            else
              warrior.walk!
            end
          end
        end
      end
    end
    @health = warrior.health
  end
end
class RubyWarrior::Turn
  def directions
    [:forward, :backward, :right, :left]
  end
  def captive_to_rescue?
    directions.each do |dir|
      return dir if self.feel(dir).captive?
    end
    return false
  end
end
