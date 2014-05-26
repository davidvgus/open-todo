require 'spec_helper'

describe Api::ListsController do

  before do
    List.destroy_all
  end

  describe "create" do

    xit "requires authentication" do
      user = FactoryGirl.create(:user)
      post :create, user_id: user.id
      expect(response.status).to eql 403 # forbidden
    end

    context "with correct user's password" do
      xit "takes a list name, creates it if it doesn't exist, and returns false if it does"
    end

    context "without correct user's password" do
      xit "it errors"
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
