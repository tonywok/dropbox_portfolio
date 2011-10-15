FactoryGirl.define do
  sequence :meta_path do |n|
    "random_file#{n}.png"
  end

  sequence :revision do |n|
    "#{81*n}"
  end

  factory :dropbox_file do
    attachment  File.open(__FILE__)
    meta_path   Factory.next(:meta_path)
    revision    Factory.next(:revision)
  end
end
