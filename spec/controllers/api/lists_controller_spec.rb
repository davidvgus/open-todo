require 'spec_helper'

describe Api::ListsController do

  before do
    List.destroy_all
  end

  describe "create" do
    context "without authentication" do
      it "requires authentication" do
        user = FactoryGirl.create(:user)
        json = { :user_id => user.id, :format => 'json', :list => { :name => "foo" } }
        post :create, json
        expect(response.status).to eql 403 # forbidden
      end
    end

    context "with authentication" do
      before do
        with_authentication
      end

      it "takes a list name, creates it if it doesn't exist, and returns error if it does" do
        user = FactoryGirl.create(:user)
        json = { :user_id => user.id, :format => 'json', :list => { :name => "New todo name" } }
        post :create, json
        expect(response.status).to eql 200
      end

      it "fails if duplicat name is assigned" do
        user = FactoryGirl.create(:user)
        FactoryGirl.create(:list, user: user, name: "New todo name")
        json = { :user_id => user.id, :format => 'json', :list => { :name => "New todo name" } }
        post :create, json
        expect(response.status).to eql 500
      end

    end
  end

  describe "update" do
    context "without authentication" do
      it "requires authentication" do
        list = FactoryGirl.create(:list)
        json = { :user_id => list.user.id, :format => 'json', :id => list.id, :list => { :name => "foo" } }
        put :update, json
        expect(response.status).to eql 403 # forbidden
      end
    end

    context "with authentication" do
      before do
        with_authentication
      end

      it "updates list name" do
        list = FactoryGirl.create(:list, :name => "initial name for list")
        new_name = "New name from spec"
        json = { :user_id => list.user.id, :format => 'json', :id => list.id, :list => { :name => new_name } }
        put :update, json
        expect(response.status).to eql 200
        expect(JSON.parse(response.body)["updated_list"]).to eql( {
          "id" => list.id,
          "name" => new_name,
          "permissions" => "private"
        })
      end

      it "fails if unsupported permission is assigned" do
        list = FactoryGirl.create(:list)
        json = { :user_id => list.user.id, :format => 'json', :id => list.id, :list => {:permissions => "seekrit"} }
        put :update, json
        expect(response.status).to eql 422
        expect(JSON.parse(response.body)).to eql( {
          "response_type"=>"ERROR",
          "message"=>"Wrong permissions type"
        })
      end

    end
  end

  describe "destroy" do
    context "without authentication" do
      it "fails to delete and returns error" do
        list = FactoryGirl.create(:list)
        user = list.user
        json = { :user_id => user.id, :id => list.id }
        delete :destroy, json
        expect(response.status).to eql 403 # forbidden
        expect(List.exists?(list.id)).to eql true
      end
    end

    context "with authentication" do
      before do
        with_authentication
      end

      it "deletes and returns list" do
        list = FactoryGirl.create(:list, :name => "List Name")
        user = list.user
        user.update_attributes(:username => "SamwiseGamgee")
        json = { :user_id => user.id, :id => list.id }
        delete :destroy, json
        expect(response.status).to eql 200
        expect(List.exists?(list.id)).to eql false

        expect(JSON.parse(response.body)).to eql(
          "list" =>{
            "id"=>list.id,
            "name"=>"List Name",
            "user_id"=>user.id,
            "user_name"=>"SamwiseGamgee"}
        )
      end
    end
  end

  describe "index" do
    context "without authentication" do
      it "index listing fails" do
        list = FactoryGirl.create(:list)
        user = list.user
        get :index, {user_id: user.id, list_id: list.id}
        expect(response.status).to eql 403 # forbidden
      end
    end

    context "with authenticaton" do
      before do
        with_authentication
      end

      it "but without user_id returns VIEWABLE lists " do
        ids = []
        3.times do |n|
          FactoryGirl.create(:list, permissions: "#{%w{ private, open}.sample}", name: "private or open#{n}")
          viewable = FactoryGirl.create(:list, permissions: "viewable", name: "viewable list desc#{n}")
          ids << viewable.id
        end
        get :index
        expect(JSON.parse(response.body)).to eql(
          {"lists" =>
            [
              {"id"=>ids[0], "name"=>"viewable list desc0"},
              {"id"=>ids[1], "name"=>"viewable list desc1"},
              {"id"=>ids[2], "name"=>"viewable list desc2"}
            ]
          }
        )
      end

      it "with user_id returns all visible and open lists" do
        view_ids = []
        open_ids = []
        private_ids = []
        user = FactoryGirl.create(:user)
        2.times do |n|

          FactoryGirl.create(:list, permissions: "private", name: "private list desc#{n}")

          users_private_list = FactoryGirl.create(:list, user: user, permissions: "private", name: "users private list desc#{n}")
          viewable_list = FactoryGirl.create(:list, permissions: "viewable", name: "viewable list desc#{n}")
          open_list = FactoryGirl.create(:list, permissions: "open", name: "open list desc#{n}")

          private_ids << users_private_list.id
          view_ids << viewable_list.id
          open_ids << open_list.id
        end

        get :index, :user_id => user.id
        expect(JSON.parse(response.body)["lists"]).to eql(
            [
              {"id"=>private_ids[0], "name"=>"users private list desc0"},
              {"id"=>view_ids[0], "name"=>"viewable list desc0"},
              {"id"=>open_ids[0], "name"=>"open list desc0"},
              {"id"=>private_ids[1], "name"=>"users private list desc1"},
              {"id"=>view_ids[1], "name"=>"viewable list desc1"},
              {"id"=>open_ids[1], "name"=>"open list desc1"}
            ]
        )
      end
    end
  end
end
