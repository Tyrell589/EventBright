Participation.destroy_all
Comment.destroy_all
Event.destroy_all
User.destroy_all

Participation.reset_pk_sequence
Comment.reset_pk_sequence
Event.reset_pk_sequence
User.reset_pk_sequence
ActiveStorage::Blob.reset_pk_sequence
ActiveStorage::Attachment.reset_pk_sequence

20.times do
	first_name = Faker::Name.first_name
	last_name = Faker::Name.last_name
	user = User.create!(
		username: "username#{rand(1..10000)}",
		first_name: first_name,
		last_name: last_name,
		email: first_name + last_name + "@yopmail.com",
		password: "azerty",
    description: Faker::Lorem.paragraph(sentence_count: 5, supplemental: false, random_sentences_to_add: 4),
	)
end

# Demo user seed

User.create!(
  username: "user",
  first_name: "user_first_name",
  last_name: "user_last_name",
  email: "user@email.com",
  password: "password",
  description: Faker::Lorem.paragraph(sentence_count: 2, supplemental: false, random_sentences_to_add: 4)
)

# Admin seed

User.create!(
  username: "admin",
  first_name: "admin_first_name",
  last_name: "admin_last_name",
  email: "admin@email.com",
  password: "password",
  description: Faker::Lorem.paragraph(sentence_count: 2, supplemental: false, random_sentences_to_add: 4),
  admin: true,
)

puts "#{User.all.count} users created (20 user + 1 demo user + 1 admin)"

  # Ouvre et lit le fichier depuis l'url que je lui ai donné, mais ré-upload  dans /assets dans cloudinary
  image_blobs = [
    ActiveStorage::Blob.create_after_upload!(io: open("https://res.cloudinary.com/cloudfilestorage/image/upload/v1616230747/eventbrite/travel_group_ur803j.jpg"), filename: 'travel_group.jpg', content_type: 'image/jpg'),
    ActiveStorage::Blob.create_after_upload!(io: open("https://res.cloudinary.com/cloudfilestorage/image/upload/v1614553355/eventbrite/party_wtsqnk.jpg"), filename: 'party.jpg', content_type: 'image/jpg'),
    ActiveStorage::Blob.create_after_upload!(io: open("https://res.cloudinary.com/cloudfilestorage/image/upload/v1614553355/eventbrite/boxe_zub0uu.jpg"), filename: 'boxe.jpg', content_type: 'image/jpg'),
    ActiveStorage::Blob.create_after_upload!(io: open("https://res.cloudinary.com/cloudfilestorage/image/upload/v1614553355/eventbrite/festival_eilxbu.jpg"), filename: 'festival.jpg', content_type: 'image/jpg'),
    ActiveStorage::Blob.create_after_upload!(io: open("https://res.cloudinary.com/cloudfilestorage/image/upload/v1614553355/eventbrite/foot_azqhzi.jpg"), filename: 'foot.jpg', content_type: 'image/jpg'),
    ActiveStorage::Blob.create_after_upload!(io: open("https://res.cloudinary.com/cloudfilestorage/image/upload/v1614553355/eventbrite/cupcake_mvgwix.jpg"), filename: 'cupcake.jpg', content_type: 'image/jpg'),
    ActiveStorage::Blob.create_after_upload!(io: open("https://res.cloudinary.com/cloudfilestorage/image/upload/v1614553355/eventbrite/motogp_fbr0o5.jpg"), filename: 'motogp.jpg', content_type: 'image/jpg'),
    ActiveStorage::Blob.create_after_upload!(io: open("https://res.cloudinary.com/cloudfilestorage/image/upload/v1616230746/eventbrite/street_art_uggbux.jpg"), filename: 'street_art.jpg', content_type: 'image/jpg'),
    ActiveStorage::Blob.create_after_upload!(io: open("https://res.cloudinary.com/cloudfilestorage/image/upload/v1614553355/eventbrite/church_xcxbjt.jpg"), filename: 'church.jpg', content_type: 'image/jpg'),
    ActiveStorage::Blob.create_after_upload!(io: open("https://res.cloudinary.com/cloudfilestorage/image/upload/v1616230746/eventbrite/reading_l8w6jy.jpg"), filename: 'reading.jpg', content_type: 'image/jpg'),
    ActiveStorage::Blob.create_after_upload!(io: open("https://res.cloudinary.com/cloudfilestorage/image/upload/v1616230746/eventbrite/parots_rmfiis.jpg"), filename: 'parot.jpg', content_type: 'image/jpg'),
    ActiveStorage::Blob.create_after_upload!(io: open("https://res.cloudinary.com/cloudfilestorage/image/upload/v1614549011/eventbrite/sport_wsvhxi.jpg"), filename: 'sport.jpg', content_type: 'image/jpg'),
    ActiveStorage::Blob.create_after_upload!(io: open("https://res.cloudinary.com/cloudfilestorage/image/upload/v1616230746/eventbrite/hills_bufyyp.jpg"), filename: 'hills.jpg', content_type: 'image/jpg'),
    ActiveStorage::Blob.create_after_upload!(io: open("https://res.cloudinary.com/cloudfilestorage/image/upload/v1614549008/eventbrite/cooking_naecrb.jpg"), filename: 'theatre.jpg', content_type: 'image/jpg'),
    ActiveStorage::Blob.create_after_upload!(io: open("https://res.cloudinary.com/cloudfilestorage/image/upload/v1616230746/eventbrite/surf_k8pufl.jpg"), filename: 'surf.jpg', content_type: 'image/jpg'),
    ActiveStorage::Blob.create_after_upload!(io: open("https://res.cloudinary.com/cloudfilestorage/image/upload/v1616230746/eventbrite/monkey_fw0qha.jpg"), filename: 'monkey.jpg', content_type: 'image/jpg'),
    ActiveStorage::Blob.create_after_upload!(io: open("https://res.cloudinary.com/cloudfilestorage/image/upload/v1614549002/eventbrite/conference_y7qiyn.jpg"), filename: 'conference.jpg', content_type: 'image/jpg')
  ]

30.times do |i|
  e = Event.create!(
    title: "Event #{i+1}",
    description: Faker::Lorem.paragraph(sentence_count: 120, supplemental: true),
    location: Faker::TvShows::Friends.location,
    start_date: Faker::Date.forward(days: 30),
    duration: rand(4..60)*5,
    administrator: User.all.sample,
    price: rand(50..1000),
    validated: true,
  )
  e.participants.concat(User.all.sample(4))
  e.images.attach(image_blobs[0..10].sample)
  e.images.attach(image_blobs[11..13].sample)
  e.images.attach(image_blobs[14..16].sample)
end
puts "#{Event.all.count} events created"

#Create comments on Events
40.times do
  Comment.create!(
    content: Faker::Lorem.sentence(word_count: 3, supplemental: true, random_words_to_add: 4),
    commenter: User.all.sample,
    commentable: Event.all.sample,
  )
end

#Create comments on Comments
20.times do
  Comment.create!(
    content: Faker::Lorem.sentence(word_count: 3, supplemental: true, random_words_to_add: 4),
    commenter: User.all.sample,
    commentable: Comment.all.sample,
  )
end
puts "#{Comment.count} comments created"

puts "End of seeds"
