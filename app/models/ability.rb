# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # user ||= User.new # guest user (not logged in)
    alias_action :create, :read, :update, :destroy, :to => :crud
    
    # Permissions for all users
    can [:read, :home], Event, validated: true
    
    # Additional permissions for login users
    return unless user.present? 
    # USER MODEL
    # Access restricted to current_user
    can [:show, :edit, :update], User, id: user.id 

    # EVENT MODEL
    can [:create], Event
    # Here the :show override (add more) permission that is set for all users above. A signed in user can access the show page of his events if he is administrator, without conditions (access allowed even if validated: false)
    can [:show, :update, :destroy], Event, administrator_id: user.id 
    can :submission_success, Event # Devise authorization will fire before it does

    # PARTICIPATION MODEL
    # Authorize participations if the event they belong to is owned (administrated) by the current_user. https://github.com/CanCanCommunity/cancancan/blob/develop/docs/Defining-Abilities.md#hash-of-conditions
    can :index, Participation, event: { administrator_id: user.id } # It will load @participations = Participation.accessible_by(current_ability), a collection of participations
   
    can [:create], Participation
    # A user who is already participant can't create another participation for the same event
    # This condition is based on another model (@event), so it must be loaded before the new and create 
    cannot [:create], Participation, event_id: user.attended_event_ids  # Can also be written cannot :new, Participation, event: { id: user.attended_event_ids }
    # The administrator can't create a participation for his own event 
    cannot [:create], Participation, event: { administrator_id: user.id }      
    # A User can destroy a participation only if he owes it
    can :destroy, Participation, user_id: user.id # Ability tested againt @participation loaded.

    # COMMENT MODEL
    can :create, Comment
    # can :manage, Comment, Event

    # Define abilities for the passed in user here. For example:
    #
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
