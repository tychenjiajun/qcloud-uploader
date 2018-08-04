COS = require "cos-nodejs-sdk-v5"
crypto = require "crypto"
{ Readable } = require 'stream'

module.exports = class Uploader

  constructor: (cfg) ->
    @appId = cfg.appId
    @secretID = cfg.secretID
    @secretKey = cfg.secretKey
    @domain = cfg.domain
    @bucket = cfg.bucket
    @region = cfg.region

  getKey: (buffer) ->
    fsHash = crypto.createHash('md5')
    fsHash.update(buffer)
    return fsHash.digest('hex')

  upload: (buffer, ext, callback) ->
    key = @getKey(buffer)
    filename = key
    filename += ".#{ext}" if typeof ext is 'string' and ext

    cos = new COS({
      AppId: @appId,
      SecretId: @secretID,
      SecretKey: @secretKey,
      })

    st = new Readable()
    st.push(buffer)

    params = {
      Bucket: @bucket,
      Region: @region,
      Key: filename,
      ContentLength: buffer.length+1024,
      Body: st
    }

    url = "#{@domain}/#{filename}"
    console.log url
    cos.putObject params, (err, data) ->
      if !err
        callback(null, {ret: data, url: url})
      else
        callback(err)
