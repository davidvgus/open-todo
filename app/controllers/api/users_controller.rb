class Api::UsersController < ApiController
  before_action :set_user, only: [:show, :update, :destroy]
  before_action :check_auth
  before_filter :set_default_response_format

  def index
    users = User.all
    render json: users, each_serializer: IndexUserSerializer
  end

  def show
    render json: UserSerializer.new(@user).to_json
  end

  def create
    new_user = User.new(user_params)

    if new_user.save
      render json: UserSerializer.new(new_user).to_json
    else
      message = "User was not created"
      error(500, message)
    end
  end

  def update
    if @user.update(user_params)
      render json: UserSerializer.new(@user).to_json
    else
      message = "User not updated"
      error(500, message)
    end
  end

  def destroy
    return error(404, "Could not destroy") if User.where(:id => params[:id]).empty?

    @user.destroy
    render json: DeletedUserSerializer.new(@user).to_json
  end

  private

  def set_user
    #@user = User.find(params[:id])
    @user = User.where(:id => params[:id]).first
  end

  def user_params
    params.require(:user).permit(:username, :password)
  end

  def set_default_response_format
    request.format = :json
  end

end
