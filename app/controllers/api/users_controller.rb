class Api::UsersController < ApiController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.all
    render json: @users, each_serializer: UserSerializer
  end

  def show
    render json: UserSerializer.new(@user).to_json
  end

  def create
    @new_user = User.new(user_params)

    if @new_user.save
      render json: NewUserSerializer.new(@new_user).to_json
    else
      message = "User was not created"
      error(500, message)
    end
  end

  def update
    #if @user.update(user_params)
      #redirect_to @user, notice: 'User was successfully updated.'
    #else
      #render action: 'edit'
    #end
  end

  def destroy
    @user.destroy
    render json: DeletedUserSerializer.new(@user).to_json
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:new_user).permit(:username, :password)
  end
end
