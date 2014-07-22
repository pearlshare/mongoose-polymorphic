require('coffee-script')
mongoose = require("mongoose-q")()

###
  mongoose-polymorphic
  @param {Object} schema - mongoose schema to patch
  @param {Object} options - options to configure plugin
    @option {String} associationKey - base of association
###
module.exports = (schema, options = {}) ->

  associationKey = options.associationKey || 'item'
  required = options.required || false
  capitalizedAssociationKey = associationKey.charAt(0).toUpperCase() + associationKey.slice(1)

  idKey = "#{associationKey}Id"
  typeKey = "#{associationKey}Type"

  ###
    Build the schema
  ###
  schemaAdditions = {}
  schemaAdditions[typeKey] = 
    type: 'String'
    required: required

  schemaAdditions[idKey] =
    type: mongoose.Schema.ObjectId
    required: required
    
  schema.add schemaAdditions

  ###
    Create a compound index for looking up the parent by the polymorphic child
  ###
  indexAdditions = {}
  indexAdditions[idKey] = 1
  indexAdditions[typeKey] = 1
  schema.index indexAdditions

  ###
    Get and set the item using mongoose virtual attributes
    model.item          => returns Promise to fetch related item
    model.item = item   => sets the itemId and itemType to that of the item
  ###
  schema.virtual(associationKey)
    .get ->
      mongoose.model(@get(typeKey)).findById(@get(idKey)).execQ()
    .set (model) ->
      @set idKey, model.id
      @set typeKey, model.constructor.modelName

  ###
    Build a setter method
  ###
  schema.methods["set#{capitalizedAssociationKey}"] = (item) ->
    itemAttrs = {}
    itemAttrs[idKey] = item.id
    itemAttrs[typeKey] = item.constructor.modelName
    @set itemAttrs

  ###
    Build a getter method
  ###
  schema.methods["get#{capitalizedAssociationKey}"] = (callback) ->
    mongoose.model(@get(typeKey)).findById(@get(idKey)).execQ().nodeify(callback)