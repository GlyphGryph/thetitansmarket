class ProposalsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_character
  before_filter :check_valid_owner, :except => :show
  
  def index
    @new_proposals = []
    @world = @character.world

    sent_proposals = @character.sent_proposals.where(:turn => @world.turn).sort_by(&:created_at)
    new_sent_proposals = sent_proposals.select{|proposal| !proposal.viewed_by?(@character)}
    sent_proposals -= new_sent_proposals

    received_proposals = @character.received_proposals.where(:turn => @world.turn).sort_by(&:created_at)
    new_received_proposals = received_proposals.select{|proposal| !proposal.viewed_by?(@character)}
    received_proposals -= new_received_proposals

    previous_sent_proposals = @character.sent_proposals.where(:turn => (@world.turn-1)).sort_by(&:created_at)
    previous_received_proposals = @character.received_proposals.where(:turn => (@world.turn-1)).sort_by(&:created_at)

    @proposals_hash = [
      {:label => 'Newly Received or Updated', :proposals => new_sent_proposals+new_received_proposals},
      {:label => 'Received', :proposals => received_proposals},
      {:label => 'Sent', :proposals => sent_proposals},
      {:label => 'Previous Proposals', :proposals => previous_sent_proposals+previous_received_proposals}
    ]

    new_sent_proposals.each do |proposal|
      proposal.mark_read_for(@character)
    end

    new_received_proposals.each do |proposal|
      proposal.mark_read_for(@character)
    end
  end

  # When we know the proposal type, but not who to send it to yet
  def new_target
    @proposal_type = params[:proposal_type]
    @other_characters = @character.world.characters.reject{|other_character| other_character==@character}
  end

  # For assigning the details of a proposal after we identify a target
  def new_details
    @proposal_type = params[:proposal_type]
    @target = Character.find(params[:target_id])
    if(@proposal_type == 'Trade')
      @sender_possessions = @character.character_possessions
      @receiver_possessions = @target.character_possessions
      
      # Remove already known knowledge from the teachables lists
      sender_knowledges = @character.knowledges.map(&:get)
      receiver_knowledges = @target.knowledges.map(&:get)
      @sender_teachables = sender_knowledges - receiver_knowledges
      @receiver_teachables = receiver_knowledges - sender_knowledges
      # Add information on remaining lessons required
      @sender_teachables.map! do |knowledge|
        attributes = {:id => knowledge.id, :name => knowledge.name}
        attributes[:progress] = @target.knowledge_progress(knowledge.id)
        attributes[:remaining_progress] = knowledge.components - attributes[:progress]
        attributes
      end
      @receiver_teachables.map! do |knowledge|
        attributes = {:id => knowledge.id, :name => knowledge.name}
        attributes[:progress] = @character.knowledge_progress(knowledge.id)
        attributes[:remaining_progress] = knowledge.components - attributes[:progress]
        attributes
      end
    elsif(@proposal_type == 'Interaction')
      @activities = Activity.all
    elsif(@proposal_type == 'Message')
      if(@character.knows?('gestures') && @target.knows?('gestures'))
        @gestures = Gesture.all
      end
    end
  end

  def create
    target = Character.find(params[:target_id])
    proposal_type = params[:proposal_type]
    errors = []
    success = false
    proposal = nil
    begin
      ActiveRecord::Base.transaction do
        if(proposal_type == 'Trade')
          asked_possession_ids = params[:asked_possession_ids] || []
          offered_possession_ids = params[:offered_possession_ids] || []
          asked_knowledge_ids = params[:asked_knowledge_ids] || []
          offered_knowledge_ids = params[:offered_knowledge_ids] || []
          if(!asked_possession_ids.empty? || !offered_possession_ids.empty? || !asked_knowledge_ids.empty? || !offered_knowledge_ids.empty?)
            trade = Trade.new()
            trade.asked_character_possessions = CharacterPossession.find(asked_possession_ids)
            trade.offered_character_possessions = CharacterPossession.find(offered_possession_ids)
            asked_knowledge_ids.each do |knowledge_id, attributes|
              if(attributes && attributes[:duration] && attributes[:duration].to_i > 0)
                if(@character.knows?(knowledge_id) || !target.knows?(knowledge_id))
                  errors << "You can't learn #{knowledge_id}"
                end
                TradeAskedKnowledge.new(:trade => trade, :knowledge_id => knowledge_id, :duration => attributes[:duration]).save!
              end
            end
            offered_knowledge_ids.each do |knowledge_id, duration|
              if(attributes && attributes[:duration] && attributes[:duration].to_i > 0)
                if(!@character.knows?(knowledge_id) || target.knows?(knowledge_id))
                  errors << "You can't teach #{knowledge_id}"
                end
                TradeAskedKnowledge.new(:trade => trade, :knowledge_id => knowledge_id, :duration => attributes[:duration]).save!
              end
            end
            trade.save!
            proposal = Proposal.new(:sender => @character, :receiver => target, :content => trade)
            success = proposal.save!
          else
            errors << " No asked or offered items."
          end
        elsif(proposal_type == 'Interaction')
          activity = Activity.find(params[:activity])
          if(activity)
            interaction = Interaction.new(:activity_id => activity.id)
            interaction.save!
            proposal = Proposal.new(:sender => @character, :receiver => target, :content => interaction)
            success = proposal.save!
          else
            errors << " Could not find an activity with the given id."
          end
        elsif(proposal_type == 'Message')
          components = params[:message_components]
          if(components && !components.empty?)
            all_components_good = true
            message = Message.new()
            components.transform_keys!{ |key| key.to_i }
            keys = components.keys.sort
            keys.each do |key|
              component = components[key]
              if(component['type']=="gesture")
                gesture = Gesture.find(component['value'])
                if(gesture)
                  message.add_gesture(gesture, target)
                else
                  all_components_good = false
                  errors << " Bad component #{component['value']}."
                end
              elsif(component['type']=="text")
                message.add_text(component['value'])
              else
                all_components_good = false
                errors << "Could not recognize the type of Message requested."
              end
            end

            if(all_components_good)
              message.save!
              proposal = Proposal.new(:sender => @character, :receiver => target, :content => message)
              proposal.save!
              success=true
            else
              errors << " Bad components."
            end
          else
            errors << " No message components provided."
          end
        else
          errors << " Invalid proposal type."
        end
        if(!errors.empty?)
          raise "Proposal failed."
        end
      end
    rescue => e      
      errors = ["Could not make this proposal."].concat(errors)
      if(proposal && !proposal.errors.empty?)
        errors = errors.concat(proposal.errors)
      end
      success = false
    end
    respond_to do |format|
      if(success)
        format.html { redirect_to proposals_path, :notice => "Proposal sent." }
      else
        format.html { redirect_to new_proposal_details_path, :alert => errors.join(" ")}
      end
    end
  end

  def show
    @proposal = Proposal.find(params[:proposal_id])
    if(@proposal.content_type == "Trade")
      if(@proposal.receiver  == @character)
        @proposal.mark_read_for(@character)
        @character_gets = @proposal.content.offered_character_possessions
        @character_loses = @proposal.content.asked_character_possessions
        @character_learns = @proposal.content.trade_offered_knowledges
        @character_teaches = @proposal.content.trade_asked_knowledges
      elsif(@proposal.sender  == @character)
        @character_loses = @proposal.content.offered_character_possessions
        @character_gets = @proposal.content.asked_character_possessions
        @character_teaches = @proposal.content.trade_offered_knowledges
        @character_learns = @proposal.content.trade_asked_knowledges
      else
        raise "This character is not involved with this proposal."
      end
    end
  end

  def accept
    @proposal = Proposal.find(params[:proposal_id])
    if(@character.received_proposals.include?(@proposal))
      success = @proposal.accept
      respond_to do |format|
        if(success)
          format.html { redirect_to character_overview_path, :notice => "Proposal accepted." }
        else
          format.html { redirect_to character_overview_path, :alert => @proposal.errors.full_messages.to_sentence}
        end
      end
    else
      redirect_to :proposals, :alert => "You cannot accept a proposal that is not yours."
    end
  end

  def decline
    @proposal = Proposal.find(params[:proposal_id])
    if(@proposal.receiver == @character)
      success = @proposal.decline
      respond_to do |format|
        if(success)
          format.html { redirect_to proposals_path, :notice => "Proposal declined." }
        else
          format.html { redirect_to proposals_path, :alert => @proposal.errors.full_messages.to_sentence}
        end
      end
    else
      redirect_to :proposals, :alert => "You cannot decline a proposal that is not yours."
    end
  end

  def cancel 
    @proposal = Proposal.find(params[:proposal_id])
    if(@proposal.sender == @character)
      success = @proposal.cancel
      respond_to do |format|
        if(success)
          format.html { redirect_to proposals_path, :notice => "Proposal declined." }
        else
          format.html { redirect_to proposals_path, :alert => @proposal.errors.full_messages.to_sentence}
        end
      end
    else
      redirect_to :proposals, :alert => "You cannot decline a proposal that is not yours."
    end
  end

private
  def find_character
    @character = Character.find(params[:id])
  end

  def check_valid_owner
    if(!current_user.characters.include?(@character))
      redirect_to :action => :show
    end
  end
end
