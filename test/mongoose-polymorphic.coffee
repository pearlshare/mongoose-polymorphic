mocha = require("mocha")
chai = require("chai")
mongoose = require('mongoose')
mongoosePolymorphic = require('../index')
expect = chai.expect


###
  Setup test environment
###

mongoose.connect('mongodb://localhost/mongoose-polymorphic')
mongoose.connection.on 'error', (err) ->
  console.error "MongoDB error:", err
  console.error 'Make sure a mongoDB server is running and accessible by this application'


# Define our alert (child model)
AlertSchema = new mongoose.Schema

  name: "String"

# Add our shiny plugin
AlertSchema.plugin mongoosePolymorphic
AlertSchema.plugin mongoosePolymorphic, associationKey: 'parent'

mongoose.model('Alert', AlertSchema)


# Define our item (parent model)
ItemSchema = new mongoose.Schema
  name: "String"

mongoose.model('Item', ItemSchema)

Item = mongoose.model('Item')
item = new Item(name: 'A big item')


###
  Usage
###
Alert = mongoose.model("Alert")

describe 'Mongoose Polymorphic', ->

  context 'When standard plugin is applied to the Alert model', ->

    it 'should create a itemId attribute', (done) ->
      alert = new Alert(name: 'Pig')
      expect(alert.schema.paths).to.have.property('itemId')
      done()


    it 'should create an itemType attribute', (done) ->
      alert = new Alert(name: 'Pig')
      expect(alert.schema.paths).to.have.property('itemType')
      done()


    describe 'setItem(item)', ->
      it 'should set the itemId to the item.id', (done) ->
        alert = new Alert(name: 'Pig')
        expect(alert.itemId).to.equal(undefined)
        alert.setItem(item)
        expect("#{alert.itemId}").to.equal("#{item.id}")
        done()

      it 'should set the itemType to the Model name of the item', (done) ->
        alert = new Alert(name: 'Pig')
        expect(alert.itemType).to.equal(undefined)
        alert.setItem(item)
        expect(alert.itemType).to.equal("Item")
        done()


    describe 'getItem()', ->
      before (done) ->
        item = new Item
        item.save (err) ->
          done()

      it 'should get the item from the database', (done) ->
        alert = new Alert(name: 'Pig')
        alert.setItem(item)
        alert.getItem (err, item) ->
          done()

  context 'When the plugin with option to use parent as polymorphic key is applied to the Alert model', ->

    it 'should create a parentId attribute', (done) ->
      alert = new Alert(name: 'Pig')
      expect(alert.schema.paths).to.have.property('parentId')
      done()


    it 'should create an parentType attribute', (done) ->
      alert = new Alert(name: 'Pig')
      expect(alert.schema.paths).to.have.property('parentType')
      done()


    describe 'setParent(item)', ->
      it 'should set the parentId to the item.id', (done) ->
        alert = new Alert(name: 'Pig')
        expect(alert.parentId).to.equal(undefined)
        alert.setParent(item)
        expect("#{alert.parentId}").to.equal("#{item.id}")
        done()

      it 'should set the parentType to the Model name of the item', (done) ->
        alert = new Alert(name: 'Pig')
        expect(alert.parentType).to.equal(undefined)
        alert.setParent(item)
        expect(alert.parentType).to.equal("Item")
        done()


    describe 'getParent()', ->
      before (done) ->
        item = new Item
        item.save (err) ->
          done()

      it 'should get the item from the database', (done) ->
        alert = new Alert(name: 'Pig')
        alert.setParent(item)
        alert.getParent (err, item) ->
          done()







