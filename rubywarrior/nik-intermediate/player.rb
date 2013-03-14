class Player
  def play_turn(warrior)
    # add your code here
    @health ||= warrior.health
    @toccato_il_muro ||= false
    @toccato_il_muro = true if warrior.feel(:backward).wall?
    dont_rest = warrior.health < @health
    @n_enemy ||= warrior.n_enemy
    if warrior.captive_to_save? and 
      (warrior.health > 8 or @n_enemy < 3)
      if warrior.feel(warrior.direction_of(warrior.captive_to_save?)).captive?
        warrior.rescue!(warrior.direction_of(warrior.captive_to_save?))
      elsif warrior.feel(warrior.direction_of(warrior.captive_to_save?)).enemy?
        warrior.attacca!(:dir => warrior.direction_of(warrior.captive_to_save?),
                        :dont_rest => dont_rest)
      else
        warrior.walk!(warrior.direction_of(warrior.captive_to_save?))
      end
    elsif warrior.enemy_vicini?
      dir,pos = warrior.where_enemy?
      case pos
        when 0
          warrior.attacca!(:dir => dir, :dont_rest => dont_rest)
        when 1,2
          warrior.shoot!(dir)
      end
    else
      if warrior.see_archer?
        dir,pos = warrior.see_archer?
        warrior.shoot!(dir)
      else
        if warrior.health != 20
          warrior.rest!
        else
          if warrior.captive_to_rescue?
            warrior.rescue!(warrior.captive_to_rescue?)
          else
            #if warrior.feel.wall?
            #  warrior.pivot!
            #else
            warrior.walk!(warrior.where_walk?)
            #end
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
  def inverse_of(dir)
    case dir
    when :backward
      return :forward
    when :forward
      return :backward
    when :left
      return :right
    when :right
      return :left
    end
  end
  def drop_bomb?(dir)
    num = 0
    self.look(dir).each do |space|
      num += 1 if space.enemy?
    end
    if num > 1 and self.health > 4
      return true
    else
      return false
    end
  end
  def attacca!(opts = {})
    dir = opts[:dir]
    dont_rest = opts[:dont_rest]
    if self.n_enemy_vicini > 1
      dir,pos = self.where_enemy?(directions - [dir])
      self.bind!(dir)
    elsif self.health < 15 and !dont_rest
      self.walk!(inverse_of(dir))
    elsif self.drop_bomb?(dir)
      self.detonate!(dir)
    else
      self.attack!(dir)
    end
  end
  def captive_to_save?
    self.listen.each do |space|
      if space.ticking?
        if self.feel(self.direction_of(space)).enemy?
          return nil
        else
          return space
        end
      end
    end
    return nil
  end
  def where_walk?
    list = self.listen
    if list.length > 0
      if self.feel(self.direction_of(list[0])).stairs?
        dirs = directions
        dirs.delete(self.direction_of(list[0]))
        return dirs[rand(0..2)]
      else
        return self.direction_of(list[0])
      end
    else
      return self.direction_of_stairs
    end
  end
  def captive_to_rescue?
    directions.each do |dir|
      return dir if self.feel(dir).captive?
    end
    return false
  end
  def where_enemy?(dirs = nil)
    dirs ||= directions
    (0..(self.look(:forward).length - 1)).each do |pos|
      dirs.each do |dir|
        if self.look(dir)[pos].enemy?
          return dir,pos
        end
      end
    end
    return nil
  end
  def see_archer?
    (0..(self.look(:forward).length - 1)).each do |pos|
      directions.each do |dir|
        if self.look(dir)[pos].to_s == "Archer"
          return dir,pos
        end
      end
    end
    return nil
  end
  def enemy_vicini?
    dir,pos = self.where_enemy?
    return pos == 0
  end
  def n_enemy_vicini
    num = 0
    directions.each do |dir|
      if self.look(dir)[0].enemy?
        num += 1
      end
    end
    return num
  end
  def n_enemy(dirs = nil)
    dirs ||= directions
    num = 0
    (0..(self.look(:forward).length - 1)).each do |pos|
      dirs.each do |dir|
        if self.look(dir)[pos].enemy?
          num += 1
        end
      end
    end
    return num
  end
end
