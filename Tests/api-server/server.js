const express = require('express')
const bodyPaser = require('body-parser')

const app = express()
app.use(bodyPaser.urlencoded({extends: false}))
app.use(bodyPaser.json())

const port = 3000

app.get('/', (req, res) => res.send('Hello World!'))
app.get('/get', (req, res) => res.send(`{path,"${req.path}", data: ${JSON.stringify(req.query)}}`))
app.post('/post', (req, res) => res.send(`{path,"${req.path}", data: ${JSON.stringify(req.body)}}`))

app.listen(port, () => console.log(`Example app listening on port ${port}!`))
