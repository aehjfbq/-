import http from '@ohos.net.http';
import fs from '@ohos.file.fs';
import util from '@ohos.util';
import common from '@ohos.app.ability.common';
//消息内容结构
interface content{
  name:string;//用户名称
  text:string;//消息内容
  islove:boolean;//是否喜欢
}
interface local_content{
  lodata:contentdata;
}
// 定义消息类型
interface Message {
  role: string;
  content: string;
}

// 定义请求数据类型
interface RequestData {
  messages: Message[];
}
//定义usage格式
interface usages{
  prompt_tokens: number;
  completion_tokens: number;
  total_tokens: number;
}
// 定义响应数据类型
interface ResponseData {
  id: string;
  object: string;
  created: number;
  result: string;
  is_truncated: boolean;
  need_clear_history: boolean;
  usage: usages;
}
interface ResponData_voice {
  corpus_no:string,
  err_no:number,
  result:string,
  sn:string
}


//消息类
class contentdata{
  data:content[];//消息属性
  num:number;//消息数量
  constructor( ){
    this.data=[];
    this.num=-1
  }
  //添加新消息
  public pushmessage(text:string,user:string){
    if(text==''){
      console.log('傻鸟，别传空字符')
      return ;
    }
    this.data.push({
      name:user,
      text:text,
      islove:false
    })
    this.num++;
  }
  public init_message(){
    this.data=[];
    this.num=-1
  }
}
//对话历史类
class local_contentdata{
  local_data:local_content[];//历史对话记录
  local_num:number;//历史对话数量
  //构造函数
  constructor( ){
    this.local_data=[];
    this.local_num=-1;
    console.log('local_num:'+this.local_num.toString())
  }
  public pushmessage(message_manage:contentdata){
    this.local_data.push({lodata:message_manage});
    this.local_num++;
  }
}
//获取文本信息
export  function  message(s:string,message_manage:contentdata){
  let httpRequest = http.createHttp();
  let access_token:string ='24.5bd3c0b6fee744bbe48984c291286dda.2592000.1735104200.282335-116382962';
  let url_a:string ="https://aip.baidubce.com/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/completions_pro?access_token="+access_token;
  // 创建请求数据对象
  let requestData: RequestData = {
    messages: [
      {role: "user", content: s}
    ]
  };
  httpRequest.request(
    url_a,{
    method: http.RequestMethod.POST,
    // 设置请求头为 JSON 格式
    header: {'Content-Type': 'application/json'},
    // 将请求数据转换为字符串后发送
    extraData: JSON.stringify(requestData)
  },
    (error,data)=>{
      if(error) {
        message_manage.pushmessage('网络错误','原神')
        //console.log('666')
      }
      else{
        if(http.ResponseCode.OK==data.responseCode){
          let response: ResponseData = JSON.parse(data.result.toString());
          message_manage.pushmessage(response.result,'原神')
          //console.log('Response: ', response)
        }
        else{
          message_manage.pushmessage('访问错误','原神')
          //console.log('Response:123')
        }
      }
    }
  )
};
export  function  voice_tomessage(filePath: string,message_manage:contentdata){

  let file = fs.openSync(filePath, fs.OpenMode.READ_WRITE);// 创建请求数据对象
  let stat = fs.statSync(filePath); // 获取文件状态
  let byteSize = stat.size;// 提取文件状态信息中的文件大小（字节数），赋值给byteSize变量
  let buf = new ArrayBuffer(stat.size);// 根据文件大小创建一个ArrayBuffer，用于存储读取的文件内容
  let num = fs.readSync(file.fd, buf);   // 读取文件
  let d=new Uint8Array(buf.slice(0, num));//转换成Uint8Array
  let base64 = new  util.Base64Helper();// 实例化Base64Helper
  let data=base64.encodeSync(d);//base64编码,返回Uint8Array
  let textDecoder = util.TextDecoder.create('utf-8', { ignoreBOM : true });
  let retStr = textDecoder.decodeWithStream( data , {stream: false});   // 可以把Uint8Array转码成base64

  let httpRequest = http.createHttp();
  let access_token:string ='24.cc5caec2f96e8c6788511feb13dc17f7.2592000.1735009730.282335-116371132';
  let url_a:string ="https://vop.baidu.com/server_api";
  httpRequest.request(
    url_a,{
    method: http.RequestMethod.POST,
    // 设置请求头为 JSON 格式
    header: {'Content-Type': 'application/json'},
    // 将请求数据转换为字符串后发送
    extraData: JSON.stringify({
      "format":"m4a",
      "rate":16000,
      "dev_pid":1537,
      "channel":1,
      "token":access_token ,
      "cuid":"baidu_workshop",
      "len":byteSize,
      "speech":retStr,
    })
  },
    (error,data)=>{
      if(error) {
        console.log('网络错误');
        message_manage.pushmessage('网络连接错误','user');
      }
      else{
        if(http.ResponseCode.OK==data.responseCode){
          console.log('访问成功');
          let data_voice:ResponData_voice=JSON.parse(data.result.toString());
          message_manage.pushmessage(data_voice.result.toString(),'user');
          message(data_voice.result.toString(),message_manage);
          console.log(data_voice.result);
        }
        else{
          message_manage.pushmessage('访问错误','user')
          console.log('访问错误');
        }
      }
    });
}

export {content,contentdata,local_contentdata};