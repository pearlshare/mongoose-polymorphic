# Mongoose Polymorphic

Extends a child object to create a polymorphic association between itself and any parent object.

This is a plugin for Mongoose ODM to create polymorphic relationships.

## Setup

```coffee

mongoose = require('mongoose')
polymorphicMongoose = require('mongoose-polymorphic')

AlertSchema = new mongoose.Schema

  name: "String"

AlertSchema.plugin(polymorphicMongoose)
mongoose.model('Alert', AlertSchema)

```
## Usage

```coffee
Item = mongoose.model('Item')
item = new Item

Alert = mongoose.model("Alert")
alert = new Alert

alert.setItem(item)

alert.getItem (err, item) -> 
  console.log item

```

Adds method to get and set item and state attributes.






