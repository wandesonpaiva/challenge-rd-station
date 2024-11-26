FactoryBot.define do
  factory :cart do
    last_interaction_at { Time.now }
  end
end
