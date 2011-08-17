FactoryGirl.define do
  sequence :meta_filename do |n|
    "random_file#{n}.png"
  end

  sequence :revision do |n|
    "#{81*n}"
  end

  factory :dropbox_file do
    attachment  File.open(__FILE__)
    meta_filename Factory.next(:meta_filename)
    revision    Factory.next(:revision)
    association :section
  end
end
