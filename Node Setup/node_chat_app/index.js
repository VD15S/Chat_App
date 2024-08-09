const express= require ('express');
var http= require ('http');
const cors=require('cors');
const app=express();
const port = process.env.PORT || 5000;
var server= http.createServer(app);
var io = require('socket.io')(server,{
    cors:
    {
        origin:"*"
    }
});

app.use(express.json());
app.use(cors());
io.on('connection',(socket)=>{
    console.log("Connected ");
    console.log(socket.id,"has joined");
    socket.on('message',(data)=>{
        console.log(data);
        socket.broadcast.emit('message-receive', data)
    })
    });

    server.listen(port,()=>{
        console.log("Server started");
    });


    
