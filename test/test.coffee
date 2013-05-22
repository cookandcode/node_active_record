assert = require("assert")
should = require('should')
ActiveRecord = require("ActiveRecord")


# CLASS TEST
Entreprises = (data = null, in_association = null, callback = null)->
  ActiveRecord.call(this, {
    table_name : 'entreprises'
    class_name: Entreprises
    id_is_uuid : true
    data : data
    in_association: in_association
    callback: callback
    belongs_to: [{
      model: Salaries
      model_string: 'Salaries'
      key: 'id_contact'
      name_row: 'big_boss'
    }]
  })


Salaries = (data = null, in_association = null, callback = null)->
  ActiveRecord.call(this, {
    table_name : 'salaries'
    class_name: Salaries
    id_is_uuid : true
    data : data
    in_association: in_association
    callback: callback
    has_many: [{
      model: Entreprises
      model_string: 'Entreprises'
      key: 'id_contact'
      name_row: 'my_entreprise'
    }]
    belongs_to:[{
      model: Salaries
      model_string: 'Salaries'
      key: 'responsable'
      name_row: 'big_boss_ever'
    }]
  })



# BEGINNING OF TEST
describe('ActiveRecord', ()->
  describe('#init()', ()->
    it('should init without error', (done)->
      active = new ActiveRecord({});
      done()
    )
  )


  describe('#extend()', ()->
    it('should extend without error', (done)->
      salarie = new Salaries()
      salarie.should.be.an.instanceof(Salaries)
      done()
    )
  )


  describe('#assocation', ()->
    it('should return association without error', (done)->
      entreprise = new Entreprises()
      entreprise.find(1, ()->
        big_boss = entreprise.big_boss
        big_boss.should.be.an.instanceof(Salaries)
        done()
      )
    )
  )

  describe('#save', ()->
    it('should save object without error', (done)->
      entreprise = new Entreprises()
      entreprise.find(1, ()->
        date = new Date()
        entreprise.nom = 'test_'+date
        entreprise.save()

        new_entreprise = new Entreprises()
        new_entreprise.find(1, ()->
          new_entreprise.nom.should.equal('test_'+date)
          done()
        )
      )
    )
  )

  describe('#save association', ()->
    it('should save association object without error', (done)->
      entreprise = new Entreprises()
      entreprise.find(1, ()->
        date = new Date()
        entreprise.big_boss.nom = 'nom_'+date
        entreprise.big_boss.save()

        new_entreprise = new Entreprises()
        new_entreprise.find(1, ()->
          new_entreprise.big_boss.nom.should.equal('nom_'+date)
          done()
        )
      )
    )
  )


  describe('#where', ()->
    it('should find object with where', (done)->
      entreprise = new Entreprises()
      entreprise.where("id = ? AND nom LIKE ?", [1, '%test%'], (entreprises_where)->
        if entreprises_where.length > 0
          entreprises_where[0].should.be.an.instanceof(Entreprises)
          done()
        else
          done()
      )
    )
  )


  describe('#all()', ()->
    it('should find object with where', (done)->
      entreprise = new Entreprises()
      entreprise.where("id = ? AND nom LIKE ?", [1, '%test%'], (entreprises_where)->
        if entreprises_where.length > 0
          entreprises_where[0].should.be.an.instanceof(Entreprises)
          done()
        else
          done()
      )
    )
  )
)