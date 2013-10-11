require 'rubygems'
require 'bundler/setup'

require './app'
require './middleware/competition_backend'

use TwitterCompete::CompetitionBackend

run TwitterCompete::App

