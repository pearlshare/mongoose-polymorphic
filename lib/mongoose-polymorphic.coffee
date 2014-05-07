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

  # Build the schema
  schemaAdditions = {}
  schemaAdditions["#{associationKey}Type"] = 
    type: 'String'
    required: required

  schemaAdditions["#{associationKey}Id"] =
    type: mongoose.Schema.ObjectId
    required: required
    
  schema.add schemaAdditions

  indexAdditions = {}
  indexAdditions["#{associationKey}Id"] = 1
  indexAdditions["#{associationKey}Type"] = 1
  schema.index indexAdditions

  # Build the getter/setter methods
  schema.methods["set#{capitalizedAssociationKey}"] = (item) ->
    itemAttrs = {}
    itemAttrs["#{associationKey}Id"] = item.id
    itemAttrs["#{associationKey}Type"] = item.constructor.modelName
    @set itemAttrs

  schema.methods["get#{capitalizedAssociationKey}"] = (callback) ->
    mongoose.model(@["#{associationKey}Type"]).findById(@["#{associationKey}Id"]).execQ().nodeify(callback)