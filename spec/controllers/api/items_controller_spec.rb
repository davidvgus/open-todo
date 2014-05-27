require 'spec_helper'

describe Api::ItemsController do
  before do
    List.destroy_all
  end

  describe "create" do
    context "without quthentication" do
      it "fails" do
        list = FactoryGirl.create(:list)
        message = "This was supposed to be a failed message"
        json = {:list_id => list.id, :format => :json, :item => {:description => message} }
        post :create, json
        expect(response.status).to eql 403 # forbidden
        expect(JSON.parse(response.body)).to eql( {
          "response_type"=>"ERROR",
          "message"=>"Permission Denied!"
        })
      end
    end

    context "with authentication" do
      before do
        with_authentication
      end

      it "Succesfully creates item" do
        list = FactoryGirl.create(:list)
        json = {:list_id => list.id, :format => 'json', :item => {:description => "test item"}}
        post :create, json
        expect(response.status).to eql 200
        expect(JSON.parse(response.body)).to eql(
          {"item"=>{"id"=>list.items.first.id, "description"=>"test item", "completed"=>false}}
        )
      end
    end
  end


  describe "destroy" do
    context "without quthentication" do
      it " fails" do
        item = FactoryGirl.create(:item, :description => "item for destroying")
        json = {:format => :json, :id => item.id}
        delete :destroy, json
        expect(response.status).to eql 403
        expect(JSON.parse(response.body)).to eql( {
          "response_type"=>"ERROR",
          "message"=>"Permission Denied!"
        })
      end
    end

    context "with authentication" do
      before do
        with_authentication
      end

      it " succeeds" do
        item = FactoryGirl.create(:item, :description => "item for destroying")
        json = {:format => :json, :id => item.id}
        delete :destroy, json
        expect(response.status).to eql 200
        expect(JSON.parse(response.body)).to eql( {
          "item"=>{"id"=>item.id,
            "description"=>"item for destroying",
            "completed"=>true}
        })

      end
    end
  end

end
