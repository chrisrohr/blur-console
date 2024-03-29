FactoryGirl.define do
	factory :user do
		sequence(:username)  	{|n| "user#{n}"}
		sequence(:name)      	{|n| "user#{n}"}
		sequence (:email)     {|n| "user#{n}@example.com"}
		password              "password"
		password_confirmation "password"
		roles                 {['editor', 'admin', 'reader', 'auditor', 'searcher']}

    factory :user_with_preferences do
      after_create do |user|
        FactoryGirl.create(:preference, :user => user)
        FactoryGirl.create(:zookeeper_pref, :user =>user)
      end
    end
  end
end