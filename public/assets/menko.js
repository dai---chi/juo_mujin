
var context = new webkitAudioContext();
var gainNode = context.createGainNode();
var freqData;
var source;    //マイクの入力
var analyserNode = context.createAnalyser();
var volumeArr = [];
var recentVolume = [];

//FFTされたデータをもらう配列
var timeDomainData = new Uint8Array(analyserNode.frequencyBinCount);
var volume = document.getElementById("volume");
var sub = 0;

var pushedCharCode = "";
$(window).on('keydown', function(t) {
    if (t.keyCode == 8 ){
        $('.char:last').remove();
        messageArr.pop()
        // console.log(t);
        return false;
    }else if(t.keyCode == 32){ // space bar で scrollさせない
        pushedCharCode = t.keyCode
        setTimeout(checkRecent, 10); //要調整
        t.preventDefault();
    }
}).on('keypress', function(e) {
    pushedCharCode = e.keyCode
    setTimeout(checkRecent, 10); //要調整
    if( $( '#select1' ).is( ':checked' ) ){
        drow_fft();
    }
    // console.log(e);
})
//.on('load', function() {
//     $('#user_name').on('blur', function(){
//         $( '#select1' ).prop("checked", false )
//     }).on('focus', function(){
//         $( '#select1' ).prop("checked", true ) //attrでやると1回しか使えない https://gist.github.com/froop/5493920
//     });
// })

var maxVol;
var messageArr = [];
var tmpArr = []

function checkRecent() {
    // for (var j = volumeArr.length-40; j < volumeArr.length; j++) {
    for (var j = volumeArr.length-15; j < volumeArr.length; j++) {
        recentVolume.push(volumeArr[j]);
        // volumeArr.push(tmpArr);
    };
    console.log('volumeArr: '+volumeArr.length)
    // console.log(recentVolume);
    maxVol = Math.max.apply(null,recentVolume) - 128;
    // console.log("maxVol: "+maxVol);
    maxVol = maxVol * 2 + 15;
    // console.log(maxVol);
    if (pushedCharCode == 8) { // delete
        $('.char:last').remove();
        messageArr.pop()
    }else if (pushedCharCode == 13){ // enter
        if (messageArr.length != 0)
            window.chatController.sendMessage()
        $('#volume').empty()
        messageArr = []
    }else if (pushedCharCode == 9){ // tabで キーイベント取得解除
        $( '#select1' ).attr("checked", false )
    }else{
        $("#volume").append("<span class='char' style='font-size:"+maxVol+"px; line-height: "+maxVol+"px;'>"+String.fromCharCode(pushedCharCode)+"</span>");
        messageArr.push({ keyCode: pushedCharCode, vol: maxVol})
    }
    // console.log('pushedCharCode: ' + pushedCharCode)
    recentVolume = [];

}

setInterval(function(){
    var max = 0.0;
    if( $( '#select1' ).is( ':checked' ) || $( '#select2' ).is( ':checked' ) ){
        freqData = new Uint8Array(analyserNode.frequencyBinCount);
        analyserNode.getByteFrequencyData(freqData);
    }
    analyserNode.getByteTimeDomainData(timeDomainData);
    for (var i=0; i<timeDomainData.length; ++i){
        var d = timeDomainData[i];
        if(d > max) {
            max = d;
        }
    }
    volumeArr.push(max);
    if(volumeArr.length > 1000){
        volumeArr.splice(0,800)
    }
    if( $( '#select2' ).is( ':checked' ) ){
        drow_fft();
    }
},0);


function drow_fft(){

var canvas = document.getElementById('fft_graph');
var ctx = canvas.getContext("2d");
var w = canvas.width = window.innerWidth;
// var h = canvas.height = window.innerHeight;
// var w = canvas.width = 1430;
var h = canvas.height = 400;

var ctx = canvas.getContext('2d');
var sub = 0;

    //Canvasをクリア
    ctx.clearRect(0,0,w,h);
    //背景色
    ctx.fillStyle = "transparent";
    ctx.fillStyle = "999";
    //背景描画
    // ctx.fillRect(0,0,w,h);

    //周波数の色
    // ctx.fillStyle = "#ccc";
    // ctx.fillStyle = "";

    for(var i = 0; i < freqData.length; ++i) {
        //上部の描画
        // ctx.fillRect( (freqData.length-i)*2, 0, 1, freqData[i]*2);
        //下部の描画
        ctx.fillRect(i*2, h, 1, -freqData[i]*2);
        // ctx.strokeRect(i*5, h, 5, -freqData[i]*2);
    }
    freqData = [];
    // return false;
}


function play(){
	navigator.webkitGetUserMedia({video:false, audio:true}, function(stream) {
		source = context.createMediaStreamSource(stream);
        source.connect(analyserNode);
        console.log('Y')
        $('#enableAPI').hide()
    });
}

play();
