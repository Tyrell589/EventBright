class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    @comment = @commentable.comments.new(comment_params)
    @comment.commenter = current_user
    if @comment.save 
      flash[:success] = "Your comment has been posted"
      redirect_back(fallback_location: root_path)
    else
      flash[:danger] = "Your comment hasn't been posted"
      redirect_back(fallback_location: root_path)
    end
  end

private

  def comment_params
    params.require(:comment).permit(:content)
  end  
end
