mocha = require('mocha')
chai = require('chai')
mongoose = require('mongoose')
mongoosePolymorphic = require('../index')
expect = chai.expect
Bluebird = require('bluebird')

###
  Setup test environment
###

mongoose.connect('mongodb://localhost/mongoose-polymorphic')
mongoose.connection.on 'error', (err) ->
  console.error 'MongoDB error:', err
  console.error 'Make sure a mongoDB server is running and accessible by this application'


# Define our alert (child model)
AlertSchema = new mongoose.Schema
  name: 'String'

# Add our shiny plugin
AlertSchema.plugin mongoosePolymorphic
AlertSchema.plugin mongoosePolymorphic, associationKey: 'parent', promise: Bluebird

mongoose.model('Alert', AlertSchema)


# Define our item (parent model)
ItemSchema = new mongoose.Schema
  name: 'String'

mongoose.model('Item', ItemSchema)

Item = mongoose.model('Item')

generateItem = ->
  new Item(name: 'A big item')

###
  Usage
###
Alert = mongoose.model('Alert')

describe 'Mongoose Polymorphic', ->

  after (done) ->
    mongoose.model('Alert').remove (err) ->
      mongoose.model('Item').remove (err) ->
        done(err)

  context 'When standard plugin is applied to the Alert model', ->

    it 'should create a itemId attribute', ->
      alert = new Alert(name: 'Pig')
      expect(alert.schema.paths).to.have.property('itemId')


    it 'should create an itemType attribute', ->
      alert = new Alert(name: 'Pig')
      expect(alert.schema.paths).to.have.property('itemType')


    describe 'setItem(item)', ->
      item = generateItem()

      it 'should set the itemId to the item.id', ->
        alert = new Alert(name: 'Pig')
        expect(alert.itemId).to.equal(undefined)
        alert.setItem(item)
        expect("#{alert.itemId}").to.equal("#{item.id}")

      it 'should set the itemType to the Model name of the item', ->
        alert = new Alert(name: 'Pig')
        expect(alert.itemType).to.equal(undefined)
        alert.setItem(item)
        expect(alert.itemType).to.equal("Item")


    describe 'fetchItem()', ->
      item = generateItem()

      before (done) ->
        item.save(done)

      it 'should get the item from the database', (done) ->
        alert = new Alert(name: 'Pig')
        alert.setItem(item)
        alert.fetchItem (err, foundItem) ->
          expect(foundItem.id).to.equal(item.id)
          done(err)

  context 'When the plugin with option to use parent as polymorphic key is applied to the Alert model', ->

    it 'should create a parentId attribute', ->
      alert = new Alert(name: 'Pig')
      expect(alert.schema.paths).to.have.property('parentId')


    it 'should create an parentType attribute', ->
      alert = new Alert(name: 'Pig')
      expect(alert.schema.paths).to.have.property('parentType')


    describe 'setParent(item)', ->
      item = generateItem()

      it 'should set the parentId to the item.id', ->
        alert = new Alert(name: 'Pig')
        expect(alert.parentId).to.equal(undefined)
        alert.setParent(item)
        expect("#{alert.parentId}").to.equal("#{item.id}")

      it 'should set the parentType to the Model name of the item', ->
        alert = new Alert(name: 'Pig')
        expect(alert.parentType).to.equal(undefined)
        alert.setParent(item)
        expect(alert.parentType).to.equal("Item")


    describe 'fetchParent()', ->
      item = null

      before (done) ->
        item = new Item
        item.save(done)

      it 'should get the item from the database', (done) ->
        alert = new Alert(name: 'Pig')
        alert.setParent(item)
        alert.fetchParent (err, foundItem) ->
          expect(foundItem.id).to.equal(item.id)
          done(err)

      it 'should get the item from the database using the given promise library', (done) ->
        alert = new Alert(name: 'Pig')
        alert.setParent(item)
        alert.fetchParent()
          .then (foundItem) ->
            expect(foundItem.id).to.equal(item.id)
          .nodeify(done)
