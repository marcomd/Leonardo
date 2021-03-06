<<<<<<< HEAD
FactoryGirl.define do
  factory :user do
    sequence(:email)      {|n| "test#{n}@leonardo.com" }
    password              'abcd1234'
    roles                 ['user']

    trait :guest do
      roles               ['guest']
    end
    trait :manager do
      roles               ['manager']
    end
    trait :admin do
      roles               ['admin']
    end

    factory :user_guest,    :traits => [:guest]
    factory :user_manager,  :traits => [:manager]
    factory :user_admin,    :traits => [:admin]
  end
  ### Leonardo creates here below your factories ###
  ### Insert below here other your factories ###
=======
FactoryGirl.define do
  factory :user do
    sequence(:email)      {|n| "test#{n}@leonardo.com" }
    password              'abcd1234'
    roles                 ['user']

    trait :guest do
      roles               ['guest']
    end
    trait :manager do
      roles               ['manager']
    end
    trait :admin do
      roles               ['admin']
    end

    factory :user_guest,    :traits => [:guest]
    factory :user_manager,  :traits => [:manager]
    factory :user_admin,    :traits => [:admin]
  end
  ### Leonardo creates here below your factories ###
  ### Insert below here other your factories ###
>>>>>>> 730e2ecf07a73945550e3f0ea4a337ed132a4798
end