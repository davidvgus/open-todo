require 'spec_helper'

describe User do
  describe "authenticate?" do

    let(:user) { FactoryGirl.build(:user, password: 'password') }

    it "tests for password parity" do
      expect(user.authenticate?('password')).to be true
      expect(user.authenticate?('wrongpassword')).not_to be true
    end
  end

  describe "can?" do

    before do
      @user = FactoryGirl.create(:user)
      @list = FactoryGirl.create(:list, user: @user)
    end

    it "allows owners to do whatever they want" do
      expect(@list.user).to be @user
      [:view, :edit].each { |action|
        expect(@user.can?(action, @list)).to be true
      }
    end

    it "toggles abilities by permissions" do
      user2 = FactoryGirl.create(:user)
      expect(@list.user).not_to be user2
      expect(@list.permissions).to eql 'private'

      expect([:view, :edit].all?{ |action|
        user2.can?(action, @list)
      }).to be false

      @list.permissions = 'visible'

      expect(user2.can?(:view, @list)).to be true
      expect(user2.can?(:edit, @list)).to be false

      @list.permissions = 'open'

      expect([:view, :edit].all?{ |action|
        user2.can?(action, @list)
      }).to be true
    end
  end

end
