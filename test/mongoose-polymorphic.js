var chai = require('chai');
var mongoose = require('mongoose');
var mongoosePolymorphic = require('../index');
var expect = chai.expect;
var Bluebird = require('bluebird');

/*
  Setup test environment
 */
mongoose.connect('mongodb://localhost/mongoose-polymorphic');

mongoose.connection.on('error', function(err) {
  console.error('MongoDB error:', err);
  return console.error('Make sure a mongoDB server is running and accessible by this application');
});

var AlertSchema = new mongoose.Schema({
  name: 'String'
});

AlertSchema.plugin(mongoosePolymorphic);

AlertSchema.plugin(mongoosePolymorphic, {
  associationKey: 'parent',
  promise: Bluebird
});
mongoose.model('Alert', AlertSchema);

var Alert = mongoose.model('Alert');

var ItemSchema = new mongoose.Schema({
  name: 'String'
});

mongoose.model('Item', ItemSchema);

var Item = mongoose.model('Item');

function generateItem () {
  return new Item({
    name: 'A big item'
  });
};


/*
  Usage
 */
describe('Mongoose Polymorphic', function() {
  after(function(done) {
    mongoose.model('Alert').remove(function(err) {
      mongoose.model('Item').remove(function(err) {
        done(err);
      });
    });
  });

  describe('When standard plugin is applied to the Alert model', function() {
    it('should create a itemId attribute', function() {
      var alert = new Alert({
        name: 'Pig'
      });
      expect(alert.schema.paths).to.have.property('itemId');
    });

    it('should create an itemType attribute', function() {
      var alert = new Alert({
        name: 'Pig'
      });
      expect(alert.schema.paths).to.have.property('itemType');
    });

    describe('setItem(item)', function() {
      var item = generateItem();

      it('should set the itemId to the item.id', function() {
        var alert = new Alert({
          name: 'Pig'
        });
        expect(alert.itemId).to.equal(void 0);
        alert.setItem(item);
        expect("" + alert.itemId).to.equal("" + item.id);
      });

      it('should set the itemType to the Model name of the item', function() {
        var alert = new Alert({
          name: 'Pig'
        });
        expect(alert.itemType).to.equal(void 0);
        alert.setItem(item);
        expect(alert.itemType).to.equal("Item");
      });
    });

    describe('fetchItem()', function() {
      var item = generateItem();

      before(function(done) {
        item.save(done);
      });

      it('should get the item from the database', function(done) {
        var alert = new Alert({
          name: 'Pig'
        });
        alert.setItem(item);
        alert.fetchItem(function(err, foundItem) {
          expect(foundItem.id).to.equal(item.id);
          done(err);
        });
      });
    });
  });

  describe('When the plugin with option to use parent as polymorphic key is applied to the Alert model', function() {
    it('should create a parentId attribute', function() {
      var alert = new Alert({
        name: 'Pig'
      });
      expect(alert.schema.paths).to.have.property('parentId');
    });

    it('should create an parentType attribute', function() {
      var alert = new Alert({
        name: 'Pig'
      });
      expect(alert.schema.paths).to.have.property('parentType');
    });

    describe('setParent(item)', function() {
      var item = generateItem();

      it('should set the parentId to the item.id', function() {
        var alert = new Alert({
          name: 'Pig'
        });
        expect(alert.parentId).to.equal(void 0);
        alert.setParent(item);
        expect("" + alert.parentId).to.equal("" + item.id);
      });

      it('should set the parentType to the Model name of the item', function() {
        var alert = new Alert({
          name: 'Pig'
        });
        expect(alert.parentType).to.equal(void 0);
        alert.setParent(item);
        expect(alert.parentType).to.equal("Item");
      });
    });

    describe('fetchParent()', function() {
      var item = null;

      before(function(done) {
        item = new Item;
        item.save(done);
      });

      it('should get the item from the database', function(done) {
        var alert = new Alert({
          name: 'Pig'
        });
        alert.setParent(item);
        alert.fetchParent(function(err, foundItem) {
          expect(foundItem.id).to.equal(item.id);
          done(err);
        });
      });

      it('should get the item from the database using the given promise library', function() {
        var alert = new Alert({
          name: 'Pig'
        });
        alert.setParent(item);
        return alert.fetchParent().then(function(foundItem) {
          return expect(foundItem.id).to.equal(item.id);
        });
      });
    });
  });
});
