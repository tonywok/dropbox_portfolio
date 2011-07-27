Factory.sequence :email do |n|
  "email#{n}@example.com"
end

Factory.define :admin do |admin|
  admin.email { Factory.next(:email) }
  admin.password "foobar"
  admin.password_confirmation "foobar"
end
