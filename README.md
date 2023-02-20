# README

A quick implementation of the assignment given.

All you really need to look at is the `controller` and `model`, For tests, everything in `rspec`

Just a few things I want to point out :
- It's been over a year since I've wrote in Ruby and more of a Java developer. I know I didn't write things the "ruby" way and the code isn't the cleanest
- Due to time constraint, I've only invested 4 hours in this. I did take some short cuts and made some assumptions to help cut time.
    - Example: "See the sleep records over the past week for their friends". I just assumed we should use the created_at. I have asked if we should be looking at the slept/woke up at times instead.
    - Using destroy_all in the test cases is not great as we lose parallelization. I just did this to save time to not consult the documentation/google.
    - Integration with mysql. I just left it using sqlite. 
- I didn't even set the DB timezone. I'm assuming the default is UTC? For the register controller, I just assumed we would be passing something like "2023-01-01 08:01:00" and let ruby handle the parsing.
- Devise for users. I just assumed we have some users registered in the DB. You just have to pass a valid user id to make the apis work. Ideally, this is done via something like a bearer token.
- Could clean up the unused folders such as assets, channels, etc.

There are so many things I would like to implement and would have done things differently if I had more time. If it was in Java, I do think I could have pumped out something better.

Tech used:
    
- rails 7.0.4
- ruby 3.2.1
- factorybot
- rspec

## APIs

- POST user/:id/schedule where :id is the user's id. Register a schedule
- GET user/:id/schedule where :id is the user's id. Get the user's schedule sorted by created_at DESC
- GET user/:id/schedule/followers where :id is the user's id. Get the schedules of from who they followed sorted by time_slept DESC(only within a week) and then the id.
- POST follow_user -> add a user to follow
- DELETE follow_user -> delete the follow

The last two takes the follow body:
```json
{
    "follower_id": 1,
    "followee_id": 5
}
```
follower_id should be the current user.



## How to run tests

I've decided to use rspec since that was something I was familiar with. Hence run the test cases using : `bundle exec rspec`.