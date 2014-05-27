class Api::ListsController < ApiController
  before_action :set_user, only: [:create,:update, :destroy]
  before_action :set_list, only: [:show, :update, :destroy]
  before_action :check_auth

  def show
    items = @list.items
    render json: items, each_serializer: ItemSerializer
  end

  def index

    if params.has_key?(:user_id)
      lists = List.where("user_id = ? OR permissions = ? OR permissions = ?", params[:user_id], "open", "viewable").order("id ASC")
      render json: lists, each_serializer: IndexListSerializer
    else
      lists = List.where(permissions: "viewable")
      render json: lists, each_serializer: IndexListSerializer
    end
  end

  def create
    list = List.new(list_params)
    list.user_id = @user.id

    if list.save
      render json: ListSerializer.new(list).to_json
    else
      error(500, list.errors.messages)
    end
  end

  def update
    if list_params[:permissions] && !List.permission_options.include?(list_params[:permissions])
      return error(422, "Wrong permissions type")
    end

    if @list.update(list_params)
      render json: UpdatedListSerializer.new(@list).to_json
    else
      error(422, @list.errors.messages)
    end
  end

  def destroy
    if @list.destroy
      render json: ListSerializer.new(@list).to_json
    else
      error(422, "could not destroy list")
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_list
    @list = List.find(params[:id])
  end

  def list_params
    params.require(:list).permit(:name, :user_id, :permissions)
  end
end
