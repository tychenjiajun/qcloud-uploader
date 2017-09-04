Uploader = require('./uploader');

{CompositeDisposable} = require 'atom'

module.exports =
  config:
    qcAId:
      title: "User's App Id"
      type: 'string'
      description: "Can be seen in https://console.qcloud.com/developer"
      default: ""
    qcSId:
      title: "User's Secret Id"
      type: 'string'
      description: "Can be seen in https://console.qcloud.com/capi"
      default: ""
    qcSK:
      title: "User's Secret Key"
      type: 'string'
      description: "Can be seen in https://console.qcloud.com/capi"
      default: ""
    qcBucket:
      title: "Bucket Name"
      type: 'string'
      description: "You can find or create one in https://console.qcloud.com/cos4/bucket"
      default: ""
    qcRegion:
      title: "Bucket Region"
      type: 'string'
      enum: ["ap-beijing-1","ap-beijing","ap-shanghai","ap-guangzhou","ap-chengdu","ap-singapore","ap-hongkong","na-toronto","eu-frankfurt"]
      default: "na-toronto"
      description: "See https://www.qcloud.com/document/product/436/6224"
    qcDomain:
      title: "Domain(Optional)"
      type: 'string'
      default: ""
      description: "Your CDN domain."


  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'qcloud-uploader:toggle': => @toggle()

  deactivate: ->
    @subscriptions.dispose()

  # `instance`:
  # API for markdown-assistant.
  # should return an uploader instance which has upload API
  #
  # usage:
  #   instance().upload(imagebuffer, '.png', (err, retData)->)
  #   * retData.url should be the online url
  instance: ->
    appId = atom.config.get('qcloud-uploader.qcAId')
    secretID = atom.config.get('qcloud-uploader.qcSId')
    secretKey = atom.config.get('qcloud-uploader.qcSK')
    bucket = atom.config.get('qcloud-uploader.qcBucket')
    region = atom.config.get('qcloud-uploader.qcRegion')
    domain = atom.config.get('qcloud-uploader.qcDomain')?.trim()

    domain = "http://#{bucket}-#{appId}.cos.#{region}.myqcloud.com" unless domain

    if domain?.indexOf('http') < 0
      domain = "http://#{domain}"

    return unless appId && secretID && secretKey && bucket && domain && region

    cfg = {
      appId: appId,
      secretID: secretID,
      secretKey: secretKey,
      bucket: bucket,
      region: region,
      domain: domain
    }
    return new Uploader(cfg)
