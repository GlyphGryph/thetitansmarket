class DrawPool
  def initialize
    @pool = {}
    @total = 0
  end
  
  def add_tickets(id, amount=1)
    if(@pool[id])
      @pool[id]+=amount
    else
      @pool[id]=amount
    end
    @total += amount
  end

  def draw
    if(@total <= 0)
      return nil
    else
      p "picking"
      pick = rand(1..@total)
      p pick.to_s
      chosen = nil
      @pool.each_pair do |key, value|
        p "pairing... #{pick} vs. #{key} : #{value}"
        if(pick <= value)
          p "chosen!"
          chosen = key
          @pool[key] = value-1
          break
        else
          p "moving on..."
          pick -= value
        end
      end
      return chosen
    end
  end
end
