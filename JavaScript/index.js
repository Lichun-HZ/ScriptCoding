const http = require("http");

const server = http.createServer((req, res) => {
    //....
    res.setHeader("content-Type","text/plain;charset=utf-8");
    if(req.method === "GET"){
        res.end("GET请求成功");
    }else if(req.method === "POST"){
        //数据传输的时候监听事件
        let data = '';
        req.on('data', temp  => {
            data += temp;
        });
        //数据完成的之后的监听事件
        req.on('end' , () =>{
            console.log(data);
        });
        //数据传输失败的监听事件
        req.on('error', (error) =>{
            console.log("error", error.message);
        });
        res.end("POST请求");
    }
})

server.listen(3000, () => {
    console.log("服务器开启成功,请访问 localhost:3000");
});