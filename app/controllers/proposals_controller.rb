class ProposalsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_character
  before_filter :check_valid_owner, :except => :show
  
  def index
    @sent_proposals = @character.sent_proposals
    @received_proposals = @character.received_proposals
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
    end
  end

  def create
    @target = Character.find(params[:target_id])
    if(params[:proposal_type] == 'Trade')
      trade = Trade.new()
      trade.asked_character_possessions = CharacterPossession.find(params[:asked_ids])
      trade.offered_character_possessions = CharacterPossession.find(params[:offered_ids])
      trade.save!
      proposal = Proposal.new(:sender_id => @character.id, :receiver => @target, :status => 'new', :content => trade)
      success = proposal.save
    else
      proposal = Proposal.new(:sender_id => @character.id, :receiver => @target, :status => 'new')
      success = proposal.save
    end
    respond_to do |format|
      if(success)
        format.html { redirect_to proposals_path, :notice => "Proposal sent." }
      else
        format.html { redirect_to proposals_path, :alert => "Could not make this proposal."}
      end
    end
  end

  def show
    @proposal = Proposal.find(params[:proposal_id])
    if(@proposal.content_type == "Trade")
      if(@proposal.receiver  == @character)
        @character_gets = @proposal.content.offered_character_possessions
        @character_loses = @proposal.content.asked_character_possessions
      elsif(@proposal.sender  == @character)
        @character_loses = @proposal.content.offered_character_possessions
        @character_gets = @proposal.content.asked_character_possessions
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
          format.html { redirect_to proposals_path, :notice => "Proposal accepted." }
        else
          format.html { redirect_to proposals_path, :alert => "Could not accept."}
        end
      end
    else
      redirect_to :proposals, :alert => "You cannot accept a proposal that is not yours."
    end
  end

  def decline
    @proposal = Proposal.find(params[:proposal_id])
    if(@character.received_proposals.include?(@proposal))
      success = @proposal.decline
      respond_to do |format|
        if(success)
          format.html { redirect_to proposals_path, :notice => "Proposal declined." }
        else
          format.html { redirect_to proposals_path, :alert => "Could not decline."}
        end
      end
    else
      redirect_to :proposals, :alert => "You cannot decline a proposal that is not yours."
    end
  end

  def cancel

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
