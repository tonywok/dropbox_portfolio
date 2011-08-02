FactoryGirl.define do
  sequence :path do |n|
    "/path_#{n}"
  end

  sequence :revision do |n|
    "#{81*n}"
  end

  factory :dropbox_file do
    attachment  File.open(__FILE__)
    path        Factory.next(:path)
    revision    Factory.next(:revision)
    association :item
  end
end
