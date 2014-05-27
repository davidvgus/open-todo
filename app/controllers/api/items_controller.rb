class Api::ItemsController < ApiController
  before_action :set_item, only: [:show, :update, :destroy]
  before_action :set_list
  before_action :check_auth

  def create
    if @list.add(item_params[:description])
      item = Item.where(:list_id => @list.id, :description => item_params[:description]).first
      render json: ItemSerializer.new(item).to_json
    else
      error(422, "item could not be created")
    end
  end

  def destroy
    @item.mark_complete
    render json: ItemSerializer.new(@item).to_json
  end

  private

  def set_item
    @item = Item.find(params[:id])
  end

  def set_list
    @list = @item ? @item.list : List.find(params[:list_id])
  end

  def item_params
    params.require(:item).permit(:description, :list_id, :completed)
  end
end
