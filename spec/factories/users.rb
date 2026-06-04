FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:name) { |n| "User #{n}" }
    sequence(:employee_id) { |n| "EMP#{n}" }
    password { "password123" }
    password_confirmation { "password123" }
    role { "colaborador" }
    department { "Operacoes" }
    position { "Analista" }
    status { "ativo" }
  end
end
