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

(Before started, you must that ActiveRecord is only compatible with MySQL.)
To do that, you just change the the "database.json" file.



## How it works ?

At first, you need to create a model file which will contain all your model !
In this file, you must "require" the ActiveRecord Class with this code :
```javascript
	var ActiveRecord = require('ActiveRecord');
```

### Init the user class.

When you do this, you can now create your first model like this :
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
As you can see, the value which can change are
- the "table_name" var which is the name of the table in your database
- the "class_name" var which is the name of your class. (Be careful, don't use the quote)
- the "id_is_uuid" var which indicate if the row id is define with the uuid function in mysql
- the "name_id" var which indicate the name of the idenfifier of the table. This key is optional because by default the "name_id" is equal to "id"


### Create an instance of the users class

To create an instance of the users class, you juste need to user the "new" keyword like this :
```javascript
	var user = new Users()
```

#### Create function (asynchronous)
If you have data, and you want inject this data in the user object, you can do this :
```javascript
	var data = {
		name: 'name'
	}
	user.create(data, function(){
		console.log user.name
	})
```
It's an asynchronous function because before injecting data, I get back the name of column in order to verify if the data send correspond to the column of the database. (The class get back the name of column of the table just one time. After, it stock in static var)



#### Find function (asynchronous)

To find a row with his id, we have the "find" function which works like this :
```javascript
	user.find(1, function(){
		console.log(user.name)
	})
```
The callback doesn't take argument because the data are injected in the object which call the find function, here the "user" object.


#### Where function (asynchronous)
The "where" function permit you to retrieve data like a where clause :
```javascript
	user.where("id = ? AND name = ?", [1, '%John%'] function(users){
		console.log(users)
		users[0].name = "Test"
		users[0].save()
	})
```
Contrary to the 'find' method, the callback take an argument which correspond to result of the query.


#### all function (asynchronous)
The "all" function permit you to retrieve all the data in the table in relation with the object :
```javascript
	user.all(function(users){
		console.log(users)
		users[0].name = "Test"
		users[0].save()
	})
```
Here, the callback is the same than the "where" callback


#### Delete function (asynchronous)

The "delete" function will delete the object from the database and initialize the object as a new instance.
```javascript
	user.find(1, function(){
		user.delete(function(){
			console.log(user)
			# Return the object user initialize
		})
	})
```
Like the other function, the "delete" method take a callback as argument


### What about the relation between model

If you have relation between database, you can indicate to the ActiveRecord class when you call it in your User class for example :
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
As you can see, the "Users" class implement a "belongs_to" relation with the "Entreprises" class.
The "belong_to", "has_many" and "has_one" key are equal to an array of object as seeing above.
These object are composed by four key whose the "name_row" key is optionnal. The other are mandatory.
More details about these key :
- "model" key is taken as a class (No quote and respect the case sensitive)
- "model_string" key is taken as the class in a string
- "key" key is taken as the name of the row which permit the relation between the two table.
	- Here the name of the key is "id_entreprise" and is found in the "users" table.
- "name_row" key is taken as the name of the key which permit you to query the association in the object. By default it's the "model_string" value which is considered

An example is better than words :

```javascript
	user = new Users()
	user.find(1, function(){
		console.log(user.crazy_entreprise.name)
		# Return the name of the entreprise which the user belongs to
		
		console.log(user.crazy_entreprise.crazy_people)
		# Return an array which contain all the users who belongs to this entreprise
	})
```


### How save a relation ?

```javascript
	user = new Users()
	user.find(1, function(){
		user.crazy_entreprise.name = 'test name entreprise'
		user.crazy_entreprise.save()
		# This command will save only the "crazy_entreprise"

		user.crazy_entreprise.crazy_people[0].first_name = 'my first name'
		user.crazy_entreprise.crazy_people[0].save()
		# This command will save only the "crazy_people" with the index 0
	})
```


The end word
===============

This class works but I'm not guarantee is stability because it's the first version but I will be happy to have returned to improve this class.




	