path = require "path"
levelup = require "levelup"

module.exports = (robot) ->
  leveldbPath = process.env.LEVELDB_PATH

  if leveldbPath?
    robot.logger.info(
      "hubot-leveldb-brain: Discovered leveldb from #{leveldbPath}
       environment variable"
    )
  else
    leveldbPath = path.join(process.cwd(), 'leveldb-brain')
    robot.logger.info(
      "hubot-leveldb-brain: Using default leveldb from #{leveldbPath}"
    )

  db = levelup(leveldbPath)
  robot.logger.debug "hubot-leveldb-brain: Successfully opened LevelDB database"
  prefix = 'hubot'

  robot.brain.setAutoSave false

  getData = ->
    db.get "#{prefix}:storage", (err, reply) ->
      if err
        throw err
      else if reply
        robot.logger.info(
          "hubot-leveldb-brain: Data for #{prefix} brain retrieved from LevelDB"
        )
        robot.brain.mergeData(JSON.parse(reply.toString()))
      else
        robot.logger.info(
          "hubot-leveldb-brain: Initializing new data for #{prefix} brain"
        )
        robot.brain.mergeData({})
      robot.brain.setAutoSave(true)

  robot.brain.on 'save', (data = {}) ->
    db.put("#{prefix}:storage", JSON.stringify data)

  robot.brain.on 'close', ->
    db.close()

  getData()
