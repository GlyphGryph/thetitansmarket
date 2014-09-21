class Trade < ActiveRecord::Base
  has_one :proposal, :as => :content

  has_many :trade_possessions

  has_many :trade_asked_knowledges, :dependent => :destroy
  has_many :trade_offered_knowledges, :dependent => :destroy

  has_one :sender, :through => :proposal, :class_name => "Character"
  has_one :receiver, :through => :proposal, :class_name => "Character"

  def acceptable?
    return true
  end

  def accept
    # The possessions offered are the ones we gain, the proffessions asked are the ones we lose
    asked_possessions = self.trade_possessions.asked
    offered_possessions = self.trade_possessions.offered
    asked_knowledges = self.trade_asked_knowledges
    offered_knowledges = self.trade_offered_knowledges
    sender_message = ["You traded with #{receiver.name}."]
    receiver_message = ["You traded with #{sender.name}."]
    errors = []
    success = true
    # We want to do this as a transaction - if there's an error changing any of these, we want to roll them all back
    begin
      ActiveRecord::Base.transaction do
        sender = proposal.sender
        receiver = proposal.receiver
        # Insure all items are valid tradeables
        asked_possessions.each do |possession_id|
         # if(character_possession.character != receiver)
         #   errors << "#{sender.name} asked for #{character_possession.get.name} ##{character_possession.id}, but #{receiver.name} does not possess that item."
         #   success=false
         # end
        end
        offered_possessions.each do |character_possession|
         # if(character_possession.character != sender)
         #   errors << "#{sender.name} asked for #{character_possession.get.name} ##{character_possession.id}, but #{receiver.name} does not possess that item."
         #   success=false
         # end
        end
        
        # Insure all knowledges can be taught
        # Insure characters have enough vigor remaining to teach and learn all knowledges
        vigor_cost = 0
        asked_knowledges.each do |trade_knowledge|
          vigor_cost += trade_knowledge.duration
          # Fails if sender already has requested knowledge
          if(sender.knows?(trade_knowledge.get.id))
            errors << "#{sender.name} asked to be taught #{trade_knowledge.get.name}, but #{sender.name} already knows this."
            success=false
          end
          # Fails is receiver does not know this
          if(!receiver.knows?(trade_knowledge.get.id))
            errors << "#{sender.name} asked to be taught #{trade_knowledge.get.name}, but #{receiver.name} does not know this."
            success=false
          end
        end

        offered_knowledges.each do |trade_knowledge|
          vigor_cost += trade_knowledge.duration
          # Fails if receiver already has requested knowledge
          if(receiver.knows?(trade_knowledge.get.id))
            errors << "#{sender.name} offered to teach #{trade_knowledge.get.name}, but #{receiver.name} already knows this."
            success=false
          end
          # Fails is sender does not know this
          if(!sender.knows?(trade_knowledge.get.id))
            errors << "#{sender.name} offered to teach #{trade_knowledge.get.name}, but #{sender.name} does not know this."
            success=false
          end
        end

        if(sender.vigor < vigor_cost)
          errors << "#{sender.name} did not have enough vigor to participate in the lessons."
          success=false
        end
        if(receiver.vigor < vigor_cost)
          errors << "#{receiver.name} did not have enough vigor to participate in the lessons."
          success=false
        end


        # Conduct Trade
        if(success)
          asked_possessions.each do |character_possession|
           # character_possession.character = sender
           # possession_name = character_possession.get.name
           # sender_message << "You gained a #{possession_name}."
           # receiver_message << "You lost your #{possession_name}."
           # character_possession.save!
          end
          offered_possessions.each do |character_possession|
           # character_possession.character = receiver
           # possession_name = character_possession.get.name
           # sender_message << "You lost your #{possession_name}."
           # receiver_message << "You gained a #{possession_name}."
           # character_possession.save!
          end

          # Conduct Knowledges
          asked_knowledges.each do |trade_knowledge|
            knowledge_id = trade_knowledge.knowledge_id
            sender.learn(knowledge_id)
            sender.change_vigor(-trade_knowledge.duration)
            receiver.change_vigor(-trade_knowledge.duration)
            sender_message << "You learned #{trade_knowledge.get.name}."
            receiver_message << "You taught #{trade_knowledge.get.name}."
          end

          offered_knowledges.each do |trade_knowledge|
            knowledge_id = trade_knowledge.knowledge_id
            receiver.learn(knowledge_id)
            sender.change_vigor(-trade_knowledge.duration)
            receiver.change_vigor(-trade_knowledge.duration)
            sender_message << "You taught #{trade_knowledge.get.name}."
            receiver_message << "You learned #{trade_knowledge.get.name}."
          end
        end
      end
    rescue => e      
      success = false
      raise e
    end
    if(!success)
      sender_message = sender_message+errors
      receiver_message = receiver_message+errors
    end
    sender.recent_history << sender_message.join(" ")
    sender.save!
    receiver.recent_history << receiver_message.join(" ")
    receiver.save!
    return success
  end

  def decline
    return true
  end

  def cancel
    return true
  end

  def name_for_sender
    return "Trade Offer to "+self.receiver.name
  end

  def name_for_receiver
    return "Trade Offer from "+self.sender.name
  end
end
