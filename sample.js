
var express = require('express')
var app = express()

app.get('/', function (req, res) {
  res.send('welcome')
})

app.listen(3000)