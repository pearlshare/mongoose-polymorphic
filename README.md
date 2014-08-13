# Mongoose Polymorphic

A mongoose plugin to create polymorphic relationships. The relationship enables the extended object to belong to any other mongoose object.


## Setup

```coffee

mongoose = require('mongoose')
mongoosePolymorphic = require('mongoose-polymorphic')

# Create a schema
AlertSchema = new mongoose.Schema
  name: "String"

# Apply the plugin
AlertSchema.plugin mongoosePolymorphic

mongoose.model 'Alert', AlertSchema

```

## Usage

```coffee
Item = mongoose.model 'Item'
item = new Item

Alert = mongoose.model "Alert"
alert = new Alert

alert.setItem(item)

alert.fetchItem (err, item) ->
  if err
    console.log err
  else
    console.log item

```

## API

mongoose-polymorphic is a mongoose plugin. It takes options to set the association and dynamically creates getters and setters.

```coffee
mongoosePolymorphic = require('mongoose-polymorphic')

AlertSchema.plugin mongoosePolymorphic, options
```

By default this will create schema keys 'itemId' and 'itemType'. It also defines methods 'setItem' and 'fetchItem'.

Options:

* associationKey {String} - define a custom association name (defaults to 'item'). This changes the base name of mappings and methods such as associationKey: 'parent' will create mappings 'parentId' and 'parentType'





