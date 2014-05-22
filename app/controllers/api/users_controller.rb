class Api::UsersController < ApiController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.all
    #render json: NewUserSerializer.new(@new_user).to_json
    render json: @users, each_serializer: UserSerializer
  end

  def show
    @lists = @user.lists
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @new_user = User.new(user_params)

    if @new_user.save
      #respond_with @new_user do |format|
        #format.json { render json: NewUserSerializer.new(@new_user).to_json }
      #end
      render json: NewUserSerializer.new(@new_user).to_json
    else
      message = "User was not created"
      error(500, message)
    end
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @user.destroy
    redirect_to users_url
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:new_user).permit(:username, :password)
  end
end
