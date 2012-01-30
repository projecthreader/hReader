require 'rubygems'
require 'betabuilder'

RestClient.proxy = ENV['http_proxy']

BetaBuilder::Tasks.new do |config|
  # your Xcode target name
  config.target = "HReader"

  # the Xcode configuration profile
  config.configuration = "Ad Hoc"
  
  config.deploy_using(:testflight) do |tf|
    tf.api_token          = "DTtxmqCuN63znsxUo2Cjz3HO6PqettzBghSQSA4uPRQ"
    tf.team_token         = "e8ef4e7b3c88827400af56886c6fe280_MjYyNTYyMDExLTEwLTE5IDE2OjU3OjQ3LjMyNDk4OQ"
    tf.notify             = true
    tf.distribution_lists = ["hReader Testers"]
    
    tf.generate_release_notes do
      File.open("CHANGELOG", "rb").read.split("\n").slice(0..20).join("\n")
    end
  end
  
end