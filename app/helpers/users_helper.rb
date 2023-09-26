module UsersHelper

  def user_avatar(user)
    if user.avatar.attached?
      user.avatar
    else
      'default-avatar.png'
    end 
  end
end
