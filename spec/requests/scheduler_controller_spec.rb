require 'rails_helper'

RSpec.describe "SchedulerControllers", type: :request do
  describe "POST register_schedule" do
    before(:context) do
      @bob = create(:user)
    end

    context 'invalid requests' do
      it "user doesn't exists" do
        post "/user/#{@bob.id + 1}/schedule",  params: {}
        expect(response.status).to eq(400)
        expect(JSON.parse(response.body)).to eq({"error" => "Invalid user id"})
      end
      it 'missing params' do
        post "/user/#{@bob.id}/schedule",  params: {}
        expect(response.status).to eq(400)
      end

      it 'slept_at is a non-date string' do
        post "/user/#{@bob.id}/schedule", params: {woke_at: "2023-01-02 08:00:00", slept_at: "some string"}
        expect(response.status).to eq(400)
        expect(JSON.parse(response.body)).to eq({"error" => "Invalid slept at or woke up values"})
      end

      it 'woke_at is a non-date string' do
        post "/user/#{@bob.id}/schedule", params: {woke_at: "some string", slept_at: "2023-01-01 22:00:00"}
        expect(response.status).to eq(400)
        expect(JSON.parse(response.body)).to eq({"error" => "Invalid slept at or woke up values"})
      end

      it 'woke_at at is less than slept at' do
        post "/user/#{@bob.id}/schedule", params: {woke_at: "2023-01-01 08:00:00", slept_at: "2023-01-01 22:00:00"}
        expect(response.status).to eq(400)
        expect(JSON.parse(response.body)).to eq({"error" => "Invalid schedule"})
      end
    end

    context 'valid requests' do
      it 'schedule created - make sure slept seconds is 60' do
        post "/user/#{@bob.id}/schedule", params: {woke_at: "2023-01-01 08:01:00", slept_at: "2023-01-01 08:00:00"}
        expect(response.status).to eq(201)
        expect(JSON.parse(response.body)["total_slept_seconds"]).to eq(60)
      end
    end
  end

  describe "GET schedule" do
    before(:context) do
      SleepSchedule.destroy_all
      @bob = create(:user)
      @joe = create(:user)
      @sleep_schedules = []
      5.times do |i|
        attributes = FactoryBot.attributes_for(:sleep_schedule)
        attributes[:slept_at] = DateTime.parse("2023-01-0#{i+1} 20:00:00")
        attributes[:woke_up_at] = DateTime.parse("2023-01-0#{i+2} 07:00:00")
        attributes[:created_at] = (i).days.ago
        attributes[:user_id] = @bob.id
        @sleep_schedules << FactoryBot.create(:sleep_schedule, attributes)
      end
    end

    context 'invalid requests' do
      it "user doesn't exists" do
        post "/user/#{@joe.id + 1}/schedule",  params: {}
        expect(response.status).to eq(400)
        expect(JSON.parse(response.body)).to eq({"error" => "Invalid user id"})
      end
    end
    context 'valid requests' do
      it 'joe has no schedules' do
        get  "/user/#{@joe.id}/schedule"
        expect(response.status).to eq(200)
        @body = JSON.parse(response.body)
        expect(@body).to be_an(Array)
        expect(@body).to be_empty
      end

      it 'bob has schedules and is sorted by created at' do
        get  "/user/#{@bob.id}/schedule"
        expect(response.status).to eq(200)
        @body = JSON.parse(response.body)
        @body.each_cons(2) do |prev, curr|
          expect(prev['created_at']).to be >= curr['created_at']
        end
      end
      it 'bob has schedules - pagination test' do
        get  "/user/#{@bob.id}/schedule",  params: {limit: 3}
        expect(response.status).to eq(200)
        @body = JSON.parse(response.body)
        expect(@body).to be_an(Array)
        expect(@body).to have_attributes(count: 3)
        @body.each_cons(2) do |prev, curr|
          expect(prev['created_at']).to be >= curr['created_at']
        end

        get  "/user/#{@bob.id}/schedule",  params: {limit: 3, offset:3}
        expect(response.status).to eq(200)
        @body_2 = JSON.parse(response.body)
        expect(@body_2).to have_attributes(count: 2)
        @body_2.each_cons(2) do |prev, curr|
          expect(prev['created_at']).to be >= curr['created_at']
          expect(@body.first['created_at']).to be >= prev['created_at']
          expect(@body.first['created_at']).to be >= curr['created_at']
        end

        get  "/user/#{@bob.id}/schedule",  params: {limit: 3, offset:6}
        expect(response.status).to eq(200)
        @body_3 = JSON.parse(response.body)
        expect(@body_3).to be_an(Array)
        expect(@body_3).to be_empty
      end
    end
  end

  describe 'GET get_followers_schedule' do
    before(:context) do
      SleepSchedule.destroy_all
      Follower.destroy_all
      @bob = create(:user)
      @joe = create(:user, name: "joe")
      @alice = create(:user, name: "alice")
      @bob_sleep_schedules = []
      5.times do |i|
        attributes = FactoryBot.attributes_for(:sleep_schedule)
        attributes[:slept_at] = DateTime.parse("2023-01-0#{i+1} 20:00:00")
        attributes[:woke_up_at] = DateTime.parse("2023-01-0#{i+2} 07:00:00")
        attributes[:created_at] = (i).days.ago
        attributes[:user_id] = @bob.id
        @bob_sleep_schedules << FactoryBot.create(:sleep_schedule, attributes)
      end
      @bob_follows_joe = create(:follower, follower_id: @bob.id, followee_id: @joe.id)
      @bob_follows_alice = create(:follower, follower_id: @bob.id, followee_id: @alice.id)
    end

    context 'Bob follows bob and alice' do
      def date_helper(slept_at, woke_at)
        return ((DateTime.parse(woke_at) - DateTime.parse(slept_at)) * 24 * 60 * 60).to_i
      end
      it "only one record of alice should show. All of joe's record should be shown as it's within one week" do
        create(:sleep_schedule, slept_at: "2023-01-01 20:00:00", woke_up_at: "2023-01-02 10:00:00", created_at: 2.weeks.ago, user_id: @alice.id, total_slept_seconds: date_helper("2023-01-01 20:00:00", "2023-01-02 10:00:00"))
        create(:sleep_schedule, slept_at: "2023-01-02 20:00:00", woke_up_at: "2023-01-03 11:00:00", created_at: 2.weeks.ago, user_id: @alice.id, total_slept_seconds: date_helper("2023-01-02 20:00:00", "2023-01-03 11:00:00"))
        @alice_record_should_be_last = create(:sleep_schedule, slept_at: "2023-01-03 20:00:00", woke_up_at: "2023-01-04 06:00:00", created_at: 6.days.ago, user_id: @alice.id, total_slept_seconds: date_helper("2023-01-03 20:00:00", "2023-01-04 06:00:00"))

        @joe_record_should_be_first = create(:sleep_schedule, slept_at: "2023-01-01 20:00:00", woke_up_at: "2023-01-02 09:00:00", created_at: 1.days.ago, user_id: @joe.id, total_slept_seconds: date_helper("2023-01-01 20:00:00", "2023-01-02 09:00:00"))
        @joe_record_should_be_second = create(:sleep_schedule, slept_at: "2023-01-02 20:00:00", woke_up_at: "2023-01-03 08:00:00", created_at: 2.days.ago, user_id: @joe.id, total_slept_seconds: date_helper("2023-01-02 20:00:00", "2023-01-03 08:00:00"))
        @joe_record_should_be_third =create(:sleep_schedule, slept_at: "2023-01-03 20:00:00", woke_up_at: "2023-01-04 07:00:00", created_at: 3.days.ago, user_id: @joe.id, total_slept_seconds: date_helper("2023-01-03 20:00:00", "2023-01-04 07:00:00"))
        @expected = [@joe_record_should_be_first.to_json(:except => [:updated_at]), @joe_record_should_be_second.to_json(:except => [:updated_at]), @joe_record_should_be_third.to_json(:except => [:updated_at]), @alice_record_should_be_last.to_json(:except => [:updated_at])]
        get  "/user/#{@bob.id}/schedule/followers"
        expect(response.status).to eq(200)
        @body = JSON.parse(response.body)
        expect(@body).to be_an(Array)
        @body.each_with_index  do |item, index|


          expected = JSON.parse(@expected[index])
          expect(item['id']).to eq(expected['id'])
          expect(item['woke_up_at']).to eq(expected['woke_up_at'])
          expect(item['slept_at']).to eq(expected['slept_at'])
          expect(item['total_slept_seconds']).to eq(expected['total_slept_seconds'])
          expect(item['user_id']).to eq(expected['user_id'])
        end
      end

      it "bob unfollows joe. Only alice record" do
        @bob_follows_joe.update(active: 0)
        create(:sleep_schedule, slept_at: "2023-01-01 20:00:00", woke_up_at: "2023-01-02 10:00:00", created_at: 2.weeks.ago, user_id: @alice.id, total_slept_seconds: date_helper("2023-01-01 20:00:00", "2023-01-02 10:00:00"))
        create(:sleep_schedule, slept_at: "2023-01-02 20:00:00", woke_up_at: "2023-01-03 11:00:00", created_at: 2.weeks.ago, user_id: @alice.id, total_slept_seconds: date_helper("2023-01-02 20:00:00", "2023-01-03 11:00:00"))
        @alice_record_should_be_last = create(:sleep_schedule, slept_at: "2023-01-03 20:00:00", woke_up_at: "2023-01-04 06:00:00", created_at: 6.days.ago, user_id: @alice.id, total_slept_seconds: date_helper("2023-01-03 20:00:00", "2023-01-04 06:00:00"))

        @joe_record_should_be_first = create(:sleep_schedule, slept_at: "2023-01-01 20:00:00", woke_up_at: "2023-01-02 09:00:00", created_at: 1.days.ago, user_id: @joe.id, total_slept_seconds: date_helper("2023-01-01 20:00:00", "2023-01-02 09:00:00"))
        @joe_record_should_be_second = create(:sleep_schedule, slept_at: "2023-01-02 20:00:00", woke_up_at: "2023-01-03 08:00:00", created_at: 2.days.ago, user_id: @joe.id, total_slept_seconds: date_helper("2023-01-02 20:00:00", "2023-01-03 08:00:00"))
        @joe_record_should_be_third =create(:sleep_schedule, slept_at: "2023-01-03 20:00:00", woke_up_at: "2023-01-04 07:00:00", created_at: 3.days.ago, user_id: @joe.id, total_slept_seconds: date_helper("2023-01-03 20:00:00", "2023-01-04 07:00:00"))
        @expected = [@alice_record_should_be_last.to_json(:except => [:updated_at])]
        get  "/user/#{@bob.id}/schedule/followers"
        expect(response.status).to eq(200)
        @body = JSON.parse(response.body)
        expect(@body).to be_an(Array)
        expect(@body).to have_attributes(count: 1)
        @body.each_with_index  do |item, index|


          expected = JSON.parse(@expected[index])
          expect(item['id']).to eq(expected['id'])
          expect(item['woke_up_at']).to eq(expected['woke_up_at'])
          expect(item['slept_at']).to eq(expected['slept_at'])
          expect(item['total_slept_seconds']).to eq(expected['total_slept_seconds'])
          expect(item['user_id']).to eq(expected['user_id'])
        end
        @bob_follows_joe.update(active: 1)
      end

      it "only one record of alice should show, the rest are bob's records. Thus only one record should be shown" do
        create(:sleep_schedule, slept_at: "2023-01-01 20:00:00", woke_up_at: "2023-01-02 07:00:00", created_at: 2.weeks.ago, user_id: @alice.id)
        create(:sleep_schedule, slept_at: "2023-01-02 20:00:00", woke_up_at: "2023-01-03 07:00:00", created_at: 2.weeks.ago, user_id: @alice.id)
        @alice_record_should_be_last = create(:sleep_schedule, slept_at: "2023-01-03 20:00:00", woke_up_at: "2023-01-04 06:00:00", created_at: 6.days.ago, user_id: @alice.id, total_slept_seconds: date_helper("2023-01-03 20:00:00", "2023-01-04 06:00:00"))

        @bob_record_should_be_first = create(:sleep_schedule, slept_at: "2023-01-01 20:00:00", woke_up_at: "2023-01-02 09:00:00", created_at: 1.days.ago, user_id: @bob.id, total_slept_seconds: date_helper("2023-01-01 20:00:00", "2023-01-02 09:00:00"))
        @bob_record_should_be_second = create(:sleep_schedule, slept_at: "2023-01-02 20:00:00", woke_up_at: "2023-01-03 08:00:00", created_at: 2.days.ago, user_id: @bob.id, total_slept_seconds: date_helper("2023-01-02 20:00:00", "2023-01-03 08:00:00"))
        @bob_record_should_be_third =create(:sleep_schedule, slept_at: "2023-01-03 20:00:00", woke_up_at: "2023-01-04 07:00:00", created_at: 3.days.ago, user_id: @bob.id, total_slept_seconds: date_helper("2023-01-03 20:00:00", "2023-01-04 07:00:00"))
        @expected = [@alice_record_should_be_last.to_json(:except => [:updated_at])]
        get  "/user/#{@bob.id}/schedule/followers"
        expect(response.status).to eq(200)
        @body = JSON.parse(response.body)
        expect(@body).to be_an(Array)
        @body.each_with_index  do |item, index|


          expected = JSON.parse(@expected[index])
          expect(item['id']).to eq(expected['id'])
          expect(item['woke_up_at']).to eq(expected['woke_up_at'])
          expect(item['slept_at']).to eq(expected['slept_at'])
          expect(item['total_slept_seconds']).to eq(expected['total_slept_seconds'])
          expect(item['user_id']).to eq(expected['user_id'])
        end
      end
      it 'joe only follows alice' do
        create(:follower, follower_id: @joe.id, followee_id: @alice.id)
        create(:sleep_schedule, slept_at: "2023-01-01 20:00:00", woke_up_at: "2023-01-02 07:00:00", created_at: 2.weeks.ago, user_id: @alice.id)
        create(:sleep_schedule, slept_at: "2023-01-02 20:00:00", woke_up_at: "2023-01-03 07:00:00", created_at: 2.weeks.ago, user_id: @alice.id)
        @alice_record_should_be_last = create(:sleep_schedule, slept_at: "2023-01-03 20:00:00", woke_up_at: "2023-01-04 06:00:00", created_at: 6.days.ago, user_id: @alice.id, total_slept_seconds: date_helper("2023-01-03 20:00:00", "2023-01-04 06:00:00"))

        create(:sleep_schedule, slept_at: "2023-01-01 20:00:00", woke_up_at: "2023-01-02 09:00:00", created_at: 1.days.ago, user_id: @bob.id, total_slept_seconds: date_helper("2023-01-01 20:00:00", "2023-01-02 09:00:00"))
        create(:sleep_schedule, slept_at: "2023-01-02 20:00:00", woke_up_at: "2023-01-03 08:00:00", created_at: 2.days.ago, user_id: @bob.id, total_slept_seconds: date_helper("2023-01-02 20:00:00", "2023-01-03 08:00:00"))
        create(:sleep_schedule, slept_at: "2023-01-03 20:00:00", woke_up_at: "2023-01-04 07:00:00", created_at: 3.days.ago, user_id: @bob.id, total_slept_seconds: date_helper("2023-01-03 20:00:00", "2023-01-04 07:00:00"))
        @expected = [@alice_record_should_be_last.to_json(:except => [:updated_at])]
        get  "/user/#{@joe.id}/schedule/followers"
        expect(response.status).to eq(200)
        @body = JSON.parse(response.body)
        expect(@body).to be_an(Array)
        @body.each_with_index  do |item, index|


          expected = JSON.parse(@expected[index])
          expect(item['id']).to eq(expected['id'])
          expect(item['woke_up_at']).to eq(expected['woke_up_at'])
          expect(item['slept_at']).to eq(expected['slept_at'])
          expect(item['total_slept_seconds']).to eq(expected['total_slept_seconds'])
          expect(item['user_id']).to eq(expected['user_id'])
        end
      end
      it 'alice follows no one' do
        get  "/user/#{@alice.id}/schedule/followers"
        expect(response.status).to eq(200)
        @body = JSON.parse(response.body)
        expect(@body).to be_an(Array)
        expect(@body).to be_empty
      end
    end

  end
end
