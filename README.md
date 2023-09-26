![](/app/assets/images/EventBright.png)

An EventBrite clone application built from scratch with Ruby on Rails!

Visit the app here [eventbright-prod-app.herokuapp.com](https://eventbright-prod-app.herokuapp.com/)

Login as a user or admin (admin has access to admin dashboard from profile dropdown button):

+ username: user or admin

+ password: password

## Table of Contents
- [I - Informations & case studies](#i---informations-and-case-studies)
  * [1. Backend](#1-backend)
    + [1.1 Models & database structure](#11-models-and-database-structure)
    + [1.2 Authentication (Devise)](#12-authentication-devise)
    + [1.3 Authorization (CanCanCan)](#13-authorization-cancancan)
    + [1.4 Admin dashboard (Administrate)](#14-admin-dashboard-administrate)
    + [1.5 Payment system (Stripe)](#15-payment-system-stripe)
    + [1.6 Mailer (Action Mailer)](#16-mailer-action-mailer)
    + [1.7 Image upload (Active Storage & Cloudinary)](#17-image-upload-active-storage-and-cloudinary)
  * [2. Frontend](#2-frontend)
      + [2.1 About the Frontend](#21-about-the-frontend)
      + [2.2 EventBrite inspiration](#22-eventbrite-inspiration)
      + [2.3 Bootstrap customization](#23-bootstrap-customization)
  * [3. Workflow & deployment](#3-workflow-and-deployment)
      + [3.1 Workflow](#31-workflow)
      + [3.2 Deployment](#32-deployment)
  * [4. To be improved](#4-to-be-improved)
- [II - Installation](#ii---installation)

## I - Informations and study cases

###  1. Backend
#### 1.1 Models and database structure
Currently there's 4 models:
 - `User`: set for both regluar users of the app and administrators (with an `:admin` attribute set to `true`)
    - has one attached `avatar`
    - has many `administrated_events` (`Event` type)
    - has many `participations`
    - has many `attended_events` (`Event` type) through `participation`
 - `Event`: main subject resource
    - has many attached `images`
    - belongs to `administrator` (`User` type)
    - has many `participations`
    - has many `participants` (`User` type) through `participations`
    - has many `comments` as `commentable`
 - `Participation`: a user's participation to an event
    - belongs to `user`
    - belongs to `event`
 - `Comment`: on events or other users comments
    - belongs to `commenter` (`User` type)
    - belongs to `commentable` (polymorphic)
    - has many `comments` as `commentable`


#### 1.2 Authentication (Devise)
I twisted the Devise configuration a little bit to allow users to use either email or username to sign in. Following the [Devise wiki](https://github.com/heartcombo/devise/wiki/How-To:-Allow-users-to-sign-in-using-their-username-or-email-address) here's the few steps I've done:
- Change the default authentication key to use `:login` instead of `:email`:
```ruby
# config/initializers/devise.rb

  config.authentication_keys = [:login]
```
- I made it mandatory to choose a username along with email & password during registration. So I had to permit it in strong parameters. Note: email also need to be explicitly permitted as well, it's no longer automatically permitted as it's not the default authentication key anymore.
```ruby
# app/controllers/application_controller.rb

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up,
      keys: [:email, :username])
    devise_parameter_sanitizer.permit(:account_update,
      keys: [:first_name, :last_name, :description, :email])
  end
```
- In the `User` model I've set a virtual attribute that will be used in the sign in form to hold the value of the crendential entered by the user (either email or username). I overwrote the `find_for_database_authentication` Devise class method to extend the default query to search for both credentials in the DB.

```ruby
# app/models/user.rb

  class User < ApplicationRecord
   attr_accessor :login

   ...

   def self.find_for_database_authentication warden_condition
     conditions = warden_condition.dup
     login = conditions.delete(:login)
     where(conditions).where(
       ["lower(username) = :value OR lower(email) = :value",
       { value: login.strip.downcase }]).first
   end
 end
```

#### 1.3 Authorization ([CanCanCan](https://github.com/CanCanCommunity/cancancan))
Permissions are centralized in `app/models/ability.rb`. It enabled me to drastically DRY up the controllers by getting ride of many `before_action`s, and conveniently load a resource with the right permissions.

Here's some examples of permissions implemented:

- Unauthenticated users can only access `event`'s `index` & `show` pages, but can't join it.
- Only `event`'s administrator can access the `event`'s profile (`show`) page if it's not validated by the (app) administrator yet. This is so an event's owner has still permission to updated or delete his event before it's published.
- Only validated `event`'s are displayed on the `index` page.
- Only `event`'s administrator can access `participant`s list.

#### 1.4 Admin dashboard ([Administrate](https://github.com/thoughtbot/administrate))
The admin dashboard is accessible under the "/admin" namespace. You can login as an admin with these credentials: `username: admin, password: password`.

When an event is newly created, it has its `validated` attribute set to `false`. It's not displayed on the index pages, and only its creator has permission to access the event `show` page in order to update or delete it. To be validated, an admin has to do it manually through the admin dashboard.

#### 1.5 Payment system ([Stripe](https://stripe.com/docs/development))

Event can either be free or paying. To checkout for paying events, enter testing card infos in the checkout form:

- Card n° `4242 4242 4242 4242`
- Expiry date: any date in the future e.g. `12/25`
- CVV: any 3 digits e.g. `123`

#### 1.6 Mailer (Action Mailer)

Emails are sent after specific actions:
- welcome email: when a user create an account
- summarizing email: when a participation is created to summarize the event infos, `star_date`, `administrator` and number of `participants`.

There are both text and html templates.

#### 1.7 Image upload (Active Storage and Cloudinary)

Cloudinary is used for hosting images and storing uploaded images.
I use Active Storage for uploading images directly from the client to the cloud service.

An interesting part was the work on the seed with this configuration.

I had 15 images stored on Cloudinary that I wanted to use for seeding the `event` images (each `event` has 3 attached images). First I attached an image individually to each event like this:
```ruby
# seed.rb

# Storing images paths in an array:
images = [
  [io: open("https://res.cloudinary.com/cloudfilestorage/image/upload/v1616230747/eventbrite/travel_group_ur803j.jpg"), filename: 'travel_group.jpg', content_type: 'image/jpg'],
  [io: open("https://res.cloudinary.com/cloudfilestorage/image/upload/v1614553355/eventbrite/party_wtsqnk.jpg"), filename: 'party.jpg', content_type: 'image/jpg'],
  [io: open("https://res.cloudinary.com/cloudfilestorage/image/upload/v1614549002/eventbrite/conference_y7qiyn.jpg"), filename: 'conference.jpg', content_type: 'image/jpg']
  ... # 15 images paths on the cloud
]

 # Attaching 3 images per event:
  3.times do
    event.images.attach(images[rand[0..15].first])
  end
```

But I faced 2 problems with the line `event.images.attach(images[rand[0..15].first])`:

- Each time the `#attach` method is used, it is actually re-uploading the image to Cloudinary before creating a blob for this image and attaching it to the event. This means if I wanted to seed 30 `event`s I would have 90 (30 * 3) uploads happening & unnecessary duplicated images stored on the cloud.
- This is too much API calls to the server and Cloudinary was blocking my requests

After some research I found a way to separate the processes (blob creation & blob attachement) that are automatically done by the `#attach` method:

```ruby
# seed.rb

image_blobs = [
  ActiveStorage::Blob.create_after_upload!(io: open("https://res.cloudinary.com/cloudfilestorage/image/upload/v1616230747/eventbrite/travel_group_ur803j.jpg"), filename: 'travel_group.jpg', content_type: 'image/jpg'),
  ActiveStorage::Blob.create_after_upload!(io: open("https://res.cloudinary.com/cloudfilestorage/image/upload/v1614553355/eventbrite/party_wtsqnk.jpg"), filename: 'party.jpg', content_type: 'image/jpg'),
  ActiveStorage::Blob.create_after_upload!(io: open("https://res.cloudinary.com/cloudfilestorage/image/upload/v1614553355/eventbrite/boxe_zub0uu.jpg"), filename: 'boxe.jpg', content_type: 'image/jpg')
... # 15 times
]
```
The `ActiveStorage::Blob.create_after_upload!` uploads the images to the cloud and create a blob referencing this image. Now I have an array that contain 15 blobs referencing 15 images, that are uploaded once and for all to the cloud. I can now have more control over the attachement process.

But I faced another problem with the file attachment:

```ruby
3.times do
  event.images.attach(image_blobs[rand[0..15]])
end
```
Since the `image_blobs` array contains 15 single instances of blobs, and I was picking randomly 3 blobs out of those same 15, it means a same blob can get attached twice for the same `event`. I was getting an `ActiveRecord::RecordNotUnique` error because there is a uniqueness constraint on the `active_storage_attachments` table. I found a simple way to work around this problem:

```ruby
event.images.attach(image_blobs[0..8].sample)
event.images.attach(image_blobs[9..11].sample)
event.images.attach(image_blobs[12..14].sample)
```
Now I make sure each `event` doesn't get the same image twice, and this also have the advantage of forcing more diversity regarding the images displayed.

###  2. Frontend
#### 2.1 About the frontend

- The frontend is an overall mix between Bootstrap and personal customizations.

- I've applied atomic design principles cutting the components in partials.

- I've used the 7-1 pattern to structure stylesheets folders.

- The components are generally Bootstrap based and customized using my own classes, especially for the cards and the main listing on the event show page. I wanted to replicate them from the [EventBrite](https://www.eventbrite.fr/) official website.

- I've used the Bootstrap grid system for layout, but I customized the `.container` class and added my personal mixin breakpoints for responsivness (in `assets/stylesheets/utilities/mixins/_breakpoints.scss`).

- Assets are compiled through the Asset Pipeline, Bootstrap is loaded through a Bootswatch theme under the `vendor/assets` folder

#### 2.2 EventBrite inspiration
I replicated 2 organisms from the official EventBrite website: cards and the event listing on the event show page.

##### 2.2.1 Cards
Cards are composed of an image section and a body section with informations about the event. They have 2 main shapes, a "regular" and a "horizontal" one for mobile view. The switch happen under a certain breakpoint. To make the transition, I've used 2 main classes that are applied dynamically depending on the breakpoint.

In the card partial `app/views/events/_event_card.html.erb` there is only 2 classes applied by default

- Bootstrap `.card` class: Used mainly to apply flexbox properties.

- Common styles `.card-presentation`: This applies styles that are common to both shapes, like `box-shadow`, `border-radius`, `object-fit` to the image... and to the subsections of the card as well.

There are 2 other classes applied dynamically using javascript

```javascript
/// app/assets/javascripts/card.js

  const cards = Array.from(document.getElementsByClassName("card"));

  function switchCardsLayout(x) {
    if (x.matches) {
      cards.forEach((card) => {
        card.classList.remove("card-regular");
        card.classList.add("card-horizontal");
      });
    } else {
      cards.forEach((card) => {
        if (card.classList.contains("card-horizontal")) {
          card.classList.remove("card-horizontal");
        }
        card.classList.add("card-regular");
      });
    }
  }

  const x = window.matchMedia("(max-width: 575px)");
  switchCardsLayout(x);
  x.addListener(switchCardsLayout);
```
Here I use javascript media queries to apply either `.card-regular` above 575px, or `.card-horizontal` below.

Now it is easier to apply the styles specifically to one or the other shape, as the classes `.regular` & `.horizontal` target one specific shape, instead of fumbling around with media queries.

For example, defining styles for the `card_event_link` subsection is done by "namespacing" the shape we are talking about:

```scss
// app/assets/stylesheets/components/_card.scss

// card-img-link styles when card in "regular" shape
.card-regular .card-img-link {
  width: 100%;
  height: 160px;
  min-height: 160px;
}

// card-img-link styles when card in "horizontal" shape
.card-horizontal .card-img-link {
  height: 100%;
  width: 160px;
  min-width: 160px;
}
```

##### 2.2.2 Card Listing

I was interested in replicating the card listing component of the events show page.
- I like the blur background that uses the event's image itself as a backgroung image.
- I also like how the CTA button is moving around at the different breakpoints.
- I chose to display a carousel of 3 images instead of just one.
- Finally I managed to get the behavior of having the blur background shrinking as the width of the page decrease and disapearing under phone viewport width.

Looking at the event show page I figuered I could broke it down into few partials that could be by themselves re-usable components in other pages.

Here's the event listing partial:

```erb
<!-- app/views/events/_event_listing.html.erb -->

<div class="event-listing">
  <%= render partial: "card_presentation_panel", locals: { event: event, amount: amount } %>
  <%= render partial: "event_link_panel", locals: { event: event } %>

  <div class="event-description">
    <p class ="text-muted">Posted on <%= @event.creation_date_and_time %></p>
    <h3>About this event</h3>
    <p><%= event.description %></p>
  </div>
</div>
```
It is broken down into 3 sections, the first 2 are partials, the last one is not because it's proper to the event listing component.

This allows me to use `card_presentation_panel` component in the participation `new` page as well to summarize the `event` details on the checkout page.

This also allows me to clean up components that have a lot logic like the CTA button:
```erb
<!-- app/views/events/_event_link_panel.html.erb -->

<% if current_user_is_administrator?(event) %>
<div class="row">
  <div class="col-12 d-flex event-link-panel">
    <%= link_to "Event Dashboard", participations_path(event_id: event.id), class: 'btn btn-lg btn-success' %><br />
  </div>
</div>
<% elsif current_user_already_participant?(event) %>
<div class="row">
  <div class="col-12 d-flex event-link-panel">
    <%= link_to "Cancel participation", participation_path(current_user_participation(event).id), method: :delete, class:'btn btn-lg btn-danger' %><br />
  </div>
</div>
<% else %>
<div class="row">
  <div class="col-12 d-flex event-link-panel">
    <%= link_to "Join the event !", new_participation_path(event_id: event.id), class: 'btn btn-lg btn-primary' %><br />
  </div>
</div>
<% end %>
```

Now the button is isolated with its logic in its own partial in the same way it's done in the Devise gem in `devise/shared/_links.html.erb` partial.

#### 2.3 Bootstrap customization

##### 2.3.1 Main carousel
I wanted a showcase section with a carousel and sliding images to give a little bit of animation to the home page.

So I've used the basic Bootsrap carousel, and made it span the enitre page width. I applied an overlay to make the text stand out. I gave it a `height: 100%`, for it to take up the height of its parent height (the showcase section) `height: 70vh`

```scss
// app/assets/stylesheets/pages/_home.scss

#showcase {
  height: 70vh;
  position: relative;
}

// app/assets/stylesheets/components/_showcase_carousel.scss

#showcase-carousel {
  height: 100%;
  .carousel-inner,
  .carousel-item {
    width: 100%;
    height: 100%;
  }
  .carousel-img {
    height: 100%;
    width: 100%;
    object-fit: cover;
  }
}
```
##### 2.3.2 Error messages in form validation fields

I used Bootstrap for the forms, and I wanted for each form field to have its error messages (if any) to be displayed under it. This is possible by default for client side validations, but I wanted to use [the serve side](https://getbootstrap.com/docs/4.0/components/forms/#server-side) and display the error messages from the app validations.

I found out about the [ActionView::Base.field_error_proc](https://github.com/rails/rails/blob/v5.2.5/actionview/lib/action_view/base.rb#L145-L145) accessor that gives access to the html tags of a model's field attribute that gets errors on validations.

I overwrote it in an initializer file to use the Bootstrap `is-invalid` and `invalid-feedback` classes. See my answer in [this gist](https://gist.github.com/telwell/db42a4dafbe9cc3b7988debe358c88ad#gistcomment-3559468)

```ruby
# app/config/initializers/bootstrap_form_errors_customizer.rb

ActionView::Base.field_error_proc = proc do |html_tag, instance|
  is_label_tag = html_tag =~ /^<label/
  class_attr_index = html_tag.index 'class="'

  def format_error_message_to_html_list(error_msg)
    html_list_errors = "<ul></ul>"
    if error_msg.is_a?(Array)
      error_msg.each do |msg|
        html_list_errors.insert(-6, "<li>#{msg}</li>")
      end
    else
      html_list_errors.insert(-6, "<li>#{msg}</li>")
    end
    html_list_errors
  end

  invalid_div =
    "<div class='invalid-feedback'>#{format_error_message_to_html_list(instance.error_message)}</div>"


  if class_attr_index && !is_label_tag
    html_tag.insert(class_attr_index + 7, 'is-invalid ')
    html_tag + invalid_div.html_safe
  elsif !class_attr_index && !is_label_tag
    html_tag.insert(html_tag.index('>'), ' class="is-invalid"')
    html_tag + invalid_div.html_safe
  else
    html_tag.html_safe
  end
end
```
Basically, I create a `div` with the `invalid-feedback` class. It contains a list of the error(s) that an attribute gets if it's invalid. I then target the `input` or `textarea` tags and add the `is-invalid` class (so they get the Bootstrap red border decoration around), and insert the invalid-feedback `div` bellow it to list the errors.

It might not be the better way to do it, I came accross the simple form gem that integrate error messages natively, nonetheless, it was a fun learning experience to do it this way.

###  3. Workflow and deployment
#### 3.1 Workflow
The workflow hasn't been perfect from the start. Overtime I would lookup better ways to implement a cleaner workflow and changed it along the way .Besides that, I've never pushed directy to the `main` branch (except for readme updates).

Here I describe the workflow I had at the end of the project:

I used 2 permanent branches for the main worflow (`main` & `dev`) and small temporary branches for features development.

For implementing a new feature I pull `main` locally and create a feature branch out of it.
Once it's finished I push the feature branch to the Github repository. I create a pull request to merge into the `dev` branch, and then a pull request to merge `dev` into `main`.

To update a feature branch with the latest update, I pull `main` locally, merge it into `dev` locally to update it, and merge it to the feature branch. This way any conflict that may happen would be resolved on the local feature branch and would not affect `main`.

#### 3.2 Deployment

I use Heroku pipeline for continus delivery with 2 apps: staging and production.

The Github `main` branch serves the staging remote, and I use the "promote to production" button in the Heroku dashboard to push the code to the production's app remote.

The same APIs credentials are used for both apps.
###  4. To be improved

Looking back in the code few months afterwards, and especially after working in a professional environment, I realized few mistakes and improvements that can better the code quality:

- Formatting: I left few blank lines and forgot spaces around quotes or operators. I was sometimes inconsistent with the use of simple quotes / double quotes. I didn't left a blank line at the end of each file. Now I like to refer to the [Ruby style guide](https://github.com/rubocop/ruby-style-guide) and I use VScode extensions to help imporve the formatting.

- The history of my commits and workflow isn't perfect: I badly used `git add .`  and  commited many files with the same message. I pushed on the master branch the readme updates.
## II - Installation

1. Clone the project: open a terminal and type in
```
$ git clone https://github.com/yourname/EventBright.git
```
2. Change directory to `EventBright`:
```
$ cd EventBright
```
3. Download dependencies:

```
$ bundle install
```

4. Setup database:
```
$ rails db:create
$ rails db:migrate
$ rails db:seed
```

5. Start the server:
```
$ rails s
```

6. Go to `http://localhost:3000`

## Author
**Georges Atalla**

Email - georges_atalla@hotmail.fr

Portfolio - [www.georgesatalla.com](https://www.georgesatalla.com/)

Github - https://github.com/Ggs91/
