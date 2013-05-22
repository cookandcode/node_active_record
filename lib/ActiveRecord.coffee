# # DATA
# # ---> table, row important like the deleted row

# # FUNCTION 
# # ----> update, create, find, save, where, all


# # ----------------------------------- RULES ---------------------------------------------------
# # WHEN I GET BACK DATA OR INSERT OR UPDATE, CALLBACK IS NECESSARY BECAUSE I MUST WAIT THE DATA
# # SO IT'S NECESSARY TO ADD CALLBACK TO CONTINUE YOUR ALGO
# # BUT WHEN THE FIND FUNCTION RETURN NOTHING BECAUSE, THE FUNCTION ASSIGN THE VALUE OF EACH ROW TO
# # THE INSTANCE 
# # ---------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------
# ------------------ ACTIVE RECORD WITH CACHED FUNCTION PATTERN ----------------------------------------
# ------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------
# # DATA
# # ---> table, row important like the deleted row

# # FUNCTION 
# # ----> update, create, find, save, where, all


# # ----------------------------------- RULES ---------------------------------------------------
# # WHEN I GET BACK DATA OR INSERT OR UPDATE, CALLBACK IS NECESSARY BECAUSE I MUST WAIT THE DATA
# # SO IT'S NECESSARY TO ADD CALLBACK TO CONTINUE YOUR ALGO
# # BUT WHEN THE FIND FUNCTION RETURN NOTHING BECAUSE, THE FUNCTION ASSIGN THE VALUE OF EACH ROW TO
# # THE INSTANCE 
# # ---------------------------------------------------------------------------------------------

mysql   = require('mysql')
uuid = require('node-uuid');

config_db = require('../database.json')

config_db_pool = require('../database.json')


connection = mysql.createConnection(config_db);


# VAR STATIC TO STORE ROWS OF A CLASS ONE TIME --
my_rows_global = {}

# -----------------------------------------
# -----------------------------------------
# --- FUNCTION FOR GET THE ROWS IN DB -----
# -----------------------------------------
# -----------------------------------------
getRows = (that, callback)->
  # that = this
  if !my_rows_global[that['config']['my_table_name']]? || my_rows_global[that['config']['my_table_name']].length == 0
    connection.query('SHOW COLUMNS FROM '+that['config']['my_table_name'], (err, rows, fields)->
      my_rows_global[that['config']['my_table_name']] = rows
      # _defineProperties(that)

      if callback?
        callback()
    )
  else
    # _defineProperties(that)
    if callback?
      callback()
      true
  true

# -----------------------------------------
# -----------------------------------------
#  FUNCTION TO INIT VAR WHEN CREATE NEW OBJECT 
# -----------------------------------------
# -----------------------------------------
inject_data = (that, data)->
  # that = this
  if data?
    rows_ = my_rows_global[that['config']['my_table_name']]
    length_row = rows_.length - 1 
    for k in [0..length_row]
      v = rows_[k]
      that[v['Field']] = data[v['Field']]
  true


_defineProperties = (that)->
  # that = this
  rows_ = my_rows_global[that['config']['my_table_name']]
  length_row = rows_.length - 1 
  for k in [0..length_row]
      v = rows_[k]
      # -- CLOSURE TO HAVE -----------
      # -- THE GOOD VALUE VAR --------
      # -- WHEN I CALL GET AND SET ---
      
      do (v)->
        get_ = ()->
          return v['Field']
        set_ = (val)->
          # that['config']['row_modified'][v['Field']] = true
          v['Field'] = val
          true

        Object.defineProperty(that, v['Field'],
          configurable: true
          enumerable: true 
          get: get_
          set: set_
        )


  true




getTableName = ()->
  return this['config']['my_table_name']

# -----------------------------------------
# -----------------------------------------
# --- FUNCTION FOR INSERT VALUE IN DB -----
# -----------------------------------------
# -----------------------------------------
association = (that, callback = null )->
  # that = this
  loading = 0
  belongs_to = that['config']['belongs_to']
  has_many = that['config']['has_many']
  has_one = that['config']['has_one']
  name_id = that['config']['name_id']

  # -----------------------------------------
  # ------- IF ASSOC BELONGS_TO EXIST ---------
  length_belong = belongs_to.length - 1

  if length_belong >= 0
    for key in [0..length_belong]
      belongs = belongs_to[key]

      test_model = new belongs['model']()
      key_name = belongs['key']
      if that['config']['in_association']['model'] == test_model.getTableName() && key_name ==  that['config']['in_association']['key_name'] && (that['config']['in_association']['type'] == 'has_many' || that['config']['in_association']['type'] == 'has_one')
        continue


      model_lower = if belongs.name_row? then belongs.name_row else belongs['model_string'].toLowerCase()
      in_association_send = {
        model: that['config']['my_table_name']
        type: 'belongs_to'
        key_name: key_name
      }

      that[model_lower] = new belongs['model'](null,in_association_send)
      
      
      if that[key_name] != null && that[key_name] != undefined
        loading = loading + 1
        that[model_lower].find(that[key_name], ()->
          loading = loading - 1
        )

  # -----------------------------------------
  # ------- IF ASSOC HAS_MANY EXIST ---------
  length_has_many = has_many.length - 1
  if length_has_many >= 0
    for key in [0..length_has_many]
      many = has_many[key]
      # test_model = new many['model']()
      # if that['config']['in_association']['model'] == test_model.getTableName() && that['config']['in_association']['type'] == 'belongs_to'
      #   continue

      model_lower = if many.name_row? then many.name_row else many['model_string'].toLowerCase()
      key_name = many['key']
      in_association_send = {
        model: that['config']['my_table_name']
        type: 'has_many'
        key_name: key_name
      }

      has_many_call = new many['model'](null, in_association_send)
    

      if that[name_id] != null && that[name_id] != undefined
        loading = loading + 1
        has_many_call.where(key_name+'= ?',[that[name_id]], (has_many_assoc)->
          loading = loading - 1
          that[model_lower] = has_many_assoc
        )

  # -----------------------------------------
  # -------- IF ASSOC HAS_ONE EXIST ---------
  length_has_one = has_one.length - 1
  if length_has_one >= 0
    for key in [0..length_has_one]
      one = has_one[key]

      test_model = new one['model']()
      if that['config']['in_association']['model'] == test_model.getTableName() && that['config']['in_association']['type'] == 'belongs_to'
        continue

      loading = true
      model_lower = if one.name_row? then one.name_row else one['model_string'].toLowerCase()
      key_name = one['key']
      in_association_send = {
        model: that['config']['my_table_name']
        type: 'has_one'
        key_name: key_name
      }
      has_one_call = new one['model'](null, in_association_send)


      # ---- QUERY TO RETRIEVE THE ASSOC ------
      if that[name_id] != null && that[name_id] != undefined
        loading = loading + 1
        has_one_call.where(key_name+'= ? LIMIT 0,1',[that[name_id]], (has_one_assoc)->
          loading = loading - 1
          that[model_lower] = has_one_assoc[0]
        )


  # --- IF LOADING IS OVER ------
  if loading == 0
    callback()
  else
    # --- IF NOT, I REFRESH EACH 10 MS TO SEE WHEN LOADING IS OVER -------
    interval = setInterval(()->
      if loading == 0
        clearInterval(interval)
        callback()
    , 10)


true


# -----------------------------------------
# -----------------------------------------
#  FUNCTION TO SAVE ASSOCIATION/RELATION
# -----------------------------------------
# -----------------------------------------
save_association = ()->
  # TO DO



    





# -----------------------------------------
# -----------------------------------------
# ------- FUNCTION FOR SAVE DATA ----------
# -----------------------------------------
# -----------------------------------------
new_ = (data, callback)->
  that = this
  getRows(that,()->
    inject_data(that, data)
    if callback?
      callback()
  )

  



# -----------------------------------------
# -----------------------------------------
# ------- FUNCTION FOR SAVE DATA ----------
# -----------------------------------------
# -----------------------------------------
save = (save_obj = {})->
  that = this
  # save_obj = 
  #     data : {}
  #     callback : ()->
  # ------- IF THE INIT ROW HAD NOT DONE -------
  if !my_rows_global[that['config']['my_table_name']]? || my_rows_global[that['config']['my_table_name']].length == 0
    getRows(that, ()->
      that.save()
      true
    )
    return true


  if save_obj? && save_obj.data?
    inject_data(this, save_obj.data)

  callback = null
  callback = save_obj.callback if save_obj? && save_obj.callback?


  if !that[that['config']['name_id']]?
    if that['config']['is_uuid']
      that[that['config']['name_id']] = uuid.v1()

    insert_value(that, callback)
  else
    # IF NOT ALREADY SAVING DATA
    update_value(that, callback)
  true







# -----------------------------------------
# -----------------------------------------
# -- FUNCTION TO FIND ROWS WITH THE ID ----
# -----------------------------------------
# -----------------------------------------
find = (id, callback)->
  that = this

  request_find = "SELECT * FROM #{that['config']['my_table_name']} WHERE #{that['config']['name_id']} = ?"
  connection.query(request_find, [id], (err, result)->
      if result.length == 0
        throw "ERROR : This request :'"+request_find+"' return nothing"
      else
        rows_ = my_rows_global[that['config']['my_table_name']]
        length_row = rows_.length - 1
        for k in [0..length_row]
          v = rows_[k]
          that[v['Field']] = result[0][v['Field']]

        association(that, callback)
  )


# -----------------------------------------
# -----------------------------------------
# ---- FUNCTION TO FIND ALL THE ROWS ------
# -----------------------------------------
# -----------------------------------------
all = (callback)->
  that = this
  if !my_rows_global[that['config']['my_table_name']]?|| my_rows_global[that['config']['my_table_name']].length == 0
    getRows(that, ()->
      that.all(callback)
    )
    return true

  request_all = "SELECT * FROM #{that['config']['my_table_name']}"

  if that['config']['my_constraint'] != ''
    request_all = request_all+' WHERE '+that['config']['my_constraint']
  
  
  connection.query("SELECT COUNT(*) AS count FROM #{that['config']['my_table_name']}", (err, result_count)->
    count_data = result_count[0].count
    get_data_all_where(that, count_data, request_all, [], callback)
  )


# -----------------------------------------
# -----------------------------------------
# - FUNCTION TO FIND THE ROWS WITH WHERE --
# -----------------------------------------
# -----------------------------------------
where = (condition, array_, callback)->
  that = this
  # condition must be = ' name = ? OR last_name = ?'

  request_WHERE = "SELECT * FROM #{that['config']['my_table_name']} WHERE "+condition
  request_WHERE_count = "SELECT COUNT(*) as count FROM #{that['config']['my_table_name']} WHERE "+condition

  connection.query(request_WHERE_count, array_, (err, result_count)->
    throw err if err
    count_data = result_count[0].count
    get_data_all_where(that, count_data, request_WHERE, array_, callback)
  )


# -----------------------------------------
# -----------------------------------------
# - FUNCTION TO DELETE ONE ROW --
# -----------------------------------------
# -----------------------------------------
delete_ = (callback)->
  that = this
  request_delete = "DELETE FROM #{that['config']['my_table_name']} WHERE #{that['config']['name_id']} = ?"
  connection.query(request_delete, [that[that['config']['name_id']]], (err, result)->
    for k,v of my_rows_global[that['config']['my_table_name']]
      delete that[v['Field']]
    # DELETE RELATION
    for k, value of that.config.belongs_to
      name = if value.name_row? then value.name_row else value['model_string'].toLowerCase()
      delete that[name]
    for k,value of that.config.has_many
      name = if value.name_row? then value.name_row else value['model_string'].toLowerCase()
      delete that[name]
    for k, value of that.config.has_one
      name = if value.name_row? then value.name_row else value['model_string'].toLowerCase()
      delete that[name]
    
    if callback?
      callback()
  )


get_data_all_where = (that, count_data, request, array_data, callback)->
    my_rows_ = my_rows_global[that['config']['my_table_name']]
    infos_rec = that['config']['infos_receive']

    if count_data > 0
      loading = count_data
      object_results = []
      config_db_pool['connectionLimit'] = 10000
      config_db_pool['queueLimit'] = 10000
      pool = mysql.createPool(config_db_pool)

      get_where = (special_query)->
        do (special_query)->  
          setTimeout(()->
            pool.getConnection((err, connection__)->
              throw err if err

              connection__.query(special_query, array_data, (err, results_)->
                length_result = results_.length - 1
                for key in [0..length_result]
                  _callback = ()->
                    loading = loading - 1
                  
                  # TRANSFORM ARRAY IN OBJECT
                  object = new that.config['my_class_name'](results_[key], that.config.in_association, _callback)
                  object_results.push(object)

                connection__.end()
              ) 
            )
          ,0)

      if count_data > 500
        end = Math.ceil(count_data / 3)
        for key_r in [0..count_data] by end
          special_query = request+' LIMIT '+key_r+','+end
          get_where(special_query)
      else
        get_where(request)


      if loading == 0
        callback(object_results)
      else
        interval = setInterval(()->
          if loading == 0
            clearInterval(interval)
            callback(object_results)
        ,10)
    else
      callback([])


# -----------------------------------------
# -----------------------------------------
# --- FUNCTION FOR INSERT VALUE IN DB -----
# -----------------------------------------
# -----------------------------------------
insert_value = (that, callback)->
  # that = this
  # INSERT HERE 
  insert_request = "INSERT INTO #{that['config']['my_table_name']} ( "
  values_request = ' VALUES ( '
  array_value = []
  can_comma = false
  
  rows_ = my_rows_global[that['config']['my_table_name']]
  length_row = rows_.length - 1
  for k in [0..length_row]
    value = rows_[k]
    name_field = value['Field']
    value_field = that[name_field]

    if can_comma
      insert_request = insert_request+', '
      values_request = values_request+', '


    if name_field == that['config']['name_id']
      if that['config']['is_uuid']
        can_comma = true
        insert_request = insert_request+' '+name_field
        values_request = values_request+' ? '
        array_value.push(value_field)
    else
      can_comma = true
      insert_request = insert_request+' '+name_field
      values_request = values_request+' ?'
      if value_field? && value_field != ''
        array_value.push(value_field)
      else
        if value['Null'] == 'NO'
          if value['Type'] == 'datetime'
            date_now = new Date()
            array_value.push(date_now)
            value_field = date_now
          else if /^varchar/.test(value['Type'])
            data_varchar = '1'
            array_value.push(data_varchar)
            value_field = data_varchar
          else
            array_value.push(value['Default'])
            value_field = value['Default']
        else
          array_value.push(value['Default'])
          value_field = value['Default']


  insert_request = insert_request+' ) '
  values_request = values_request+' ) '

  insert_request = insert_request+values_request

  connection.query(insert_request, array_value, (err, result)->
    throw err if err
    if callback?
      callback()
  )

true


# -----------------------------------------
# -----------------------------------------
# --- FUNCTION FOR INSERT VALUE IN DB -----
# -----------------------------------------
# -----------------------------------------
update_value = (that, callback)->
  # that = this
  update_request = "UPDATE #{that['config']['my_table_name']} SET "
  array_value = []
  can_comma = false

  rows_ = my_rows_global[that['config']['my_table_name']]
  
  length_row = rows_.length - 1
  for k in [0..length_row]
    value = rows_[k]
    value = rows_[k]
    name_field = value['Field']
    value_field = that[name_field]


    if can_comma
      update_request = update_request+' , '

    if name_field != that['config']['name_id']
      can_comma = true
      update_request = update_request+' '+name_field+' = ?'
      array_value.push(value_field)

  update_request = update_request+' WHERE '+that['config']['name_id']+' = ?'
  array_value.push(that[that['config']['name_id']])


  connection.query(update_request, array_value, (err, result)->
    throw err if err
    if callback?
      callback()
  )

  true



ActiveRecord = (infos)->
  # arg infos = {
      # table_name : '' => CAN'T BE NULL
      # constraint : ''
      # id_that['config']['is_uuid'] : ''
      # that['config']['name_id'] : ''
      # data : {}
      # that['config']['in_association']: {}
      # callback : ()->
  # }

  init = (that, infos=null)->
    Object.defineProperty(that, 'config',
      value: new Object()
      enumerable:false
      configurable: true
      writable: true
    )

    that['config'] = {
        infos_receive: infos
        my_table_name: infos.table_name
        my_class_name: infos.class_name
        my_constraint: ''
        name_id: if infos.name_id? then infos.name_id else 'id'
        is_uuid: if (infos.id_is_uuid? && infos.id_is_uuid) then true else false
        callback_init: if infos.callback? then infos.callback else null
        data_init: if infos.data? then infos.data else null
        row_modified: new Object()
        in_association: new Object()
        belongs_to: if infos.belongs_to? then infos.belongs_to else []
        has_many: if infos.has_many? then infos.has_many else []
        has_one: if infos.has_one? then infos.has_one else []

    }


    # ---------------------------------------------------------------------
    # ------------------- VAR ASSOCIATION/RELATION ------------------------
    # ---------------------------------------------------------------------
    # HERE, VAR WHEN THE OBJECT IS AN ASSOCIATION OF AN OTHER OBJECT ---
    

    if infos.in_association? && infos.in_association != null
      that['config']['in_association'] = {
          model: infos.in_association.model
          type: infos.in_association.type
          key_name: infos.in_association.key_name
      } 
      # that['config']['in_association']['model'] = infos.in_association.model
      # that['config']['in_association']['type'] = infos.in_association.type
      # that['config']['in_association']['key_name'] = infos.in_association.key_name



    # ------------- INIT THE ROW FOR THE OBJECT ------------
    # -- NOT TO THE BEGINNING OF THE CODE BECAUSE ----------
    # -- CALL SOME FUNCTION WHICH MUST BE DECLARE BEFORE ---
    if that['config']['data_init'] != null
      getRows(that, ()->
        inject_data(that, that['config']['data_init'])
        if that['config']['callback_init'] != null
          association(that, that['config']['callback_init'])
        else
          association(that, ()->
          )
        true
      )
    else
      getRows(that,()->
        that['config']['callback_init']() if that['config']['callback_init'] != null
      )




    # -----------------------------------------
    # -----------------------------------------
    # - ADD CONSTRAINT IF THERE ARE CONSTRAINT 
    # -----------------------------------------
    # -----------------------------------------
    if infos.constraint? && typeof infos.constraint == 'object' && infos.constraint.length > 0
      for key, val of infos.constraint
        if that['config']['my_constraint'] != ''
          that['config']['my_constraint'] += ' AND '  
        that['config']['my_constraint'] += ' '+key+'="'+val+'" '




  init(this, infos)

  @save = save
  @find = find
  @all = all
  @where = where
  @delete = delete_
  @getTableName = getTableName
  @create = new_

  @



  

module.exports = ActiveRecord

