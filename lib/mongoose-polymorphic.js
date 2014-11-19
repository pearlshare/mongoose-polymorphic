var mongoose = require('mongoose');

/*
  mongoose-polymorphic
  @param {Object} schema - mongoose schema to patch
  @param {Object} options - options to configure plugin
    @option {String} associationKey - base of association
    @option {String} promise - base of association
 */

module.exports = function(schema, options) {
  var associationKey, capitalizedAssociationKey, idKey, indexAdditions, required, schemaAdditions, typeKey;
  if (options == null) {
    options = {};
  }
  associationKey = options.associationKey || 'item';
  required = options.required || false;
  capitalizedAssociationKey = associationKey.charAt(0).toUpperCase() + associationKey.slice(1);
  idKey = "" + associationKey + "Id";
  typeKey = "" + associationKey + "Type";

  /*
    Build the schema
   */
  schemaAdditions = {};
  schemaAdditions[typeKey] = {
    type: 'String',
    required: required
  };
  schemaAdditions[idKey] = {
    type: mongoose.Schema.ObjectId,
    required: required
  };
  schema.add(schemaAdditions);

  /*
    Create a compound index for looking up the parent by the polymorphic child
   */
  indexAdditions = {};
  indexAdditions[idKey] = 1;
  indexAdditions[typeKey] = 1;
  schema.index(indexAdditions);

  /*
    Get and set the item using mongoose virtual attributes
    model.item          => returns object containing type and id
    model.item = item   => sets the itemId and itemType to that of the item
   */
  schema.virtual(associationKey).get(function() {
    var out = {};
    out['type'] = this.get(typeKey);
    out['id'] = this.get(idKey);
    return out;
  }).set(function(model) {
    this.set(idKey, model.id);
    this.set(typeKey, model.constructor.modelName);
    return this;
  });

  /*
    Build a setter method
    model.setItem(item)
    @param {Object} item - mongoose model instance
    @returns {Object} instance of model being modified
   */
  schema.methods["set" + capitalizedAssociationKey] = function(item) {
    var itemAttrs = {};
    itemAttrs[idKey] = item.id;
    itemAttrs[typeKey] = item.constructor.modelName;
    this.set(itemAttrs);
    return this;
  };

  /*
    Build a getter method
    model.fetchItem().then console.log
    model.fetchItem (err, item) -> console.log(err, item)
    @param {String} select (optional)
    @param {Function} callback
    @returns {Promise} if options.promise is provided and no callback
   */
  schema.methods["fetch" + capitalizedAssociationKey] = function(select, callback) {
    if (typeof select === 'function') {
      callback = select;
      select = '';
    }
    if (options.promise && !callback) {
      var deferred = options.promise.defer();
      mongoose.model(this.get(typeKey)).findById(this.get(idKey)).select(select).exec(function(err, doc) {
        if (err) {
          deferred.reject(err);
        } else {
          deferred.resolve(doc);
        }
      });
      return deferred.promise;
    } else {
      mongoose.model(this.get(typeKey)).findById(this.get(idKey)).select(select).exec(callback);
    }
  };
};
