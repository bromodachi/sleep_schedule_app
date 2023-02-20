require 'rails_helper'

RSpec.describe "FollowerControllers", type: :request do
  describe 'POST #follower_user' do
    context 'invalid requests are made' do
      it "missing parameters all params" do
        post '/follow_user', params: {}
        expect(response.status).to eq(400)
      end

      it "missing parameters partial params: followee_id" do
        post '/follow_user', params: {follower_id: 1}
        expect(response.status).to eq(400)
      end

      it "missing parameters partial params: follower_id" do
        post '/follow_user', params: {followee_id: 1}
        expect(response.status).to eq(400)
      end

      context 'only one user exists' do
        before(:context) do
          @bob = create(:user)
        end

        it "same ids: follower_id" do
          post '/follow_user', params: {follower_id: @bob.id, followee_id: @bob.id}
          expect(response.status).to eq(400)
          expect(JSON.parse(response.body)).to eq({"error" => ["Follower is not allowed to follow themselves"]})
        end

        it "Followee do not exists" do
          post '/follow_user', params: {follower_id: @bob.id, followee_id: 2}
          expect(response.status).to eq(400)
          expect(JSON.parse(response.body)).to eq({"error" => ["Followee must exist"]})
        end
        it "Follower do not exists" do
          post '/follow_user', params: {follower_id: 2, followee_id: @bob.id}
          expect(response.status).to eq(400)
          expect(JSON.parse(response.body)).to eq({"error" => ["Follower must exist"]})
        end
      end
    end

    context 'valid requests' do
      before(:context) do
        Follower.destroy_all
        @bob = create(:user)
        @joe = create(:user, name: "Joe")
      end
      context "record doesn't exists" do
        it 'bob follows joe' do
          post '/follow_user', params: {follower_id: @bob.id, followee_id: @joe.id}
          expect(response.status).to eq(201)
          expect(Follower.count).to eq(1)
        end
      end
      context "follower already exists" do
        before(:context) do
          @follower = create(:follower, follower_id: @bob.id, followee_id: @joe.id)
        end
        it 'gets called again, just updates' do
          post '/follow_user', params: {follower_id: @bob.id, followee_id: @joe.id}
          expect(response.status).to eq(200)
          expect(Follower.count).to eq(1)
        end
      end

    end
  end

  describe 'POST #delete_follow' do
    # just a copy and paste of the above
    context 'invalid requests are made' do
      it "missing parameters all params" do
        delete '/follow_user', params: {}
        expect(response.status).to eq(400)
      end

      it "missing parameters partial params: followee_id" do
        delete '/follow_user', params: {follower_id: 1}
        expect(response.status).to eq(400)
      end

      it "missing parameters partial params: follower_id" do
        delete '/follow_user', params: {followee_id: 1}
        expect(response.status).to eq(400)
      end

      context 'only one user exists' do
        before(:context) do
          @bob = create(:user)
        end

        it "same ids: follower_id" do
          delete '/follow_user', params: {follower_id: @bob.id, followee_id: @bob.id}
          expect(response.status).to eq(400)
          expect(JSON.parse(response.body)).to eq({"error" => "You weren't following this user!"})
        end

        it "Followee do not exists" do
          delete '/follow_user', params: {follower_id: @bob.id, followee_id: 2}
          expect(response.status).to eq(400)
          expect(JSON.parse(response.body)).to eq({"error" => "You weren't following this user!"})
        end
        it "Follower do not exists" do
          delete '/follow_user', params: {follower_id: 2, followee_id: @bob.id}
          expect(response.status).to eq(400)
          expect(JSON.parse(response.body)).to eq({"error" => "You weren't following this user!"})
        end
      end
    end
    context "delete follow" do
      before(:context) do
        Follower.destroy_all
        @bob = create(:user)
        @joe = create(:user, name: "Joe")
        @follower = create(:follower, follower_id: @bob.id, followee_id: @joe.id)
      end
      it 'safely deleted' do
        delete '/follow_user', params: {follower_id: @bob.id, followee_id: @joe.id}
        expect(response.status).to eq(200)
      end
    end
  end
end
