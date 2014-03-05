// forked from ryoheycc's " Web Audio APIで音楽のリアルタイム波形表示" http://jsdo.it/ryoheycc/tk3X
// forked from warinside's "Web Audio API Test+GainNode" http://jsdo.it/warinside/3AY7
//参考
//http://www.usamimi.info/~ide/programe/tinysynth/doc/audioapi-report.pdf
//http://epx.com.br/artigos/audioapi.php
//http://code.google.com/p/chromium/issues/detail?id=88122
//https://dvcs.w3.org/hg/audio/raw-file/tip/webaudio/specification.html#AudioSourceNode-section

var canvas = document.getElementById("world");
var ctx = canvas.getContext("2d");
// var w = canvas.width = window.innerWidth;
// var h = canvas.height = window.innerHeight;
var w = canvas.width = 1430;
var h = canvas.height = 400;

// var w = canvas.width = 0;
// var h = canvas.height = 0;


var context = new webkitAudioContext();
var gainNode = context.createGainNode();
var freqData;
var source;    //マイクの入力

var analyserNode = context.createAnalyser();
var volumeArr = [];
var recentVolume = [];


/**
*FFTされたデータをもらう配列。
*要素数がfrequencyBinCount(FFTのサイズの半分 FFT結果は対称だから半分でいい)より少ないときは
*余分なデータは切り捨てられる。
*/
var timeDomainData = new Uint8Array(analyserNode.frequencyBinCount);

//
var canvas = document.getElementById('world');
var volume = document.getElementById("volume");
var volume2 = document.getElementById("volume2");
var ctx = canvas.getContext('2d');
var sub = 0;

// function draw(data){
//     var max = 0.0;
//     ctx.beginPath();
//     ctx.fillStyle = "black";
//     ctx.rect(0,0,canvas.width,canvas.height);
//     ctx.fill();
//     var value;
//     ctx.beginPath();
//     ctx.moveTo(0,-999);
//     for (var i=0; i<data.length; ++i){
//         var d = data[i];
//         // console.log(d)
//         if(max-d > 10) {
//             sub = max-d;
//             // $("#volume2").prepend("<p>"+sub+" in "+Date()+"</p>");
//         }
//         if(d > max) { max = d; volume.innerText = max; }
//         // if(d > 150) { $("#volume2").prepend("<p>"+max+" in "+Date()+"</p>");}
//         value = d-128.0+canvas.height/2;
//         ctx.lineTo(i,value);
//     }
//     ctx.moveTo(0,999);
//     ctx.closePath();
//     ctx.strokeStyle = "gray";
//     ctx.stroke();
// }
var pushedCharCode = "";
$(window).keydown(function(e){
    // var max = 0.0;
    // console.log(e.keyCode);
    // analyserNode.getByteTimeDomainData(timeDomainData);
    // $("volume2").prepend("<p style='font-size:"+sub+"px'>"+e.keyCode+"</p>");
    // for (var i=0; i<timeDomainData.length; ++i){
        // var d = timeDomainData[i];
        // console.log(d)
        // if(max-d > 10) {
            // sub = max-d;
            // $("#volume2").prepend("<p>"+sub+" in "+Date()+"</p>");
        // }
        // if(d > max) {// 2013-11-22 遅延によって上手く取得できない 他の方法考えなければ
            // max = d;

            // volume.innerText = volumeArr;
            // sub = max - 120;
            // $("#volume2").prepend("<p style='font-size:"+sub+"px;'>"+String.fromCharCode(e.keyCode)+"</p>");
        // }
        // if(d > 150) { $("#volume2").prepend("<p>"+max+" in "+Date()+"</p>");}
        // value = d-128.0+canvas.height/2;
        // ctx.lineTo(i,value);ka
    // }
    pushedCharCode =e.keyCode;


    //周波数でーた
    // arr = [];
    // for (var i = 0; i < freqData.length; i++) {
    //     // console.log('200 to 230: '+freqData[i]);
    //     arr.push(freqData[i])
    // }
    //周波数でーたここまで

    //Canvasをクリア
    ctx.clearRect(0,0,w,h);
    //背景色
    ctx.fillStyle = "transparent";
    ctx.fillStyle = "333";
    //背景描画
    // ctx.fillRect(0,0,w,h);

    //周波数の色
    // ctx.fillStyle = "#ccc";
    ctx.fillStyle = "";

    for(var i = 0; i < freqData.length; ++i) {
        //上部の描画
        // ctx.fillRect(i*5, 0, 5, freqData[i]*2);
        //下部の描画
        ctx.fillRect(i*2, h, 1, -freqData[i]*2);
        // ctx.strokeRect(i*5, h, 5, -freqData[i]*2);
    }
    freqData = [];

    setTimeout("checkRecent()", 50); //要調整
    return false;
});
var maxVol;
var arr = [];
function checkRecent() {



    for (var j = volumeArr.length-40; j < volumeArr.length; j++) {
        recentVolume.push(volumeArr.pop());
    };
    console.log(recentVolume);
    maxVol = Math.max.apply(null,recentVolume) - 128;
    console.log("maxVol: "+maxVol);
    // audio(0.1, maxVol/127*40);
    maxVol = maxVol * 2 + 15;
    console.log(maxVol);
    if (pushedCharCode==8) {
        $(".char:last").remove();
    }else{
        $("#volume").append("<span class='char' style='font-size:"+maxVol+"px;'>"+String.fromCharCode(pushedCharCode)+"</span>");
    }
    recentVolume = [];



}


setInterval(function(){
    var max = 0.0;
    freqData = new Uint8Array(analyserNode.frequencyBinCount);
    analyserNode.getByteFrequencyData(freqData);


    analyserNode.getByteTimeDomainData(timeDomainData);
    // draw(timeDomainData);
    // console.log('aaaaa')
    for (var i=0; i<timeDomainData.length; ++i){
        var d = timeDomainData[i];
        if(d > max) {
            max = d;
        }
    }
    volumeArr.push(max);
},0);


function play(){
	navigator.webkitGetUserMedia({video:false, audio:true}, function(stream) {
		var source = context.createMediaStreamSource(stream);
        // console.log(source);
        source.connect(analyserNode);
        // source.connect(gainNode);
        // gainNode.gain.value = 12.5;
        // gainNode.connect(context.destination);

        // analyserNode.connect(context.destination);
    });

    // setInterval(function(){
    //    analyserNode.getByteTimeDomainData(timeDomainData);
    //    draw(timeDomainData);
   // },1000);
}

play();

