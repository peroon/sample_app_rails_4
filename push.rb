commands = [
  'git push heroku',
  'heroku pg:reset DATABASE',
  'heroku run rake db:migrate',
  'heroku run rake db:populate',
  'heroku open',
]

commands.each do |command|
  p command
  system(command)
end
