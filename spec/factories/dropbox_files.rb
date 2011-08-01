FactoryGirl.define do
  sequence :path do |n|
    "/path_#{n}"
  end

  sequence :revision do |n| 
    "#{81*n}"
  end

  factory :dropbox_file do
    attachment "stuff"
    path       Factory.next(:path)
    revision   Factory.next(:revision)
  end
end
