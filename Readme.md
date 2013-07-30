Active Record Class for NodeJS (The Readme is being drafted)
===============


## Installation

For the moment the installation is manual, you must download the folder and put it in your "node_modules" folder.
When you put it in the right folder, don't forget to go to this folder and launch this command :
```Shell
	npm install
```
(In the following days, I will put it on NPM)


## Init the database configuration

(Before starting, you must know that ActiveRecord is only compatible with MySQL.)
To do that, you just change the the "database.json" file.



## How it works ?

At first, you need to create a model file which will contain all your model !
In this file, you must "require" the ActiveRecord Class with this code :
```javascript
	var ActiveRecord = require('ActiveRecord');
```

### Init the user class.

After doing this, you can create your first model like this :
```javascript
	var Users = function(data, in_association, callback){
		ActiveRecord.call(this,{
		    table_name : 'users'
		    class_name: Users
		    id_is_uuid : true
		    name_id: 'id'
		    data : data
		    in_association: in_association
		    callback: callback
		})
	}
```
As you can see, the values which can change are
- the "table_name" var which is the name of the table in your database
- the "class_name" var which is the name of your class. (Be careful, don't use the quote)
- the "id_is_uuid" var which indicates if the row id is define with the uuid function in mysql
- the "name_id" var which indicates the name of the idenfifier of the table. This key is optional because by default the "name_id" is equal to "id"


### Create an instance of the users class

To create an instance of the users class, you just need to user the "new" keyword like this :
```javascript
	var user = new Users()
```

#### Create function (asynchronous)
If you have data, and you want to inject this data in the user object, you can do this :
```javascript
	var data = {
		name: 'name'
	}
	user.create(data, function(){
		console.log user.name
	})
```
It's an asynchronous function because before injecting data, I get back the name of column in order to verify if the sent data correspond to the column of the database. (The class gets back the name of column of the table once. After, it stocks in static var)



#### Find function (asynchronous)

To find a row with its id, we have the "find" function which works like this :
```javascript
	user.find(1, function(){
		console.log(user.name)
	})
```
The callback doesn't take argument because the datas are injected in the object which calls the find function, here the "user" object.


#### Where function (asynchronous)
The "where" function permits you to retrieve data like a where clause :
```javascript
	user.where("id = ? AND name = ?", [1, '%John%'] function(users){
		console.log(users)
		users[0].name = "Test"
		users[0].save()
	})
```
Contrary to the 'find' method, the callback takes an argument which corresponds to result of the query.


#### all function (asynchronous)
The "all" function permits you to retrieve all the datas in the table in relation with the object :
```javascript
	user.all(function(users){
		console.log(users)
		users[0].name = "Test"
		users[0].save()
	})
```
Here, the callback is the same than the "where" callback


#### Delete function (asynchronous)

The "delete" function will delete the object from the database and will initialize the object as a new instance.
```javascript
	user.find(1, function(){
		user.delete(function(){
			console.log(user)
			# Return the object user initialize
		})
	})
```
Like the other function, the "delete" method takes a callback as argument


### What about the relations between models

If you have relations between databases, you can indicate to the ActiveRecord class when you call it in your User class for example :
```javascript
	Users = function(data, in_association, callback){
		ActiveRecord.call(this,{
			table_name : 'users'
			class_name: Users
			id_is_uuid : true
			data : data
			in_association: in_association
			callback: callback
			belongs_to : [{
			  model: Entreprises
			  model_string: 'Entreprises'
			  key: 'id_entreprise'
			  name_row: 'crazy_entreprise'
			}]
		})
	}


	Entreprises = (data = null, in_association = null, callback = null)->
		ActiveRecord.call(this, {
			table_name : 'entreprises'
			class_name: Entreprises
			id_is_uuid : true
			data : data
			in_association: in_association
			callback: callback
			has_many : [{
			   model: Users
			   model_string: 'Users'
			   key: 'id_entreprise'
			   name_row: 'crazy_people'
			}]
		})
```
As you can see, the "Users" class implements a "belongs_to" relation with the "Entreprises" class.
The "belong_to", "has_many" and "has_one" keys are equals to an array of object as we've seen before.
These objects are composed by four keys whose the "name_row" key is optionnal. The others are mandatory.

More details about these keys :
- "model" key is taken as a class (No quote and respect the case sensitive)
- "model_string" key is taken as the class in a string
- "key" key is taken as the name of the row which permits the relation between the two tables.
	- Here the name of the key is "id_entreprise" and is found in the "users" table.
- "name_row" key is taken as the name of the key which permits you to query the association in the object. By default it's the "model_string" value which is considered

(The "in_assocation" key is mandatory because it used for the relation between the models. It permit to avoid infinity loop between the models).

An example is better than words :

```javascript
	var user = new Users()
	user.find(1, function(){
		console.log(user.crazy_entreprise.name)
		// Return the name of the entreprise which the user belongs to
		
		console.log(user.crazy_entreprise.crazy_people)
		// Return an array which contain all the users who belongs to this entreprise
	})
```


### How to save a relation ?

```javascript
	user = new Users()
	user.find(1, function(){
		user.crazy_entreprise.name = 'test name entreprise'
		user.crazy_entreprise.save()
		// This command will save only the "crazy_entreprise"

		user.crazy_entreprise.crazy_people[0].first_name = 'my first name'
		user.crazy_entreprise.crazy_people[0].save()
		// This command will save only the "crazy_people" with the index 0
	})
```


The last word
===============

This class works but I can't garantee its stability because it's the first version. I can't wait to your feedbacks, they could help me to improve it/make it better




	