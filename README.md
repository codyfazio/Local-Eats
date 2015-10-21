# Local-Eats

Capstone Project (aka Local Eats)

This app centers around the idea that certain places are known for certain types of food. It provides a way to view information about these foods, find them, and keep a journal of new foods the user tries. It presents information to the user in three main views. 
	
	•	Near Me: This view displays a table of foods nearest to the user. Each food also has a corresponding rating. Tapping on a a food segues to a detail view (more on the detail view below). A collection view at the bottom presents a selection of restaurants near the user that serve those foods. This restaurant information is obtained through Yelp, and allows the user to view more information either via an installed Yelp App, or Yelp.com. 

	•	Local Food: This view displays the entire database of food types, their locations, and their ratings. As in Near Me, tapping on an item presents information about that food. There is also a search bar for quickly finding foods.

	•	Journal: The user’s private journal of food. It displays a list of entries the user has made about food items and the date the entries were created. Tapping the entry presents a detail view(nearly identical to that of Near Me and Local Food). Tapping the plus button allows the user to create a new entry. Entries can be deleted via standard swiping. There is also a search bar for locating entries by food type. 

	
Other views…

	•	Detail View: After selecting a food or entry form the lists, the user is presented with a detail view of the item. The top view displays the name, location, rating image, and random user submitted image from the iCloud database. The rating image is of one of three varieties: a solid green thumb indicating a like, a solid red thumb indicating a dislike, and an empty red thumb indicating no rating. The mid view shows pages of information about the food (a description of the food, history, and recommendations). The bottom view displays a collection view of restaurant recommendations for that specific item in its indigenous area.
	•	Adding a journal entry: tapping the plus button presents a view for adding a new entry. Tapping select food presents a list of foods. Once the user has selected a food, they can select an eatery. A map view is presented and populated with restaurants in the foods indigenous area. A search bar at the top allows the user find any eatery, regardless of its location. The user can then enter notes, rate the food, add a photo from their library or camera and then create the entry. The rating and photo are then uploaded to iCloud to be used anonymously for crowd sourced food rating and food images. 

Under the hood…

This app uses a combination of an iCloud database, the Yelp API, and the Foursquare API to obtain necessary information. Due to the difficulty of dealing with OAuth1a, I chose to use a 3rd party library for working with Yelp. However, I found that the images Yelp returns are very low resolution and there were cases were a business turned out to be permanently closed though responses indicated it was open. To combat these two issues, I used Foursquare to verify the existence of the eateries and to get larger images. 

