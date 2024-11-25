import media from '@ohos.multimedia.media';
import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import http from '@ohos.net.http';



export class AudioRecorderDemo {
  private avRecorder;
  file:fs.File;
  surfaceID = null; // 该surfaceID用于传递给相机接口创造videoOutput
  private avProfile: media.AVRecorderProfile = {
    audioBitrate: 64000, // 音频比特率
    audioChannels: 1, // 音频声道数
    audioCodec: media.CodecMimeType.AUDIO_AAC, // 音频编码格式，当前支持ACC，MP3，G711MU
    audioSampleRate: 16000, // 音频采样率
    fileFormat: media.ContainerFormatType.CFT_MPEG_4A, // 封装格式，当前支持MP4，M4A，MP3，WAV
  };
  private avConfig: media.AVRecorderConfig = {
    audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC, // 音频输入源，这里设置为麦克风
    profile: this.avProfile,
    rotation : 0, // 合理值0、90、180、270，非合理值prepare接口报错
    url: 'fd://35', // 参考应用文件访问与管理开发示例新建并读写一个文件
  };

   async createFile(context)  {
    // 获取应用文件路径
    let filesDir = context.filesDir;
    console.log("filesDir"+filesDir);
    // 新建并打开文件
     try {
       this.file = fs.openSync(`${filesDir}/test_audio.m4a`, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
       console.info('打开文件成功');
       // 文件打开成功后，可以在这里进行后续的文件操作，比如写入音频数据等
     } catch (error) {
       console.info('打开文件出现错误：', error);
       // 根据具体错误情况，可以采取相应的补救措施，比如提示用户检查存储空间等
     }
  }
  // 注册audioRecorder回调函数
  setAudioRecorderCallback() {
    // 状态机变化回调函数
    this.avRecorder.on('stateChange', (state, reason) => {
      console.log(`AudioRecorder current state is ${state}`);
    })
    // 错误上报回调函数
    this.avRecorder.on('error', (err) => {
      console.error(`AudioRecorder failed, code is ${err.code}, message is ${err.message}`);
    })
  }

  // 开始录制准备工作
  async startRecordingProcess(context) {
    // 1.创建录制实例
    this.avRecorder = await media.createAVRecorder();
    this.setAudioRecorderCallback();
    // 2.获取录制文件fd赋予avConfig里的url；参考FilePicker文档
    await this.createFile(context);
    console.log(`file.fd:  ${this.file}`)
    this.avConfig.url='fd://'+''+this.file.fd
    console.log(this.avConfig.url)
    // 3.配置录制参数完成准备工作
    this.avRecorder.prepare(this.avConfig, (err) => {
      if (err == null) {
        console.info('prepare success');
        try {
          this.avRecorder.start();
          console.info('start AVRecorder success');
        }catch(err){
          console.error('start failed and error is ' + err.message);
        }
      } else {
        console.error('prepare failed and error is ' + err.message);
      }
    })
  }


  // 停止录制对应的流程
  async stopRecordingProcess() {
    // 1. 停止录制
    if (this.avRecorder.state === 'started'
    || this.avRecorder.state === 'paused') { // 仅在started或者paused状态下调用stop为合理状态切换
      await this.avRecorder.stop();
    }
    // 2.重置
    await this.avRecorder.reset();
    // 3.释放录制实例
    await this.avRecorder.release();
    // 4.关闭录制文件fd
    fs.close(this.file, (err) => {
      if (err) {
        console.error("close file failed with error message: " + err.message + ", error code: " + err.code);
      } else {
        console.info("close file success");
      }
    });
    console.log("stop success")
  }

}
