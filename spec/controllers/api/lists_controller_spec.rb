require 'spec_helper'

describe Api::ListsController do
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
        3.times do |n|
          FactoryGirl.create(:list, permissions: "#{%w{ private, open}.sample}", name: "private or open#{n}")
          FactoryGirl.create(:list, permissions: "viewable", name: "viewable list desc.#{n}")
        end
        get :index
        expect(JSON.parse(response.body)).to eql(
          {"something" => "somethingelse"}
        )
      end

      xit "with user_id returns all visible and open lists"
    end
  end
end
